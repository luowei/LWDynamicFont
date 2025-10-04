//
// Font+LWDynamicFont.swift
// Created by Luo Wei on 2017/10/27.
// Copyright (c) 2017 wodedata. All rights reserved.
//
// SwiftUI Font extension for LWDynamicFont

import SwiftUI

// MARK: - Font Extension for SwiftUI

@available(iOS 13.0, *)
public extension Font {

    /// Create a custom dynamic font with the specified name and size
    /// - Parameters:
    ///   - fontName: The PostScript name of the font
    ///   - size: The point size of the font
    /// - Returns: A Font instance, or system font if the custom font is not available
    static func dynamicFont(name fontName: String, size: CGFloat) -> Font {
        if LWFontManager.isAvailable(fontName: fontName) {
            return Font.custom(fontName, size: size)
        }
        // Fallback to system font
        return Font.system(size: size)
    }

    /// Create a custom dynamic font with relative sizing
    /// - Parameters:
    ///   - fontName: The PostScript name of the font
    ///   - size: The point size of the font
    ///   - relativeTo: The text style to scale relative to
    /// - Returns: A Font instance, or system font if the custom font is not available
    static func dynamicFont(name fontName: String, size: CGFloat, relativeTo textStyle: Font.TextStyle) -> Font {
        if LWFontManager.isAvailable(fontName: fontName) {
            return Font.custom(fontName, size: size, relativeTo: textStyle)
        }
        // Fallback to system font
        return Font.system(size: size)
    }

    /// Create a custom dynamic font with fixed size
    /// - Parameters:
    ///   - fontName: The PostScript name of the font
    ///   - fixedSize: The fixed point size of the font
    /// - Returns: A Font instance, or system font if the custom font is not available
    static func dynamicFont(name fontName: String, fixedSize: CGFloat) -> Font {
        if LWFontManager.isAvailable(fontName: fontName) {
            return Font.custom(fontName, fixedSize: fixedSize)
        }
        // Fallback to system font
        return Font.system(size: fixedSize)
    }
}

// MARK: - Dynamic Font View Modifier

@available(iOS 13.0, *)
public struct DynamicFontModifier: ViewModifier {
    let fontName: String
    let size: CGFloat

    public func body(content: Content) -> some View {
        content
            .font(.dynamicFont(name: fontName, size: size))
    }
}

@available(iOS 13.0, *)
public extension View {
    /// Apply a dynamic font to the view
    /// - Parameters:
    ///   - fontName: The PostScript name of the font
    ///   - size: The point size of the font
    /// - Returns: A view with the dynamic font applied
    func dynamicFont(name fontName: String, size: CGFloat) -> some View {
        modifier(DynamicFontModifier(fontName: fontName, size: size))
    }
}

// MARK: - Font Download Observer

@available(iOS 13.0, *)
public class FontDownloadObserver: ObservableObject {
    @Published public var isDownloading: Bool = false
    @Published public var progress: Float = 0.0
    @Published public var isComplete: Bool = false
    @Published public var currentFont: Font?

    public init() {}

    /// Download a custom font from URL
    /// - Parameters:
    ///   - fontName: The PostScript name of the font
    ///   - urlString: The URL string to download the font from
    ///   - size: The desired font size
    public func downloadCustomFont(fontName: String, urlString: String, size: CGFloat) {
        LWFontManager.downloadCustomFont(
            fontName: fontName,
            urlString: urlString,
            showProgressBlock: { [weak self] in
                self?.isDownloading = true
            },
            updateProgressBlock: { [weak self] progress in
                self?.progress = progress
            },
            completeBlock: { [weak self] in
                self?.isDownloading = false
                self?.isComplete = true
                self?.currentFont = .dynamicFont(name: fontName, size: size)
            }
        )
    }

    /// Download an Apple-provided font
    /// - Parameters:
    ///   - fontName: The PostScript name of the font
    ///   - size: The desired font size
    public func downloadAppleFont(fontName: String, size: CGFloat) {
        LWFontManager.downloadAppleFont(
            fontName: fontName,
            showProgressBlock: { [weak self] in
                self?.isDownloading = true
            },
            updateProgressBlock: { [weak self] progress in
                self?.progress = progress
            },
            completeBlock: { [weak self] in
                self?.isDownloading = false
                self?.isComplete = true
                self?.currentFont = .dynamicFont(name: fontName, size: size)
            }
        )
    }
}
