//
// LWFontManager.swift
// Created by Luo Wei on 2017/10/27.
// Copyright (c) 2017 wodedata. All rights reserved.
//
// Swift/SwiftUI version of LWFontManager
// This file uses fontName as the PostScript name of the font

import UIKit
import CoreText
import Foundation

#if DEBUG
func LWFLog(_ format: String, _ args: CVarArg...) {
    NSLog(format, args)
}
#else
func LWFLog(_ format: String, _ args: CVarArg...) {}
#endif

// MARK: - LWFontManager

public class LWFontManager: NSObject {

    // MARK: - Properties

    public var currentDataTask: URLSessionDataTask?

    private var fontDirectoryPath: String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = (documentsPath as NSString).appendingPathComponent("fonts")

        LWFontManager.createDirectory(ifNotExist: path)

        LWFLog("======fontDirectoryPath:%@", path)
        LWFLog("======App Bundle Path:%@", Bundle.main.bundlePath)
        LWFLog("======Home Path:%@", NSHomeDirectory())

        return path
    }

    private var appleFontPathDict: [String: String] = [:]
    private var fontTaskDict: [String: LWFontDownloadTask] = [:]
    private var taskDict: [String: LWFontDownloadTask] = [:]

    private var showProgressBlock: (() -> Void)?
    private var updateProgressBlock: ((Float) -> Void)?
    private var completeBlock: (() -> Void)?

    private static let appleFontPathDataKey = "Key_AppleFontPathData"

    // MARK: - Singleton

    public static let shared = LWFontManager()

    private override init() {
        super.init()

        // Load saved Apple font paths
        if let data = UserDefaults.standard.data(forKey: LWFontManager.appleFontPathDataKey),
           let dict = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String: String] {
            appleFontPathDict = dict
        }
    }

    // MARK: - Public Methods

    /// Check if a font is available
    public static func isAvailable(fontName: String) -> Bool {
        let font = UIFont(name: fontName, size: 12.0)
        return font != nil && (font!.fontName.compare(fontName) == .orderedSame || font!.familyName.compare(fontName) == .orderedSame)
    }

    /// Remove file at the specified path
    @discardableResult
    public static func removeFile(at filePath: String) -> Bool {
        do {
            try FileManager.default.removeItem(atPath: filePath)
            return true
        } catch {
            LWFLog("Error! %@", error.localizedDescription)
            return false
        }
    }

    /// Write data to the specified file path
    @discardableResult
    public static func writeData(_ data: Data, toFilePath filePath: String) -> Bool {
        do {
            try data.write(to: URL(fileURLWithPath: filePath), options: .atomic)
            LWFLog("=======font writeToFile:YES")
            return true
        } catch {
            LWFLog("=======font writeToFile:NO - %@", error.localizedDescription)
            return false
        }
    }

    /// Create directory if it doesn't exist
    @discardableResult
    public static func createDirectory(ifNotExist path: String) -> Bool {
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                LWFLog("Create fonts directory Success!")
                return true
            } catch {
                LWFLog("Error! %@", error.localizedDescription)
                return false
            }
        }
        return true
    }

    /// Register all custom local fonts
    public static func registerAllCustomLocalFonts() {
        let manager = LWFontManager.shared

        // Register all font files in the fonts directory
        if let fontFiles = try? FileManager.default.contentsOfDirectory(atPath: manager.fontDirectoryPath) {
            for fontFileName in fontFiles {
                let fontPath = (manager.fontDirectoryPath as NSString).appendingPathComponent(fontFileName)
                registerFont(at: fontPath)
            }
        }
    }

    /// Create a UIFont with the specified font name and size
    public static func font(withFontName fontName: String, size: CGFloat) -> UIFont? {
        if isAvailable(fontName: fontName) {
            return UIFont(name: fontName, size: size)
        }
        return nil
    }

    /// Use font with callback
    public static func useFont(name fontName: String, size: CGFloat, useBlock: @escaping (UIFont?) -> Void) {
        if let font = font(withFontName: fontName, size: size) {
            useBlock(font)
        } else {
            userAppleFont(withFontName: fontName, size: size) { font in
                useBlock(font)
            }
        }
    }

    /// Download custom font from URL
    public static func downloadCustomFont(
        fontName: String,
        urlString: String,
        showProgressBlock: (() -> Void)? = nil,
        updateProgressBlock: ((Float) -> Void)? = nil,
        completeBlock: (() -> Void)? = nil
    ) {
        let manager = LWFontManager.shared
        manager.showProgressBlock = showProgressBlock
        manager.updateProgressBlock = updateProgressBlock
        manager.completeBlock = completeBlock
        manager.downloadCustomFont(fontName: fontName, urlString: urlString)
    }

    /// Download Apple-provided font
    public static func downloadAppleFont(
        fontName: String,
        showProgressBlock: (() -> Void)? = nil,
        updateProgressBlock: ((Float) -> Void)? = nil,
        completeBlock: (() -> Void)? = nil
    ) {
        let manager = LWFontManager.shared
        manager.showProgressBlock = showProgressBlock
        manager.updateProgressBlock = updateProgressBlock
        manager.completeBlock = completeBlock
        manager.downloadAppleFont(fontName: fontName)
    }

    // MARK: - Private Methods

    private static func existsCustomFontFile(withFontName fontName: String) -> Bool {
        let manager = LWFontManager.shared
        let fontPath = (manager.fontDirectoryPath as NSString).appendingPathComponent(fontName)
        return FileManager.default.fileExists(atPath: fontPath)
    }

    private func downloadCustomFont(fontName: String, urlString: String) {
        // Check if font is already available
        if LWFontManager.isAvailable(fontName: fontName) {
            updateProgressBlock?(1.0)
            completeBlock?()
            return
        }

        // Check if font file exists
        let exists = LWFontManager.existsCustomFontFile(withFontName: fontName)
        if exists {
            if !LWFontManager.isAvailable(fontName: fontName) {
                let fontPath = (fontDirectoryPath as NSString).appendingPathComponent(fontName)
                LWFontManager.registerFont(at: fontPath)
            }
            updateProgressBlock?(1.0)
            completeBlock?()
            return
        }

        // Download font
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.setValue("http://app.wodedata.com", forHTTPHeaderField: "Referer")

        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: .main)

        // Cancel previous task if needed
        if let currentTask = currentDataTask, currentTask.state != .completed {
            currentTask.cancel()
        }

        currentDataTask = session.dataTask(with: request)
        currentDataTask?.resume()

        let fontTask = LWFontDownloadTask(
            identifier: currentDataTask!.taskIdentifier,
            fontName: fontName,
            dataTask: currentDataTask!
        )
        fontTaskDict[fontName] = fontTask
        taskDict[String(currentDataTask!.taskIdentifier)] = fontTask
    }

    private static func registerFont(at fontPath: String) {
        guard let fontData = try? Data(contentsOf: URL(fileURLWithPath: fontPath)) else {
            return
        }

        guard let dataProvider = CGDataProvider(data: fontData as CFData) else {
            return
        }

        guard let font = CGFont(dataProvider) else {
            removeFile(at: fontPath)
            return
        }

        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font, &error) {
            if let error = error?.takeRetainedValue() {
                let errorDescription = CFErrorCopyDescription(error)
                LWFLog("Failed to load font: %@", errorDescription as String? ?? "Unknown error")
            }
        }
    }

    // MARK: - Apple Font Methods

    private static func userAppleFont(
        withFontName fontName: String,
        size: CGFloat,
        matchedFontBlock: @escaping (UIFont?) -> Void
    ) {
        let manager = LWFontManager.shared

        // Check if font was previously downloaded
        guard manager.appleFontPathDict[fontName] != nil else {
            matchedFontBlock(nil)
            return
        }

        // Create font descriptor
        let attributes: [String: Any] = [kCTFontNameAttribute as String: fontName]
        let descriptor = CTFontDescriptorCreateWithAttributes(attributes as CFDictionary)
        let descriptors = [descriptor] as CFArray

        var errorDuringDownload = false

        // Match font descriptors
        CTFontDescriptorMatchFontDescriptorsWithProgressHandler(descriptors, nil) { state, progressParameter in
            if state == .didFinish {
                if !errorDuringDownload {
                    DispatchQueue.main.async {
                        let font = UIFont(name: fontName, size: size)
                        matchedFontBlock(font)
                    }
                }
            }
            return true
        }
    }

    private func downloadAppleFont(fontName: String) {
        // Check if font is already available
        if LWFontManager.isAvailable(fontName: fontName) {
            updateProgressBlock?(1.0)
            completeBlock?()
            return
        }

        // Create font descriptor
        let attributes: [String: Any] = [kCTFontNameAttribute as String: fontName]
        let descriptor = CTFontDescriptorCreateWithAttributes(attributes as CFDictionary)
        let descriptors = [descriptor] as CFArray

        var errorDuringDownload = false

        // Download font
        CTFontDescriptorMatchFontDescriptorsWithProgressHandler(descriptors, nil) { [weak self] state, progressParameter in
            guard let self = self else { return true }

            let progressDict = progressParameter as NSDictionary
            let progressValue = (progressDict[kCTFontDescriptorMatchingPercentage] as? NSNumber)?.doubleValue ?? 0.0

            switch state {
            case .didBegin:
                DispatchQueue.main.async {
                    LWFLog("Begin Matching")
                }

            case .didFinish:
                DispatchQueue.main.async {
                    if !errorDuringDownload {
                        LWFLog("%@ MatchingDidFinish", fontName)
                        self.updateProgressBlock?(1.0)
                        if LWFontManager.isAvailable(fontName: fontName) {
                            self.saveAppleFontPath(withFontName: fontName)
                            self.completeBlock?()
                        } else {
                            LWFLog("=====font %@ is Unavailable", fontName)
                        }
                    }
                }

            case .willBeginDownloading:
                LWFLog("Begin Downloading")
                DispatchQueue.main.async {
                    self.showProgressBlock?()
                }

            case .didFinishDownloading:
                LWFLog("Finish downloading")
                DispatchQueue.main.async {
                    self.updateProgressBlock?(1.0)
                    if LWFontManager.isAvailable(fontName: fontName) {
                        self.completeBlock?()
                    } else {
                        LWFLog("=====font %@ is Unavailable", fontName)
                    }
                }

            case .downloading:
                LWFLog("Downloading %.0f%% complete", progressValue)
                DispatchQueue.main.async {
                    self.updateProgressBlock?(Float(progressValue / 100))
                }

            case .didFailWithError:
                if let error = progressDict[kCTFontDescriptorMatchingError] as? Error {
                    LWFLog("%@", error.localizedDescription)
                }
                errorDuringDownload = true

            default:
                break
            }

            return true
        }
    }

    private func saveAppleFontPath(withFontName fontName: String) {
        guard let fontRef = CTFontCreateWithName(fontName as CFString, 0, nil) else { return }

        if let fontURL = CTFontCopyAttribute(fontRef, kCTFontURLAttribute) as? URL {
            LWFLog("====Apple Font URL:%@", fontURL.path)

            appleFontPathDict[fontName] = fontURL.path

            if let data = try? NSKeyedArchiver.archivedData(withRootObject: appleFontPathDict, requiringSecureCoding: false) {
                UserDefaults.standard.set(data, forKey: LWFontManager.appleFontPathDataKey)
                UserDefaults.standard.synchronize()
            }
        }
    }
}

