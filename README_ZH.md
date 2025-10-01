# LWDynamicFont

[![CI Status](https://img.shields.io/travis/luowei/LWDynamicFont.svg?style=flat)](https://travis-ci.org/luowei/LWDynamicFont)
[![Version](https://img.shields.io/cocoapods/v/LWDynamicFont.svg?style=flat)](https://cocoapods.org/pods/LWDynamicFont)
[![License](https://img.shields.io/cocoapods/l/LWDynamicFont.svg?style=flat)](https://cocoapods.org/pods/LWDynamicFont)
[![Platform](https://img.shields.io/cocoapods/p/LWDynamicFont.svg?style=flat)](https://cocoapods.org/pods/LWDynamicFont)

## 简介

LWDynamicFont 是一个支持从服务器端动态下载字体并即时加载到 iOS 应用中的字体管理器。该库提供了完整的字体下载、注册、加载和使用功能，让你的应用可以动态地使用各种自定义字体，无需将所有字体文件打包到应用中。

### 主要特性

- ✅ **动态下载字体**：支持从自定义服务器下载 TrueType (.ttf) 和 OpenType (.otf) 字体文件
- ✅ **Apple 系统字体下载**：支持下载 Apple 官方提供的字体库
- ✅ **字体自动注册**：下载完成后自动注册字体，即时可用
- ✅ **本地字体缓存**：已下载的字体会缓存到本地，避免重复下载
- ✅ **下载进度跟踪**：提供下载进度回调，方便展示下载状态
- ✅ **字体可用性检查**：提供字体是否可用的检查方法
- ✅ **应用启动自动加载**：应用启动时自动注册所有已下载的本地字体
- ✅ **Method Swizzling**：通过方法交换实现字体的自动加载和降级处理

## 系统要求

- iOS 8.0 或更高版本
- Xcode 8.0 或更高版本
- Objective-C

## 安装

### CocoaPods

LWDynamicFont 可通过 [CocoaPods](https://cocoapods.org) 安装。只需在你的 Podfile 中添加以下内容：

```ruby
pod 'LWDynamicFont'
```

然后执行：

```bash
pod install
```

### Carthage

使用 [Carthage](https://github.com/Carthage/Carthage) 安装，在 Cartfile 中添加：

```ruby
github "luowei/LWDynamicFont"
```

## 使用方法

### 1. 导入头文件

```objective-c
#import <LWDynamicFont/LWFontManager.h>
```

### 2. 应用启动时注册本地字体

在应用启动时（`application:didFinishLaunchingWithOptions:` 方法中）注册所有已下载的本地字体：

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 注册所有自定义的本地字体
    [LWFontManager registerAllCustomLocalFonts];

    return YES;
}
```

### 3. 检查字体是否可用

在使用字体之前，建议先检查字体是否可用：

```objective-c
NSString *fontName = @"YuppySC-Regular";  // 字体的 PostScript 名称

if ([LWFontManager isAvaliableFont:fontName]) {
    // 字体可用，直接使用
    UIFont *font = [UIFont fontWithName:fontName size:18.0];
} else {
    // 字体不可用，需要下载
}
```

### 4. 下载自定义字体

从自定义服务器下载字体文件：

```objective-c
NSString *fontName = @"YuppySC-Regular";  // 字体的 PostScript 名称
NSString *fontURL = @"http://example.com/fonts/YuppySC-Regular.otf";

// 下载字体并监听下载进度
[LWFontManager downloadCustomFontWithFontName:fontName
                                    URLString:fontURL
                            showProgressBlock:^{
                                // 开始下载，显示进度提示
                                NSLog(@"开始下载字体...");
                            }
                          updateProgressBlock:^(float progress) {
                              // 更新下载进度 (0.0 ~ 1.0)
                              NSLog(@"字体下载进度: %.2f%%", progress * 100);
                          }
                                completeBlock:^{
                                    // 下载完成
                                    NSLog(@"字体下载完成！");
                                    // 可以在这里更新 UI，使用新字体
                                }];
```

### 5. 下载 Apple 官方字体

下载 Apple 提供的系统字体：

```objective-c
NSString *fontName = @"DIN Alternate";  // Apple 字体的 PostScript 名称

[LWFontManager downloadAppleFontWithFontName:fontName
                           showProgressBlock:^{
                               NSLog(@"开始下载 Apple 字体...");
                           }
                         updateProgressBlock:^(float progress) {
                             NSLog(@"下载进度: %.2f%%", progress * 100);
                         }
                               completeBlock:^{
                                   NSLog(@"Apple 字体下载完成！");
                               }];
```

### 6. 使用字体

#### 方式一：直接使用

```objective-c
NSString *fontName = @"YuppySC-Regular";

if ([LWFontManager isAvaliableFont:fontName]) {
    UIFont *font = [LWFontManager fontWithFontName:fontName size:20.0];
    label.font = font;
}
```

#### 方式二：使用回调（推荐）

```objective-c
NSString *fontName = @"YuppySC-Regular";

[LWFontManager useFontName:fontName
                      size:20.0
                  useBlock:^(UIFont *font) {
                      if (font) {
                          // 字体可用，更新 UI
                          label.font = font;
                      } else {
                          // 字体不可用
                          NSLog(@"字体 %@ 不可用", fontName);
                      }
                  }];
```

### 7. 完整示例

以下是一个完整的使用示例：

```objective-c
#import <LWDynamicFont/LWFontManager.h>

@interface ViewController ()

@property (nonatomic, strong) UILabel *myLabel;
@property (nonatomic, strong) NSDictionary *fontURLMap;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 配置字体 URL 映射表
    self.fontURLMap = @{
        @"YuppySC-Regular": @"http://oss.wodedata.com/Fonts/雅痞.otf",
        @"STLiti": @"http://oss.wodedata.com/Fonts/华文隶书.ttf",
        @"YouYuan": @"http://oss.wodedata.com/Fonts/幼圆.ttf",
        @"MicrosoftYaHei": @"http://oss.wodedata.com/Fonts/微软雅黑.ttf"
    };

    // 创建 Label
    self.myLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 100, 300, 50)];
    self.myLabel.text = @"这是一段测试文字";
    [self.view addSubview:self.myLabel];

    // 加载并使用字体
    [self loadAndUseFontNamed:@"YuppySC-Regular"];
}

- (void)loadAndUseFontNamed:(NSString *)fontName {
    // 检查字体是否可用
    if (![LWFontManager isAvaliableFont:fontName]) {
        // 字体不可用，开始下载
        NSString *fontURL = self.fontURLMap[fontName];

        [LWFontManager downloadCustomFontWithFontName:fontName
                                           URLString:fontURL
                                   showProgressBlock:^{
                                       // 显示下载提示
                                       NSLog(@"开始下载字体: %@", fontName);
                                   }
                                 updateProgressBlock:^(float progress) {
                                     // 更新下载进度
                                     NSLog(@"下载进度: %.2f%%", progress * 100);
                                 }
                                       completeBlock:^{
                                           // 下载完成，使用字体
                                           NSLog(@"字体下载完成");
                                           self.myLabel.font = [UIFont fontWithName:fontName size:24.0];
                                       }];
    } else {
        // 字体已可用，直接使用
        self.myLabel.font = [UIFont fontWithName:fontName size:24.0];
    }
}

@end
```

## 核心 API 说明

### LWFontManager 类方法

#### 字体管理

```objective-c
// 获取单例实例
+ (instancetype)shareInstance;

// 检查字体是否可用（参数为字体的 PostScript 名称）
+ (BOOL)isAvaliableFont:(NSString *)fontName;

// 注册所有已下载的本地字体（建议在应用启动时调用）
+ (void)registerAllCustomLocalFonts;
```

#### 字体使用

```objective-c
// 根据字体名称和大小创建 UIFont 对象
+ (UIFont *)fontWithFontName:(NSString *)fontName size:(CGFloat)size;

// 使用字体（带回调）
+ (void)useFontName:(NSString *)fontName
               size:(CGFloat)size
           useBlock:(void (^)(UIFont *font))useBlock;
```

#### 下载自定义字体

```objective-c
// 从自定义服务器下载字体
+ (void)downloadCustomFontWithFontName:(NSString *)fontName
                            URLString:(NSString *)urlString
                    showProgressBlock:(void (^)(void))showProgressBlock
                  updateProgressBlock:(void (^)(float progress))progressBlock
                        completeBlock:(void (^)(void))completeBlock;
```

**参数说明：**
- `fontName`: 字体的 PostScript 名称（重要：不是文件名）
- `urlString`: 字体文件的下载 URL
- `showProgressBlock`: 开始下载时的回调
- `progressBlock`: 下载进度回调，参数 progress 范围为 0.0 ~ 1.0
- `completeBlock`: 下载完成时的回调

#### 下载 Apple 字体

```objective-c
// 下载 Apple 官方提供的字体
+ (void)downloadAppleFontWithFontName:(NSString *)fontName
                    showProgressBlock:(void (^)(void))showProgressBlock
                  updateProgressBlock:(void (^)(float progress))progressBlock
                        completeBlock:(void (^)(void))completeBlock;
```

#### 文件操作

```objective-c
// 删除指定路径的文件
+ (BOOL)removeFileWithFilePath:(NSString *)filePath;

// 写入数据到指定路径
+ (BOOL)writeData:(NSData *)data toFilePath:(NSString *)filePath;

// 创建目录（如果不存在）
+ (BOOL)createDirectoryIfNotExsitPath:(NSString *)path;
```

## 工作原理

### 1. 字体存储

- 下载的字体文件存储在应用的 Documents/fonts 目录下
- Apple 字体的路径信息保存在 NSUserDefaults 中

### 2. 字体注册

- 使用 CoreText 框架的 `CTFontManagerRegisterGraphicsFont` 方法注册字体
- 应用启动时自动注册所有已下载的本地字体
- 自定义字体下载完成后立即注册

### 3. Method Swizzling

库使用方法交换技术增强了 `UIFont` 的 `fontWithName:size:` 方法：
- 当使用字体时，自动检查字体文件是否存在
- 如果字体文件存在但未注册，自动注册后使用
- 如果字体不可用，自动降级到 Helvetica 字体

### 4. 下载机制

- **自定义字体**：使用 NSURLSession 下载字体文件到本地
- **Apple 字体**：使用 CoreText 的 `CTFontDescriptorMatchFontDescriptorsWithProgressHandler` API

## 注意事项

### 字体命名

⚠️ **重要**：所有 API 中的 `fontName` 参数都必须使用字体的 **PostScript 名称**，而不是字体文件名。

如何获取字体的 PostScript 名称：
1. 在 Mac 上双击字体文件，使用「字体册」应用打开
2. 在字体信息中查看「PostScript 名称」字段
3. 或者使用以下代码打印所有可用字体：

```objective-c
// 打印所有字体家族
for (NSString *familyName in [UIFont familyNames]) {
    NSLog(@"Family: %@", familyName);

    // 打印该家族下的所有字体
    for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
        NSLog(@"  Font: %@", fontName);
    }
}
```

### 字体文件格式

支持的字体格式：
- TrueType (.ttf)
- OpenType (.otf)

### 应用重启后的字体加载

注册过的字体在应用关闭后，下次启动时需要重新注册才能使用。因此，必须在应用启动时调用 `registerAllCustomLocalFonts` 方法：

```objective-c
- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 重新注册所有本地字体
    [LWFontManager registerAllCustomLocalFonts];
    return YES;
}
```

### 字体下载的网络要求

- 确保字体文件 URL 可访问
- 建议使用 HTTPS 协议
- 如果使用 HTTP，需要在 Info.plist 中配置 App Transport Security

### 线程安全

- 所有回调都在主线程执行
- UI 更新可以直接在回调中进行

## 示例项目

项目包含一个完整的示例应用，演示了如何使用 LWDynamicFont：

1. 克隆仓库：
```bash
git clone https://github.com/luowei/LWDynamicFont.git
```

2. 进入 Example 目录并安装依赖：
```bash
cd LWDynamicFont/Example
pod install
```

3. 打开工作空间：
```bash
open LWDynamicFont.xcworkspace
```

4. 运行示例项目查看效果

示例项目展示了：
- 字体的动态下载
- 下载进度的显示
- 字体下载完成后的即时应用
- 多个字体的管理和切换

## 常见问题

### Q1: 字体下载完成后，为什么 Label 没有显示正确的字体？

A: 请检查以下几点：
1. 确认使用的是字体的 PostScript 名称，不是文件名
2. 检查字体文件是否下载成功（可以查看 Documents/fonts 目录）
3. 确认在下载完成回调中设置了 Label 的 font 属性

### Q2: 如何知道我的字体文件的 PostScript 名称？

A: 方法一：使用 Mac 的「字体册」应用查看；方法二：使用以下代码遍历所有已注册的字体：

```objective-c
for (NSString *familyName in [UIFont familyNames]) {
    for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
        NSLog(@"%@", fontName);  // 这就是 PostScript 名称
    }
}
```

### Q3: 支持同时下载多个字体吗？

A: 当前版本同一时间只支持下载一个字体。如果在前一个字体下载完成前开始下载新字体，前一个下载任务会被取消。

### Q4: 下载的字体会占用多少存储空间？

A: 字体文件大小因字体而异，通常在 2MB ~ 20MB 之间。中文字体因为包含大量汉字，通常会比较大。

### Q5: 如何删除已下载的字体？

A: 使用以下方法删除字体文件：

```objective-c
NSString *fontPath = [LWFontManager shareInstance].fontDirectoryPath;
NSString *fontFilePath = [fontPath stringByAppendingPathComponent:@"fontFileName"];
[LWFontManager removeFileWithFilePath:fontFilePath];
```

## 版本历史

### 1.0.0
- 首次发布
- 支持自定义字体动态下载
- 支持 Apple 官方字体下载
- 提供字体自动注册功能
- 提供下载进度跟踪

## 作者

**luowei** - [luowei@wodedata.com](mailto:luowei@wodedata.com)

## 许可证

LWDynamicFont 使用 MIT 许可证发布。详见 [LICENSE](LICENSE) 文件。

## 参与贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建你的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交你的更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启一个 Pull Request

## 相关资源

- [CocoaPods 官方文档](https://cocoapods.org)
- [CoreText 编程指南](https://developer.apple.com/library/archive/documentation/StringsTextFonts/Conceptual/CoreText_Programming/Introduction/Introduction.html)
- [Apple 动态字体下载示例](https://developer.apple.com/library/ios/samplecode/DownloadFont/Introduction/Intro.html)
- [iOS 自定义字体使用指南](http://blog.devzeng.com/blog/using-custom-font-in-ios.html)

## 致谢

感谢所有为这个项目做出贡献的开发者！
