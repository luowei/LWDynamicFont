# LWDynamicFont

[![CI Status](https://img.shields.io/travis/luowei/LWDynamicFont.svg?style=flat)](https://travis-ci.org/luowei/LWDynamicFont)
[![Version](https://img.shields.io/cocoapods/v/LWDynamicFont.svg?style=flat)](https://cocoapods.org/pods/LWDynamicFont)
[![License](https://img.shields.io/cocoapods/l/LWDynamicFont.svg?style=flat)](https://cocoapods.org/pods/LWDynamicFont)
[![Platform](https://img.shields.io/cocoapods/p/LWDynamicFont.svg?style=flat)](https://cocoapods.org/pods/LWDynamicFont)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```Objective-C
if (![LWFontManager isAvaliableFont:fontName]) {  //如果字体不可用
    //todo: something
    
    //下载字体
    [LWFontManager downloadCustomFontWithFontName:fontName URLString:vc.fontURLMap[fontName]
                                showProgressBlock:^{
                                    Log(@"=====开始下载字体");
                                }
                              updateProgressBlock:^(float progress) {
                                  Log(@"======字体下载：%f", progress);
                              }
                                    completeBlock:^{
                                        Log(@"======字体下载完成");
                                    }];

    return;
}

```

## Requirements

## Installation

LWDynamicFont is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LWDynamicFont'
```

**Carthage**
```ruby
github "luowei/LWDrawboard"
```

## Author

luowei, luowei@wodedata.com

## License

LWDynamicFont is available under the MIT license. See the LICENSE file for more info.
