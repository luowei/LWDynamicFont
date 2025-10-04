# LWDynamicFont Swift Version

This document describes how to use the Swift/SwiftUI version of LWDynamicFont.

## Overview

LWDynamicFont_swift is a modern Swift/SwiftUI implementation of the LWDynamicFont library. It provides a comprehensive solution for downloading, managing, and using custom fonts dynamically in iOS applications with full support for SwiftUI, async/await, and Combine framework.

## Requirements

- iOS 14.0+
- Swift 5.0+
- Xcode 12.0+

## Installation

### CocoaPods

Add the following line to your Podfile:

```ruby
pod 'LWDynamicFont_swift'
```

Then run:
```bash
pod install
```

## Key Features

- **Dynamic Font Loading** - Download fonts from remote servers at runtime
- **Font Management** - Centralized font registration and caching
- **SwiftUI Support** - Native SwiftUI Font extension
- **UIKit Support** - UIFont extension for UIKit apps
- **Async/Await** - Modern asynchronous font loading
- **Combine Integration** - Reactive font download progress
- **Font Caching** - Automatic font persistence and reuse
- **Progress Tracking** - Monitor download progress
- **Error Handling** - Comprehensive error handling and fallbacks
- **Type Safe** - Full Swift type safety

## Quick Start

### Download and Use a Font

```swift
import SwiftUI
import LWDynamicFont_swift

struct ContentView: View {
    @State private var customFont: Font?

    var body: some View {
        Text("Hello, World!")
            .font(customFont ?? .body)
            .task {
                await loadCustomFont()
            }
    }

    func loadCustomFont() async {
        do {
            let fontURL = URL(string: "https://example.com/fonts/CustomFont.ttf")!
            let font = try await LWFontManager.shared.downloadAndRegisterFont(
                from: fontURL,
                fontName: "CustomFont-Regular",
                size: 20
            )
            customFont = font
        } catch {
            print("Failed to load font: \(error)")
        }
    }
}
```

### Using UIFont Extension

```swift
import UIKit
import LWDynamicFont_swift

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        Task {
            let fontURL = URL(string: "https://example.com/fonts/MyFont.ttf")!

            do {
                let font = try await UIFont.dynamicFont(
                    from: fontURL,
                    name: "MyFont-Bold",
                    size: 18
                )
                label.font = font
            } catch {
                print("Font loading failed: \(error)")
            }
        }
    }
}
```

### Font Manager with Progress Tracking

```swift
import SwiftUI
import LWDynamicFont_swift

struct FontDownloadView: View {
    @StateObject private var fontManager = LWFontManager.shared
    @State private var downloadProgress: Double = 0
    @State private var loadedFont: Font?

    var body: some View {
        VStack(spacing: 20) {
            if let font = loadedFont {
                Text("Font Loaded!")
                    .font(font)
            } else {
                ProgressView(value: downloadProgress, total: 1.0)
                    .padding()

                Text("Downloading: \(Int(downloadProgress * 100))%")
            }

            Button("Download Font") {
                Task {
                    await downloadFont()
                }
            }
        }
    }

    func downloadFont() async {
        let fontURL = URL(string: "https://example.com/fonts/CustomFont.ttf")!

        do {
            let font = try await fontManager.downloadFont(
                from: fontURL,
                fontName: "CustomFont",
                size: 24
            ) { progress in
                downloadProgress = progress
            }
            loadedFont = font
        } catch {
            print("Download failed: \(error)")
        }
    }
}
```

## Advanced Usage

### Font Manager

```swift
import LWDynamicFont_swift

class FontService: ObservableObject {
    private let manager = LWFontManager.shared
    @Published var availableFonts: [String] = []
    @Published var isLoading = false

    func downloadFont(url: URL, name: String) async throws -> Font {
        isLoading = true
        defer { isLoading = false }

        return try await manager.downloadAndRegisterFont(
            from: url,
            fontName: name,
            size: 16
        )
    }

    func checkFontAvailability(_ fontName: String) -> Bool {
        return manager.isFontRegistered(fontName)
    }

    func loadCachedFont(_ name: String, size: CGFloat) -> Font? {
        guard manager.isFontRegistered(name) else { return nil }
        return Font.custom(name, size: size)
    }

    func clearFontCache() {
        manager.clearCache()
    }
}
```

### Download Multiple Fonts

```swift
struct MultiFontLoader {
    let fontManager = LWFontManager.shared

    func loadAllFonts() async {
        let fontURLs = [
            (URL(string: "https://example.com/font1.ttf")!, "Font1-Regular"),
            (URL(string: "https://example.com/font2.ttf")!, "Font2-Bold"),
            (URL(string: "https://example.com/font3.ttf")!, "Font3-Italic")
        ]

        await withTaskGroup(of: Void.self) { group in
            for (url, name) in fontURLs {
                group.addTask {
                    do {
                        _ = try await self.fontManager.downloadAndRegisterFont(
                            from: url,
                            fontName: name,
                            size: 16
                        )
                        print("Loaded: \(name)")
                    } catch {
                        print("Failed to load \(name): \(error)")
                    }
                }
            }
        }
    }
}
```

