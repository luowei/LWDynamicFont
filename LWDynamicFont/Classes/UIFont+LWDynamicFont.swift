//
// UIFont+LWDynamicFont.swift
// Created by Luo Wei on 2017/10/27.
// Copyright (c) 2017 wodedata. All rights reserved.
//
// UIFont extension for LWDynamicFont with method swizzling

import UIKit
import ObjectiveC

// MARK: - UIFont Extension

public extension UIFont {

    /// Create a dynamic font with the specified name and size
    /// - Parameters:
    ///   - fontName: The PostScript name of the font
    ///   - size: The point size of the font
    /// - Returns: A UIFont instance, or fallback font if the custom font is not available
    static func dynamicFont(name fontName: String, size: CGFloat) -> UIFont {
        if let font = LWFontManager.font(withFontName: fontName, size: size) {
            return font
        }
        // Fallback to system font
        return UIFont.systemFont(ofSize: size)
    }

    /// Check if a font with the specified name is available
    /// - Parameter fontName: The PostScript name of the font
    /// - Returns: true if the font is available, false otherwise
    static func isDynamicFontAvailable(name fontName: String) -> Bool {
        return LWFontManager.isAvailable(fontName: fontName)
    }

    /// Use a font asynchronously, downloading if necessary
    /// - Parameters:
    ///   - fontName: The PostScript name of the font
    ///   - size: The point size of the font
    ///   - completion: Callback with the UIFont instance or nil if unavailable
    static func useDynamicFont(name fontName: String, size: CGFloat, completion: @escaping (UIFont?) -> Void) {
        LWFontManager.useFont(name: fontName, size: size, useBlock: completion)
    }
}

// MARK: - Method Swizzling

private extension UIFont {

    @objc static func lwdf_swizzledFont(name fontName: String, size fontSize: CGFloat) -> UIFont? {
        var font: UIFont?

        if fontSize > 0 {
            // Check if font is available
            if let testFont = UIFont.lwdf_swizzledFont(name: fontName, size: 12.0) {
                let isAvailable = testFont.fontName.compare(fontName) == .orderedSame ||
                                testFont.familyName.compare(fontName) == .orderedSame

                if isAvailable {
                    font = UIFont.lwdf_swizzledFont(name: fontName, size: fontSize)
                } else {
                    // Check if font file exists in custom directory
                    let exists = LWFontManager.shared.fontDirectoryPath
                        .appending("/\(fontName)")
                        .withCString { path in
                            FileManager.default.fileExists(atPath: String(cString: path))
                        }

                    if exists {
                        // Register font and try again
                        let fontPath = (LWFontManager.shared.fontDirectoryPath as NSString)
                            .appendingPathComponent(fontName)
                        LWFontManager.registerFont(at: fontPath)
                        font = UIFont.lwdf_swizzledFont(name: fontName, size: fontSize)
                    } else {
                        // Fallback to Helvetica
                        font = UIFont.lwdf_swizzledFont(name: "Helvetica", size: fontSize)
                    }
                }
            } else {
                // Font not found, use fallback
                font = UIFont.lwdf_swizzledFont(name: "Helvetica", size: fontSize)
            }
        }

        return font
    }

    static func lwdf_swizzleFontMethod() {
        guard self === UIFont.self else { return }

        let originalSelector = #selector(UIFont.init(name:size:))
        let swizzledSelector = #selector(UIFont.lwdf_swizzledFont(name:size:))

        guard let originalMethod = class_getClassMethod(self, originalSelector),
              let swizzledMethod = class_getClassMethod(self, swizzledSelector) else {
            return
        }

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

// MARK: - Automatic Swizzling Setup

extension UIFont {

    @objc static func lwdf_load() {
        DispatchQueue.once(token: "com.lwdynamicfont.swizzle") {
            lwdf_swizzleFontMethod()
        }
    }
}

// MARK: - Helper for Once Execution

private extension DispatchQueue {

    private static var onceTokens = Set<String>()
    private static var onceTokensLock = NSLock()

    static func once(token: String, block: () -> Void) {
        onceTokensLock.lock()
        defer { onceTokensLock.unlock() }

        guard !onceTokens.contains(token) else {
            return
        }

        onceTokens.insert(token)
        block()
    }
}

// MARK: - Public Interface for Swizzling

public extension UIFont {

    /// Enable automatic font registration for custom fonts
    /// Call this method in your AppDelegate's application(_:didFinishLaunchingWithOptions:)
    static func enableDynamicFontSwizzling() {
        lwdf_load()
    }
}

// MARK: - Backward Compatibility

// For accessing fontDirectoryPath from the manager
fileprivate extension LWFontManager {
    var fontDirectoryPath: String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = (documentsPath as NSString).appendingPathComponent("fonts")
        return path
    }
}
