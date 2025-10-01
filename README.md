# LWDynamicFont

[![CI Status](https://img.shields.io/travis/luowei/LWDynamicFont.svg?style=flat)](https://travis-ci.org/luowei/LWDynamicFont)
[![Version](https://img.shields.io/cocoapods/v/LWDynamicFont.svg?style=flat)](https://cocoapods.org/pods/LWDynamicFont)
[![License](https://img.shields.io/cocoapods/l/LWDynamicFont.svg?style=flat)](https://cocoapods.org/pods/LWDynamicFont)
[![Platform](https://img.shields.io/cocoapods/p/LWDynamicFont.svg?style=flat)](https://cocoapods.org/pods/LWDynamicFont)

[中文文档](README_ZH.md)

## Introduction

LWDynamicFont is a powerful font manager for iOS that enables dynamic downloading and instant loading of custom fonts from remote servers. This library provides complete functionality for font downloading, registration, loading, and usage, allowing your app to dynamically use various custom fonts without bundling all font files in the app package.

### Key Features

- ✅ **Dynamic Font Download**: Download TrueType (.ttf) and OpenType (.otf) fonts from custom servers
- ✅ **Apple System Fonts**: Download fonts from Apple's official font library
- ✅ **Automatic Font Registration**: Automatically register fonts after download for immediate use
- ✅ **Local Font Caching**: Downloaded fonts are cached locally to avoid re-downloading
- ✅ **Download Progress Tracking**: Provides download progress callbacks for status display
- ✅ **Font Availability Check**: Methods to check if fonts are available
- ✅ **Auto-load on Startup**: Automatically register all downloaded local fonts on app launch
- ✅ **Method Swizzling**: Implements automatic font loading and fallback handling through method swizzling

## Requirements

- iOS 8.0 or later
- Xcode 8.0 or later
- Objective-C

## Installation

### CocoaPods

LWDynamicFont is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'LWDynamicFont'
```

Then run:

```bash
pod install
```

### Carthage

To install using [Carthage](https://github.com/Carthage/Carthage), add this to your Cartfile:

```ruby
github "luowei/LWDynamicFont"
```

## Usage

### 1. Import the Header

```objective-c
#import <LWDynamicFont/LWFontManager.h>
```

### 2. Register Local Fonts on App Launch

Register all downloaded local fonts when the app starts (in `application:didFinishLaunchingWithOptions:`):

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Register all custom local fonts
    [LWFontManager registerAllCustomLocalFonts];

    return YES;
}
```

### 3. Check Font Availability

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

### 4. Download Custom Fonts

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

### 5. Download Apple Official Fonts

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

### 6. Using Fonts

#### Method 1: Direct Use

```objective-c
NSString *fontName = @"YuppySC-Regular";

if ([LWFontManager isAvaliableFont:fontName]) {
    UIFont *font = [LWFontManager fontWithFontName:fontName size:20.0];
    label.font = font;
}
```

#### Method 2: Using Callbacks (Recommended)

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

### 7. Complete Example

Here's a complete usage example:

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

## Core API Documentation

### LWFontManager Class Methods

#### Font Management

```objective-c
// Get singleton instance
+ (instancetype)shareInstance;

// Check if font is available (parameter is font's PostScript name)
+ (BOOL)isAvaliableFont:(NSString *)fontName;

// Register all downloaded local fonts (recommended to call on app launch)
+ (void)registerAllCustomLocalFonts;
```

#### Font Usage

```objective-c
// Create UIFont object from font name and size
+ (UIFont *)fontWithFontName:(NSString *)fontName size:(CGFloat)size;

// Use font with callback
+ (void)useFontName:(NSString *)fontName
               size:(CGFloat)size
           useBlock:(void (^)(UIFont *font))useBlock;
```

#### Download Custom Fonts

```objective-c
// Download font from custom server
+ (void)downloadCustomFontWithFontName:(NSString *)fontName
                            URLString:(NSString *)urlString
                    showProgressBlock:(void (^)(void))showProgressBlock
                  updateProgressBlock:(void (^)(float progress))progressBlock
                        completeBlock:(void (^)(void))completeBlock;
```

**Parameters:**
- `fontName`: PostScript name of the font (Important: NOT the filename)
- `urlString`: Download URL of the font file
- `showProgressBlock`: Callback when download starts
- `progressBlock`: Download progress callback, progress range is 0.0 ~ 1.0
- `completeBlock`: Callback when download completes

#### Download Apple Fonts

```objective-c
// Download fonts provided by Apple
+ (void)downloadAppleFontWithFontName:(NSString *)fontName
                    showProgressBlock:(void (^)(void))showProgressBlock
                  updateProgressBlock:(void (^)(float progress))progressBlock
                        completeBlock:(void (^)(void))completeBlock;
```

#### File Operations

```objective-c
// Delete file at specified path
+ (BOOL)removeFileWithFilePath:(NSString *)filePath;

// Write data to specified path
+ (BOOL)writeData:(NSData *)data toFilePath:(NSString *)filePath;

// Create directory if it doesn't exist
+ (BOOL)createDirectoryIfNotExsitPath:(NSString *)path;
```

## How It Works

### 1. Font Storage

- Downloaded font files are stored in the app's Documents/fonts directory
- Apple font path information is saved in NSUserDefaults

### 2. Font Registration

- Uses CoreText framework's `CTFontManagerRegisterGraphicsFont` method to register fonts
- Automatically registers all downloaded local fonts on app launch
- Custom fonts are registered immediately after download

### 3. Method Swizzling

The library uses method swizzling to enhance UIFont's `fontWithName:size:` method:
- Automatically checks if font file exists when using a font
- If font file exists but is not registered, automatically registers it before use
- If font is not available, automatically falls back to Helvetica font

### 4. Download Mechanism

- **Custom Fonts**: Uses NSURLSession to download font files to local storage
- **Apple Fonts**: Uses CoreText's `CTFontDescriptorMatchFontDescriptorsWithProgressHandler` API

## Important Notes

### Font Naming

⚠️ **Important**: All `fontName` parameters in the APIs must use the font's **PostScript name**, NOT the font filename.

How to get the PostScript name of a font:
1. Double-click the font file on Mac and open with Font Book app
2. Check the "PostScript name" field in the font information
3. Or use the following code to print all available fonts:

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

### Font File Formats

Supported font formats:
- TrueType (.ttf)
- OpenType (.otf)

### Font Loading After App Restart

Registered fonts need to be re-registered after app restart to be available. Therefore, you must call `registerAllCustomLocalFonts` on app launch:

```objective-c
- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Re-register all local fonts
    [LWFontManager registerAllCustomLocalFonts];
    return YES;
}
```

### Network Requirements for Font Download

- Ensure font file URL is accessible
- HTTPS protocol is recommended
- If using HTTP, configure App Transport Security in Info.plist

### Thread Safety

- All callbacks are executed on the main thread
- UI updates can be performed directly in callbacks

## Example Project

The project includes a complete example app demonstrating how to use LWDynamicFont:

1. Clone the repository:
```bash
git clone https://github.com/luowei/LWDynamicFont.git
```

2. Enter the Example directory and install dependencies:
```bash
cd LWDynamicFont/Example
pod install
```

3. Open the workspace:
```bash
open LWDynamicFont.xcworkspace
```

4. Run the example project to see it in action

The example project demonstrates:
- Dynamic font downloading
- Download progress display
- Instant application of fonts after download
- Managing and switching between multiple fonts

## FAQ

### Q1: Why doesn't the label show the correct font after download completes?

A: Please check the following:
1. Confirm you're using the font's PostScript name, not the filename
2. Check if the font file downloaded successfully (check Documents/fonts directory)
3. Confirm you set the label's font property in the download completion callback

### Q2: How do I find my font file's PostScript name?

A: Method 1: Use Mac's Font Book app to view; Method 2: Use the following code to iterate all registered fonts:

```objective-c
for (NSString *familyName in [UIFont familyNames]) {
    for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
        NSLog(@"%@", fontName);  // This is the PostScript name
    }
}
```

### Q3: Can multiple fonts be downloaded simultaneously?

A: The current version only supports downloading one font at a time. If you start downloading a new font before the previous one completes, the previous download task will be cancelled.

### Q4: How much storage space will downloaded fonts occupy?

A: Font file sizes vary, typically between 2MB ~ 20MB. Chinese fonts are usually larger because they contain many characters.

### Q5: How do I delete downloaded fonts?

A: Use the following method to delete font files:

```objective-c
NSString *fontPath = [LWFontManager shareInstance].fontDirectoryPath;
NSString *fontFilePath = [fontPath stringByAppendingPathComponent:@"fontFileName"];
[LWFontManager removeFileWithFilePath:fontFilePath];
```

## Version History

### 1.0.0
- Initial release
- Support for custom font dynamic download
- Support for Apple official font download
- Automatic font registration
- Download progress tracking

## Author

**luowei** - [luowei@wodedata.com](mailto:luowei@wodedata.com)

## License

LWDynamicFont is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Contributing

Issues and Pull Requests are welcome!

1. Fork this repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Related Resources

- [CocoaPods Official Documentation](https://cocoapods.org)
- [CoreText Programming Guide](https://developer.apple.com/library/archive/documentation/StringsTextFonts/Conceptual/CoreText_Programming/Introduction/Introduction.html)
- [Apple Dynamic Font Download Sample](https://developer.apple.com/library/ios/samplecode/DownloadFont/Introduction/Intro.html)
- [iOS Custom Font Usage Guide](http://blog.devzeng.com/blog/using-custom-font-in-ios.html)

## Acknowledgments

Thanks to all developers who contributed to this project!