### Custom Font Download with Progress

```swift
class FontDownloadTask: ObservableObject {
    @Published var progress: Double = 0
    @Published var status: DownloadStatus = .idle

    enum DownloadStatus {
        case idle
        case downloading
        case completed
        case failed(Error)
    }

    func download(from url: URL, fontName: String) async {
        status = .downloading

        do {
            let task = LWFontDownloadTask(url: url, fontName: fontName)

            for await progress in task.progressStream() {
                self.progress = progress
            }

            let font = try await task.execute()
            status = .completed
        } catch {
            status = .failed(error)
        }
    }
}

// Usage in SwiftUI
struct FontDownloadProgressView: View {
    @StateObject private var downloadTask = FontDownloadTask()

    var body: some View {
        VStack {
            switch downloadTask.status {
            case .idle:
                Button("Start Download") {
                    Task {
                        await downloadTask.download(
                            from: fontURL,
                            fontName: "CustomFont"
                        )
                    }
                }

            case .downloading:
                ProgressView(value: downloadTask.progress)
                Text("\(Int(downloadTask.progress * 100))%")

            case .completed:
                Text("Download Complete!")
                    .foregroundColor(.green)

            case .failed(let error):
                Text("Failed: \(error.localizedDescription)")
                    .foregroundColor(.red)
            }
        }
    }
}
```

### Font Caching and Persistence

```swift
class FontCacheManager {
    private let manager = LWFontManager.shared
    private let userDefaults = UserDefaults.standard

    func saveFontInfo(_ fontName: String, url: String) {
        var fonts = loadedFonts
        fonts[fontName] = url
        userDefaults.set(fonts, forKey: "LoadedFonts")
    }

    func restoreFonts() async {
        let fonts = loadedFonts

        for (name, urlString) in fonts {
            guard let url = URL(string: urlString) else { continue }

            if !manager.isFontRegistered(name) {
                try? await manager.downloadAndRegisterFont(
                    from: url,
                    fontName: name,
                    size: 16
                )
            }
        }
    }

    private var loadedFonts: [String: String] {
        userDefaults.dictionary(forKey: "LoadedFonts") as? [String: String] ?? [:]
    }
}
```

## SwiftUI-Specific Features

### Font Modifier

```swift
extension View {
    func dynamicFont(
        url: URL,
        name: String,
        size: CGFloat,
        fallback: Font = .body
    ) -> some View {
        modifier(DynamicFontModifier(
            url: url,
            name: name,
            size: size,
            fallback: fallback
        ))
    }
}

struct DynamicFontModifier: ViewModifier {
    let url: URL
    let name: String
    let size: CGFloat
    let fallback: Font

    @State private var loadedFont: Font?

    func body(content: Content) -> some View {
        content
            .font(loadedFont ?? fallback)
            .task {
                loadedFont = try? await LWFontManager.shared.downloadAndRegisterFont(
                    from: url,
                    fontName: name,
                    size: size
                )
            }
    }
}

// Usage
Text("Custom Font Text")
    .dynamicFont(
        url: URL(string: "https://example.com/font.ttf")!,
        name: "MyFont",
        size: 20
    )
```

### Font Picker View

```swift
struct FontPickerView: View {
    @State private var selectedFont: String?
    @State private var availableFonts: [(name: String, url: URL)] = []

    var body: some View {
        List(availableFonts, id: \.name) { fontInfo in
            Button(action: {
                selectedFont = fontInfo.name
            }) {
                Text(fontInfo.name)
                    .font(selectedFont == fontInfo.name
                        ? .custom(fontInfo.name, size: 18)
                        : .body)
            }
        }
        .task {
            await loadFonts()
        }
    }

    func loadFonts() async {
        // Load fonts from server or config
        for fontInfo in availableFonts {
            try? await LWFontManager.shared.downloadAndRegisterFont(
                from: fontInfo.url,
                fontName: fontInfo.name,
                size: 18
            )
        }
    }
}
```

## API Reference

### LWFontManager

```swift
class LWFontManager {
    static let shared: LWFontManager

    func downloadAndRegisterFont(
        from url: URL,
        fontName: String,
        size: CGFloat
    ) async throws -> Font

    func downloadFont(
        from url: URL,
        fontName: String,
        size: CGFloat,
        progressHandler: ((Double) -> Void)?
    ) async throws -> Font

    func isFontRegistered(_ fontName: String) -> Bool
    func registerFont(at path: URL, name: String) throws
    func clearCache()
}
```

