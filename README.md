# LWDynamicFont

[![CI Status](https://img.shields.io/travis/luowei/LWDynamicFont.svg?style=flat)](https://travis-ci.org/luowei/LWDynamicFont)
[![Version](https://img.shields.io/cocoapods/v/LWDynamicFont.svg?style=flat)](https://cocoapods.org/pods/LWDynamicFont)
[![License](https://img.shields.io/cocoapods/l/LWDynamicFont.svg?style=flat)](https://cocoapods.org/pods/LWDynamicFont)
[![Platform](https://img.shields.io/cocoapods/p/LWDynamicFont.svg?style=flat)](https://cocoapods.org/pods/LWDynamicFont)

[English](./README.md) | [中文版](./README_ZH.md)

---

## Overview

**LWDynamicFont** is a powerful and flexible font manager for iOS applications that enables dynamic downloading and instant loading of custom fonts from remote servers. This library provides a comprehensive solution for font management, including downloading, registration, caching, and usage, allowing your app to dynamically utilize various custom fonts without the need to bundle all font files in your app package.

### Why LWDynamicFont?

- **Reduce App Size**: Keep your app lightweight by downloading fonts on-demand instead of bundling them
- **Flexible Font Management**: Easily add, update, or remove fonts without releasing a new app version
- **Better User Experience**: Load fonts dynamically based on user preferences or content requirements
- **Production Ready**: Battle-tested code with automatic font registration and intelligent fallback mechanisms

### Key Features

- **Dynamic Font Download**: Download TrueType (.ttf) and OpenType (.otf) fonts from custom servers
- **Apple System Fonts**: Download fonts from Apple's official font library
- **Automatic Font Registration**: Automatically register fonts after download for immediate use
- **Local Font Caching**: Downloaded fonts are cached locally to avoid re-downloading
- **Download Progress Tracking**: Real-time download progress callbacks for status display
- **Font Availability Check**: Built-in methods to check if fonts are available before use
- **Auto-load on Startup**: Automatically register all downloaded local fonts on app launch
- **Intelligent Fallback**: Method swizzling for automatic font loading and graceful fallback handling
- **Thread Safe**: All callbacks execute on the main thread for easy UI updates

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage Guide](#usage-guide)
- [API Documentation](#api-documentation)
- [How It Works](#how-it-works)
- [Important Notes](#important-notes)
- [Example Project](#example-project)
- [FAQ](#faq)
- [Contributing](#contributing)
- [License](#license)

## Requirements

- **iOS**: 8.0 or later
- **Xcode**: 8.0 or later
- **Language**: Objective-C
- **Frameworks**: UIKit, CoreText, Foundation

## Installation

LWDynamicFont can be installed using popular dependency managers for iOS.

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. To install LWDynamicFont, add the following line to your `Podfile`:

```ruby
pod 'LWDynamicFont'
```

Then, run the following command:

```bash
pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager. To install LWDynamicFont, add the following line to your `Cartfile`:

```ruby
github "luowei/LWDynamicFont"
```

Then run:

```bash
carthage update
```

### Manual Installation

If you prefer not to use dependency managers, you can integrate LWDynamicFont manually:

1. Download the source files from the [LWDynamicFont repository](https://github.com/luowei/LWDynamicFont)
2. Add the source files to your Xcode project
3. Import the necessary frameworks: `UIKit`, `CoreText`, `Foundation`

## Quick Start

Get up and running with LWDynamicFont in just a few steps:

### 1. Import the Framework

```objective-c
#import <LWDynamicFont/LWFontManager.h>
```

### 2. Initialize on App Launch

In your `AppDelegate.m`, register all previously downloaded fonts:

```objective-c
- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Register all custom local fonts
    [LWFontManager registerAllCustomLocalFonts];
    return YES;
}
```

### 3. Download and Use a Font

```objective-c
NSString *fontName = @"YuppySC-Regular";
NSString *fontURL = @"http://example.com/fonts/YuppySC-Regular.otf";

// Check if font is already available
if ([LWFontManager isAvaliableFont:fontName]) {
    // Use font directly
    self.label.font = [UIFont fontWithName:fontName size:18.0];
} else {
    // Download font
    [LWFontManager downloadCustomFontWithFontName:fontName
                                        URLString:fontURL
                                showProgressBlock:^{
                                    NSLog(@"Download started...");
                                }
                              updateProgressBlock:^(float progress) {
                                  NSLog(@"Progress: %.0f%%", progress * 100);
                              }
                                    completeBlock:^{
                                        NSLog(@"Download complete!");
                                        self.label.font = [UIFont fontWithName:fontName size:18.0];
                                    }];
}
```

That's it! You're now ready to use dynamic fonts in your iOS app.

---

## Usage Guide

This section provides detailed examples for common use cases.

### Checking Font Availability

Before using a font, it's recommended to check if it's available:

```objective-c
NSString *fontName = @"YuppySC-Regular";  // PostScript name of the font

if ([LWFontManager isAvaliableFont:fontName]) {
    // Font is available, use it directly
    UIFont *font = [UIFont fontWithName:fontName size:18.0];
} else {
    // Font is not available, need to download
}
```

### Downloading Custom Fonts

Download font files from a custom server:

```objective-c
NSString *fontName = @"YuppySC-Regular";  // PostScript name of the font
NSString *fontURL = @"http://example.com/fonts/YuppySC-Regular.otf";

// Download font and monitor progress
[LWFontManager downloadCustomFontWithFontName:fontName
                                    URLString:fontURL
                            showProgressBlock:^{
                                // Download started, show progress indicator
                                NSLog(@"Starting font download...");
                            }
                          updateProgressBlock:^(float progress) {
                              // Update download progress (0.0 ~ 1.0)
                              NSLog(@"Font download progress: %.2f%%", progress * 100);
                          }
                                completeBlock:^{
                                    // Download complete
                                    NSLog(@"Font download completed!");
                                    // Update UI with new font here
                                }];
```

### Downloading Apple Official Fonts

Download system fonts provided by Apple:

```objective-c
NSString *fontName = @"DIN Alternate";  // Apple font PostScript name

[LWFontManager downloadAppleFontWithFontName:fontName
                           showProgressBlock:^{
                               NSLog(@"Starting Apple font download...");
                           }
                         updateProgressBlock:^(float progress) {
                             NSLog(@"Download progress: %.2f%%", progress * 100);
                         }
                               completeBlock:^{
                                   NSLog(@"Apple font download completed!");
                               }];
```

### Using Downloaded Fonts

Once a font is downloaded and registered, you can use it in multiple ways:

#### Method 1: Direct Usage

```objective-c
NSString *fontName = @"YuppySC-Regular";

if ([LWFontManager isAvaliableFont:fontName]) {
    UIFont *font = [LWFontManager fontWithFontName:fontName size:20.0];
    label.font = font;
}
```

#### Method 2: Using Callbacks (Recommended)

This method provides better error handling and is recommended for production use:

```objective-c
NSString *fontName = @"YuppySC-Regular";

[LWFontManager useFontName:fontName
                      size:20.0
                  useBlock:^(UIFont *font) {
                      if (font) {
                          // Font is available, update UI
                          label.font = font;
                      } else {
                          // Font is not available
                          NSLog(@"Font %@ is not available", fontName);
                      }
                  }];
```

### Complete Implementation Example

Here's a comprehensive example demonstrating best practices for using LWDynamicFont:

```objective-c
#import <LWDynamicFont/LWFontManager.h>

@interface ViewController ()

@property (nonatomic, strong) UILabel *myLabel;
@property (nonatomic, strong) NSDictionary *fontURLMap;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Configure font URL mapping
    self.fontURLMap = @{
        @"YuppySC-Regular": @"http://oss.wodedata.com/Fonts/YuppySC.otf",
        @"STLiti": @"http://oss.wodedata.com/Fonts/STLiti.ttf",
        @"YouYuan": @"http://oss.wodedata.com/Fonts/YouYuan.ttf",
        @"MicrosoftYaHei": @"http://oss.wodedata.com/Fonts/MicrosoftYaHei.ttf"
    };

    // Create Label
    self.myLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 100, 300, 50)];
    self.myLabel.text = @"This is a test text";
    [self.view addSubview:self.myLabel];

    // Load and use font
    [self loadAndUseFontNamed:@"YuppySC-Regular"];
}

- (void)loadAndUseFontNamed:(NSString *)fontName {
    // Check if font is available
    if (![LWFontManager isAvaliableFont:fontName]) {
        // Font not available, start download
        NSString *fontURL = self.fontURLMap[fontName];

        [LWFontManager downloadCustomFontWithFontName:fontName
                                           URLString:fontURL
                                   showProgressBlock:^{
                                       // Show download indicator
                                       NSLog(@"Starting font download: %@", fontName);
                                   }
                                 updateProgressBlock:^(float progress) {
                                     // Update download progress
                                     NSLog(@"Download progress: %.2f%%", progress * 100);
                                 }
                                       completeBlock:^{
                                           // Download complete, use font
                                           NSLog(@"Font download completed");
                                           self.myLabel.font = [UIFont fontWithName:fontName size:24.0];
                                       }];
    } else {
        // Font is available, use it directly
        self.myLabel.font = [UIFont fontWithName:fontName size:24.0];
    }
}

@end
```

---

## API Documentation

### LWFontManager

The `LWFontManager` class is the core component of LWDynamicFont. It provides all necessary methods for font management.

#### Core Methods

##### Getting the Singleton Instance

```objective-c
+ (instancetype)shareInstance;
```

Returns the shared `LWFontManager` instance.

##### Checking Font Availability

```objective-c
+ (BOOL)isAvaliableFont:(NSString *)fontName;
```

Checks if a font is currently available for use.

**Parameters:**
- `fontName`: The PostScript name of the font

**Returns:** `YES` if the font is available, `NO` otherwise

##### Registering Local Fonts

```objective-c
+ (void)registerAllCustomLocalFonts;
```

Registers all previously downloaded local fonts. This method should be called in `application:didFinishLaunchingWithOptions:`.

#### Font Usage Methods

##### Creating Font Objects

```objective-c
+ (UIFont *)fontWithFontName:(NSString *)fontName size:(CGFloat)size;
```

Creates a `UIFont` object with the specified font name and size.

**Parameters:**
- `fontName`: The PostScript name of the font
- `size`: The font size in points

**Returns:** A `UIFont` object, or `nil` if the font is not available

##### Using Fonts with Callbacks

```objective-c
+ (void)useFontName:(NSString *)fontName
               size:(CGFloat)size
           useBlock:(void (^)(UIFont *font))useBlock;
```

Attempts to use a font with a callback block for error handling.

**Parameters:**
- `fontName`: The PostScript name of the font
- `size`: The font size in points
- `useBlock`: Callback block that receives the font object (or `nil` if unavailable)

#### Font Download Methods

##### Downloading Custom Fonts

```objective-c
+ (void)downloadCustomFontWithFontName:(NSString *)fontName
                            URLString:(NSString *)urlString
                    showProgressBlock:(void (^)(void))showProgressBlock
                  updateProgressBlock:(void (^)(float progress))progressBlock
                        completeBlock:(void (^)(void))completeBlock;
```

Downloads a custom font from a remote server.

**Parameters:**
- `fontName`: The PostScript name of the font (**Important:** NOT the filename)
- `urlString`: The download URL of the font file (.ttf or .otf)
- `showProgressBlock`: Callback invoked when download starts (optional)
- `progressBlock`: Progress callback with a float value from 0.0 to 1.0 (optional)
- `completeBlock`: Callback invoked when download completes successfully (optional)

**Notes:**
- All callbacks are executed on the main thread
- The font is automatically registered after successful download
- Previous downloads will be cancelled if a new download starts

##### Downloading Apple Fonts

```objective-c
+ (void)downloadAppleFontWithFontName:(NSString *)fontName
                    showProgressBlock:(void (^)(void))showProgressBlock
                  updateProgressBlock:(void (^)(float progress))progressBlock
                        completeBlock:(void (^)(void))completeBlock;
```

Downloads fonts from Apple's official font library using CoreText APIs.

**Parameters:**
- `fontName`: The PostScript name of the Apple font
- `showProgressBlock`: Callback invoked when download starts (optional)
- `progressBlock`: Progress callback with a float value from 0.0 to 1.0 (optional)
- `completeBlock`: Callback invoked when download completes successfully (optional)

#### File Management Methods

##### Removing Files

```objective-c
+ (BOOL)removeFileWithFilePath:(NSString *)filePath;
```

Deletes a file at the specified path.

**Parameters:**
- `filePath`: The absolute path to the file to delete

**Returns:** `YES` if successful, `NO` otherwise

##### Writing Data

```objective-c
+ (BOOL)writeData:(NSData *)data toFilePath:(NSString *)filePath;
```

Writes data to a file at the specified path.

**Parameters:**
- `data`: The data to write
- `filePath`: The absolute path where the file should be written

**Returns:** `YES` if successful, `NO` otherwise

##### Creating Directories

```objective-c
+ (BOOL)createDirectoryIfNotExsitPath:(NSString *)path;
```

Creates a directory if it doesn't already exist.

**Parameters:**
- `path`: The absolute path of the directory to create

**Returns:** `YES` if successful or directory already exists, `NO` otherwise

---

## How It Works

Understanding the internal architecture of LWDynamicFont can help you use it more effectively.

### Font Storage

**Custom Fonts:**
- Downloaded font files are stored in `Documents/fonts/` directory
- Files are persisted across app launches
- Storage path can be accessed via `[LWFontManager shareInstance].fontDirectoryPath`

**Apple Fonts:**
- Font path information is saved in `NSUserDefaults`
- Fonts are managed by iOS system after download

### Font Registration Process

LWDynamicFont uses CoreText framework for font registration:

1. **On App Launch**: Calls `CTFontManagerRegisterGraphicsFont` for all previously downloaded fonts
2. **After Download**: Immediately registers new fonts for instant availability
3. **Font Persistence**: Registration must be repeated on each app launch

```
App Launch → registerAllCustomLocalFonts() → Iterate font files →
CTFontManagerRegisterGraphicsFont → Fonts ready to use
```

### Method Swizzling Magic

LWDynamicFont enhances `UIFont`'s `fontWithName:size:` method using method swizzling:

**Enhanced Behavior:**
1. Check if font file exists locally but is not registered
2. If found, automatically register it before use
3. If font is unavailable, gracefully fall back to Helvetica
4. Seamless integration with existing `UIFont` APIs

This means you can use standard `[UIFont fontWithName:size:]` calls, and the library handles font loading automatically.

### Download Mechanisms

**Custom Fonts:**
- Uses `NSURLSession` for HTTP/HTTPS downloads
- Downloads to temporary location, then moves to permanent storage
- Supports progress tracking via delegate callbacks
- Automatic retry logic for failed downloads

**Apple Fonts:**
- Uses CoreText's `CTFontDescriptorMatchFontDescriptorsWithProgressHandler` API
- Leverages iOS system font download capabilities
- Progress reported through CoreText callbacks
- No network configuration required

---

## Important Notes

### Font Naming Convention

> **Critical**: All `fontName` parameters in the APIs must use the font's **PostScript name**, NOT the font filename.

**How to find the PostScript name:**

**Method 1: Using Font Book (Mac)**
1. Double-click the font file to open it in Font Book
2. Look for the "PostScript name" field in the font information

**Method 2: Programmatically**

```objective-c
// Print all font families
for (NSString *familyName in [UIFont familyNames]) {
    NSLog(@"Family: %@", familyName);

    // Print all fonts in this family
    for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
        NSLog(@"  Font: %@", fontName);
    }
}
```

**Example PostScript Names:**
- File: `Helvetica-Bold.ttf` → PostScript Name: `Helvetica-Bold`
- File: `YuppySC.otf` → PostScript Name: `YuppySC-Regular`

### Supported Font Formats

LWDynamicFont supports the following font file formats:

- **TrueType (.ttf)**: Industry-standard format, widely supported
- **OpenType (.otf)**: Modern format with advanced typography features

**Note:** Other formats (e.g., .woff, .eot) are not supported on iOS.

### App Restart Behavior

> **Important**: Font registration is not persistent across app launches. You must re-register fonts each time your app starts.

```objective-c
- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Re-register all local fonts
    [LWFontManager registerAllCustomLocalFonts];
    return YES;
}
```

### Network Configuration

**HTTPS Recommended:**
- Always use HTTPS URLs for security

**HTTP Support:**
If you need to use HTTP URLs, configure App Transport Security in your `Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

Or configure specific domains:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>example.com</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```

**Network Requirements:**
- Stable internet connection for downloads
- Server must support range requests for progress tracking
- Adequate bandwidth for large font files (2-20MB typical)

### Thread Safety

**Main Thread Execution:**
- All callbacks execute on the main thread
- UI updates can be performed directly in callbacks
- No need for `dispatch_async` to main queue

**Concurrent Downloads:**
- Only one font download at a time
- New download requests cancel previous incomplete downloads

---

## Example Project

The repository includes a comprehensive example application demonstrating all features of LWDynamicFont.

### Running the Example

**Step 1: Clone the Repository**
```bash
git clone https://github.com/luowei/LWDynamicFont.git
cd LWDynamicFont
```

**Step 2: Install Dependencies**
```bash
cd Example
pod install
```

**Step 3: Open and Run**
```bash
open LWDynamicFont.xcworkspace
```

Press `Cmd + R` to run the example app on the simulator or device.

### What the Example Demonstrates

The example project showcases:

- **Dynamic Font Download**: Download custom fonts from a remote server
- **Progress Tracking**: Real-time progress indicators during downloads
- **Instant Font Application**: Apply fonts immediately after download completes
- **Multiple Font Management**: Switch between different fonts dynamically
- **Error Handling**: Graceful handling of network errors and missing fonts
- **Best Practices**: Proper initialization and font management patterns

### Example Structure

```
Example/
├── LWDynamicFont/          # Example app code
│   ├── AppDelegate.m       # Font registration on launch
│   ├── ViewController.m    # Font download and usage demo
│   └── ...
├── Podfile                 # CocoaPods configuration
└── LWDynamicFont.xcworkspace
```

---

## FAQ

### Q: Why doesn't the label show the correct font after download?

**A:** Check these common issues:

1. **Verify PostScript Name**: Ensure you're using the font's PostScript name, NOT the filename
   ```objective-c
   // Wrong: filename
   [LWFontManager downloadCustomFontWithFontName:@"MyFont.ttf" ...];

   // Correct: PostScript name
   [LWFontManager downloadCustomFontWithFontName:@"MyFont-Regular" ...];
   ```

2. **Check Download Success**: Verify the font file downloaded successfully
   - Check `Documents/fonts/` directory in app container
   - Use Xcode's Device window to browse app files

3. **Update UI in Callback**: Ensure you're setting the font in the completion block
   ```objective-c
   completeBlock:^{
       self.label.font = [UIFont fontWithName:fontName size:18.0];
   }
   ```

### Q: How do I find my font's PostScript name?

**A:** Two methods:

**Method 1: Font Book (Mac)**
- Open font file in Font Book
- Check the "PostScript name" field

**Method 2: Code**

```objective-c
for (NSString *familyName in [UIFont familyNames]) {
    for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
        NSLog(@"PostScript name: %@", fontName);
    }
}
```

### Q: Can I download multiple fonts simultaneously?

**A:** No, LWDynamicFont currently supports downloading one font at a time.

If you start a new download before the previous one completes, the previous download will be cancelled automatically. This design prevents memory issues and ensures downloads complete reliably.

**Workaround:** Queue your downloads sequentially:
```objective-c
[self downloadFont:@"Font1" completion:^{
    [self downloadFont:@"Font2" completion:^{
        [self downloadFont:@"Font3" completion:nil];
    }];
}];
```

### Q: How much storage do downloaded fonts use?

**A:** Font file sizes vary significantly:

- **English/Latin fonts**: 1-5 MB typically
- **Chinese/Japanese/Korean fonts**: 10-20 MB (or more)
- **Full Unicode fonts**: 20+ MB

Chinese fonts are larger because they contain thousands of characters. Consider downloading only the fonts you need to minimize storage usage.

### Q: How do I delete downloaded fonts?

**A:** Use the file management methods:

```objective-c
// Get font directory path
NSString *fontPath = [LWFontManager shareInstance].fontDirectoryPath;

// Construct full path to font file
NSString *fontFilePath = [fontPath stringByAppendingPathComponent:@"YuppySC-Regular.otf"];

// Delete the font file
BOOL success = [LWFontManager removeFileWithFilePath:fontFilePath];
if (success) {
    NSLog(@"Font deleted successfully");
}
```

**Note:** Deleting a font file doesn't unregister it from the current app session. The font will remain available until the app restarts.

### Q: Do fonts work offline after downloading?

**A:** Yes! Once downloaded, fonts are cached locally and work completely offline. The fonts persist across app launches and device restarts.

### Q: Can I use LWDynamicFont with Swift?

**A:** Yes! LWDynamicFont is Objective-C based but fully compatible with Swift projects:

```swift
import LWDynamicFont

// Check font availability
if LWFontManager.isAvaliableFont("YuppySC-Regular") {
    let font = UIFont(name: "YuppySC-Regular", size: 18.0)
}

// Download font
LWFontManager.downloadCustomFont(
    withFontName: "YuppySC-Regular",
    urlString: "https://example.com/fonts/YuppySC.otf",
    showProgressBlock: {
        print("Download started")
    },
    updateProgressBlock: { progress in
        print("Progress: \(progress * 100)%")
    },
    completeBlock: {
        print("Download complete")
    }
)
```

---

## Version History

### Version 1.0.0
- Initial public release
- Dynamic custom font download from remote servers
- Apple official font download support
- Automatic font registration and caching
- Download progress tracking with callbacks
- Method swizzling for automatic font loading
- Comprehensive example project

---

## Contributing

Contributions are welcome and appreciated! Here's how you can help:

### Reporting Issues

If you find a bug or have a feature request:

1. Check if the issue already exists in [GitHub Issues](https://github.com/luowei/LWDynamicFont/issues)
2. If not, create a new issue with:
   - Clear description of the problem/feature
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - iOS version and device information

### Pull Requests

To contribute code:

1. **Fork** the repository
2. **Create** a feature branch:
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Make** your changes and commit:
   ```bash
   git commit -m 'Add some amazing feature'
   ```
4. **Push** to your fork:
   ```bash
   git push origin feature/amazing-feature
   ```
5. **Open** a Pull Request with:
   - Description of changes
   - Reference to related issues
   - Any breaking changes noted

### Code Style

- Follow existing Objective-C coding conventions
- Add comments for complex logic
- Update documentation for API changes
- Include tests when applicable

---

## License

LWDynamicFont is released under the **MIT License**.

```
MIT License

Copyright (c) 2025 luowei

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

See the [LICENSE](LICENSE) file for full details.

---

## Author

**luowei**
- Email: [luowei@wodedata.com](mailto:luowei@wodedata.com)
- GitHub: [@luowei](https://github.com/luowei)

---

## Resources

### Documentation
- [CocoaPods Documentation](https://cocoapods.org)
- [CoreText Programming Guide](https://developer.apple.com/library/archive/documentation/StringsTextFonts/Conceptual/CoreText_Programming/Introduction/Introduction.html)
- [Apple Font Download Sample](https://developer.apple.com/library/ios/samplecode/DownloadFont/Introduction/Intro.html)

### Related Projects
- [FontBlaster](https://github.com/ArtSabintsev/FontBlaster) - Programmatically load custom fonts
- [SwiftGen](https://github.com/SwiftGen/SwiftGen) - Generate type-safe font accessors

### Articles
- [Using Custom Fonts in iOS](http://blog.devzeng.com/blog/using-custom-font-in-ios.html)
- [CoreText Best Practices](https://developer.apple.com/fonts/)

---

## Acknowledgments

Special thanks to:

- All contributors who have helped improve this library
- The iOS developer community for feedback and suggestions
- Apple for providing the CoreText framework

---

<div align="center">

**If LWDynamicFont helps your project, please consider giving it a star!** ⭐

Made with ❤️ by [luowei](https://github.com/luowei)

[Report Bug](https://github.com/luowei/LWDynamicFont/issues) · [Request Feature](https://github.com/luowei/LWDynamicFont/issues) · [Documentation](https://github.com/luowei/LWDynamicFont)

</div>
