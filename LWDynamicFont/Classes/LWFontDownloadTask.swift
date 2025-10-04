//
// LWFontDownloadTask.swift
// Created by Luo Wei on 2017/10/27.
// Copyright (c) 2017 wodedata. All rights reserved.
//
// Swift/SwiftUI version of LWFontDownloadTask

import Foundation

// MARK: - LWFontDownloadTask

public class LWFontDownloadTask: NSObject {

    // MARK: - Properties

    public var fontName: String
    public var taskIdentifier: Int
    public var dataTask: URLSessionDataTask

    public var progress: Float = 0.0
    public var downloadSize: Int64 = 0
    public var dataToDownload: Data = Data()

    // MARK: - Initialization

    public init(identifier: Int, fontName: String, dataTask: URLSessionDataTask) {
        self.taskIdentifier = identifier
        self.fontName = fontName
        self.dataTask = dataTask
        super.init()
    }
}