### Font Extension

```swift
extension Font {
    static func dynamicFont(
        from url: URL,
        name: String,
        size: CGFloat
    ) async throws -> Font
}
```

### UIFont Extension

```swift
extension UIFont {
    static func dynamicFont(
        from url: URL,
        name: String,
        size: CGFloat
    ) async throws -> UIFont

    static func registerDynamicFont(at path: URL) throws -> String
}
```

### LWFontDownloadTask

```swift
class LWFontDownloadTask {
    let url: URL
    let fontName: String

    init(url: URL, fontName: String)

    func execute() async throws -> Font
    func progressStream() -> AsyncStream<Double>
    func cancel()
}
```

## Best Practices

### 1. Cache Downloaded Fonts

```swift
// Good - Check cache first
func loadFont(name: String, url: URL) async -> Font {
    if fontManager.isFontRegistered(name) {
        return Font.custom(name, size: 16)
    }
    return try! await fontManager.downloadAndRegisterFont(
        from: url,
        fontName: name,
        size: 16
    )
}
```

### 2. Handle Errors Gracefully

```swift
// Always provide fallback
func loadFontSafely(url: URL, name: String) async -> Font {
    do {
        return try await fontManager.downloadAndRegisterFont(
            from: url,
            fontName: name,
            size: 16
        )
    } catch {
        print("Font load failed: \(error)")
        return .body // Fallback to system font
    }
}
```

### 3. Preload Fonts

```swift
// Preload fonts on app launch
class AppDelegate {
    func application(_ application: UIApplication, ...) -> Bool {
        Task {
            await preloadFonts()
        }
        return true
    }

    func preloadFonts() async {
        let fonts = [
            ("CustomFont1", URL(string: "...")!),
            ("CustomFont2", URL(string: "...")!)
        ]

        for (name, url) in fonts {
            try? await LWFontManager.shared.downloadAndRegisterFont(
                from: url,
                fontName: name,
                size: 16
            )
        }
    }
}
```

### 4. Monitor Network Conditions

```swift
import Network

class FontDownloader: ObservableObject {
    private let monitor = NWPathMonitor()
    @Published var isConnected = true

    func downloadFont(url: URL) async throws -> Font {
        guard isConnected else {
            throw FontError.noConnection
        }

        return try await LWFontManager.shared.downloadAndRegisterFont(
            from: url,
            fontName: "CustomFont",
            size: 16
        )
    }
}
```

## Migration from Objective-C Version

### Before (Objective-C)
```objective-c
[LWDynamicFont downloadFontFromURL:fontURL
                       fontName:@"CustomFont"
                     completion:^(UIFont *font, NSError *error) {
    if (font) {
        self.label.font = font;
    }
}];
```

### After (Swift)
```swift
Task {
    let font = try await UIFont.dynamicFont(
        from: fontURL,
        name: "CustomFont",
        size: 18
    )
    label.font = font
}
```

## Error Handling

### Common Errors

```swift
enum FontError: Error {
    case downloadFailed
    case invalidFontData
    case registrationFailed
    case fontNotFound
    case noConnection
}

// Handle errors
do {
    let font = try await fontManager.downloadAndRegisterFont(...)
} catch FontError.downloadFailed {
    print("Download failed")
} catch FontError.registrationFailed {
    print("Could not register font")
} catch {
    print("Unknown error: \(error)")
}
```

## Troubleshooting

**Q: Font not displaying**
- Verify font name matches the actual font family name
- Check if font file format is supported (.ttf, .otf)
- Ensure font is properly registered

**Q: Download fails**
- Check network connectivity
- Verify URL is valid and accessible
- Check file permissions

**Q: Font looks incorrect**
- Verify correct font variant (Regular, Bold, Italic)
- Check font size is appropriate
- Ensure font file is not corrupted

**Q: Memory issues with multiple fonts**
- Clear unused fonts from cache
- Limit number of simultaneously loaded fonts
- Use font lazy loading

## Performance Tips

1. **Preload Common Fonts** - Load frequently used fonts at app launch
2. **Cache Aggressively** - Store downloaded fonts locally
3. **Async Loading** - Always load fonts asynchronously
4. **Monitor Memory** - Clear unused fonts from cache
5. **Font Subsetting** - Use font subsets for smaller file sizes

## Examples

Complete working examples can be found in the example project:

```bash
cd LWDynamicFont/Example
pod install
open LWDynamicFont.xcworkspace
```

Examples include:
- Basic font download
- Progress tracking
- Multiple font management
- SwiftUI integration
- Error handling

## License

LWDynamicFont_swift is available under the MIT license. See the LICENSE file for more information.

## Author

**luowei**
- Email: luowei@wodedata.com
- GitHub: [@luowei](https://github.com/luowei)
