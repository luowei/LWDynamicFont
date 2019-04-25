//
//  LWViewController.m
//  libDynamicFont
//
//  Created by luowei on 04/25/2019.
//  Copyright (c) 2019 luowei. All rights reserved.
//

#import <libDynamicFont/LWFontManager.h>
#import "LWViewController.h"
#import "LWAppDelegate.h"
#import "LWMaskProgressView.h"

@interface LWViewController ()

@property(nonatomic, strong) NSDictionary *fontURLMap;

@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;
@property (weak, nonatomic) IBOutlet UIButton *btn3;

@end

@implementation LWViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.btn1.titleLabel.font = [UIFont fontWithName:[self randomFontName] size:20];
    self.btn2.titleLabel.font = [UIFont fontWithName:[self randomFontName] size:20];
    self.btn3.titleLabel.font = [UIFont fontWithName:[self randomFontName] size:20];

    self.fontURLMap = @{
            @"LiuJiang-Cao-1.0": @"http://oss.wodedata.com/Fonts/%E9%92%9F%E9%BD%90%E6%B5%81%E6%B1%9F%E7%A1%AC%E7%AC%94%E8%8D%89%E4%BD%93.ttf",
            @"AnJingCheng-Xing-2.0": @"http://oss.wodedata.com/Fonts/%E9%92%9F%E9%BD%90%E5%AE%89%E6%99%AF%E8%87%A3%E7%A1%AC%E7%AC%94%E8%A1%8C%E4%B9%A6.ttf",
            @"STLiti": @"http://oss.wodedata.com/Fonts/%E5%8D%8E%E6%96%87%E9%9A%B6%E4%B9%A6.ttf",
            @"YouYuan": @"http://oss.wodedata.com/Fonts/%E5%B9%BC%E5%9C%86.ttf",
            @"YuppySC-Regular": @"http://oss.wodedata.com/Fonts/%E9%9B%85%E7%97%9E.otf",
            @"MicrosoftYaHei": @"http://oss.wodedata.com/Fonts/%E5%BE%AE%E8%BD%AF%E9%9B%85%E9%BB%91.ttf"
    };

}

- (void)loadFontWithFontName:(NSString *)fontName completeBlock:(void (^)())completeBlock {
    if (![LWFontManager isAvaliableFont:fontName]) {  //如果字体不可用
        //下载字体
        [LWFontManager downloadCustomFontWithFontName:fontName URLString:self.fontURLMap[fontName]
                                    showProgressBlock:^{
                                        LWFLog(@"=====开始下载字体");
                                        [LWMaskProgressView showMaskProgressViewin:self.view withText:@"取消" progress:0 dismissBlock:^{
                                            [[LWFontManager shareInstance].curretnDataTask cancel];
                                        }];
                                    }
                                  updateProgressBlock:^(float progress) {
                                      LWFLog(@"======字体下载：%f", progress);
                                      [LWMaskProgressView showMaskProgressViewin:self.view withText:@"取消" progress:progress dismissBlock:^{
                                          [[LWFontManager shareInstance].curretnDataTask cancel];
                                      }];
                                  }
                                        completeBlock:^{
                                            LWFLog(@"======字体下载任务执行完成");
                                            [LWMaskProgressView dismissMaskProgressViewin:self.view];
                                            if(completeBlock){
                                                completeBlock();
                                            }
                                        }];

        return;
    }else{
        if(completeBlock){
            completeBlock();
        }
    }
}



- (IBAction)btnAction:(UIButton *)btn {
    NSString *fontName = [self randomFontName];

    [self loadFontWithFontName:fontName completeBlock:^{
        btn.titleLabel.font = [UIFont fontWithName:fontName size:20];
    }];
}

- (NSString *)randomFontName {
    NSArray *allKeys = self.fontURLMap.allKeys;
    int random = arc4random() % allKeys.count;
    NSString *fontName = allKeys[(NSUInteger) random];
    return fontName;
}


@end



@implementation LWAppDelegate (LWLoadFonts)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [LWAppDelegate lwdf_swizzleClassMethod:@selector(application: didFinishLaunchingWithOptions:) withMethod:@selector(myApplication: didFinishLaunchingWithOptions:)];
    });
}

- (BOOL)myApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{

    BOOL result = YES;
    if(application){
        result = [self myApplication:application didFinishLaunchingWithOptions:launchOptions];
        //注册所有本地字体
        [LWFontManager registerAllCustomLocalFonts];
    }
    return result;
}

@end