// MARK: - URLSessionDataDelegate

extension LWFontManager: URLSessionDataDelegate {

    public func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        LWFLog("--------%d:%s", #line, #function)
        completionHandler(.allow)

        guard let fontTask = taskDict[String(dataTask.taskIdentifier)] else { return }

        fontTask.progress = 0.0
        fontTask.downloadSize = response.expectedContentLength
        fontTask.dataToDownload = Data()

        DispatchQueue.main.async { [weak self] in
            self?.showProgressBlock?()
        }
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        LWFLog("--------%d:%s", #line, #function)

        guard let fontTask = taskDict[String(dataTask.taskIdentifier)] else { return }

        fontTask.dataToDownload.append(data)
        fontTask.progress = Float(fontTask.dataToDownload.count) / Float(fontTask.downloadSize)

        LWFLog(
            "=======progress:%.4f, dataToDownload:%lli, downloadSize:%lli",
            fontTask.progress,
            Int64(fontTask.dataToDownload.count),
            fontTask.downloadSize
        )

        DispatchQueue.main.async { [weak self] in
            let progress = min(fontTask.progress, 1.0)
            self?.updateProgressBlock?(progress)

            if fontTask.progress >= 1 {
                self?.updateProgressBlock?(1.0)
            }
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        LWFLog("--------%d:%s", #line, #function)
        LWFLog("=====completed; error: %@", error?.localizedDescription ?? "nil")

        if error == nil {
            if let fontTask = taskDict[String(task.taskIdentifier)] {
                // Write to file
                let fontPath = (fontDirectoryPath as NSString).appendingPathComponent(fontTask.fontName)
                LWFontManager.writeData(fontTask.dataToDownload, toFilePath: fontPath)

                // Register font
                LWFontManager.registerFont(at: fontPath)
            }
        }

        // Complete callback
        completeBlock?()
    }
}
