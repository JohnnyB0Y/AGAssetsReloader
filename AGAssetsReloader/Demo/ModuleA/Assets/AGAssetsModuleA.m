//
//  AGAssetsModuleA.m
//  AGAssetsReloader
//
//  Created by JohnnyB0Y on 2019/12/1.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//

#import "AGAssetsModuleA.h"
#import "AGThemeAssets.h"
#import "AGCustomThemeConstKeys.h"
#import "AGOrangeThemePack.h"
#import "AGBlueThemePack.h"
#import "AGDarkThemePackA.h"
#import "AGLightThemePackA.h"

@implementation AGAssetsModuleA

#pragma mark - ----------- Getter Methods ----------

+ (AGBaseAssets *)ag_assetsForName:(NSString *)name
{
    if (name == kAGThemeAssetsName) {
        
        static AGThemeAssets *collection;
        if (nil == collection) {
            // 配置模块主题
            collection = [AGThemeAssets newWithDefaultPackName:kAGOrangeThemePack];
            [collection ag_registerAssetsPack:[AGOrangeThemePack newWithPackName:kAGOrangeThemePack] forName:kAGOrangeThemePack];
            [collection ag_registerAssetsPack:[AGBlueThemePack newWithPackName:kAGBlueThemePack] forName:kAGBlueThemePack];
            [collection ag_registerAssetsPack:[AGDarkThemePackA newWithPackName:kAGDarkThemePack] forName:kAGDarkThemePack];
            [collection ag_registerAssetsPack:[AGLightThemePackA newWithPackName:kAGLightThemePack] forName:kAGLightThemePack];
            collection.followSystemThemeHandleBlock = ^NSString * _Nullable(UITraitCollection * _Nonnull traitCollection) {
                if (@available(iOS 13.0, *)) {
                    switch ([UIScreen mainScreen].traitCollection.userInterfaceStyle) {
                        case UIUserInterfaceStyleDark: {
                            return kAGDarkThemePack;
                        } break;
                        default: {
                            return kAGLightThemePack;
                        } break;
                    }
                }
                // iOS 13以下，只有白天
                return kAGLightThemePack;
            };
            
            [self ag_registerAssets:collection forName:name];
        }
        return collection;
        
    }
    else if (name == kAGLanguageAssetsName) {
        static AGLanguageAssets *collection;
        if (nil == collection) {
            // 配置语言
            NSArray *languages = @[@"LocalizationEnglish", @"LocalizationChinese", @"LocalizationCantonese"];
            collection = [AGLanguageAssets newWithDefaultPackName:languages.firstObject];
            collection.currentBundle = [NSBundle mainBundle];
            
            [languages enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [collection ag_registerAssetsPack:obj forName:obj];
            }];
            
            // 系统正在使用的语言
            collection.followSystemLanguageHandleBlock = ^NSString * _Nullable(NSString * _Nonnull systemLanguage) {
                // 这是例子🌰，其实可以把语言文件名和系统语言匹配起来使用。
                if ([systemLanguage isEqualToString:@"en-US"]) {
                    return @"LocalizationEnglish";
                }
                else if ([systemLanguage isEqualToString:@"zh-Hans-US"]) {
                    return @"LocalizationChinese";
                }
                return nil;
            };
            
            [self ag_registerAssets:collection forName:name];
        }
        return collection;
    }
    
    return nil;
}

+ (void)reloadLanguageAssetsForPackName:(NSString *)packName
{
    [self ag_reloadAssetsWithName:kAGLanguageAssetsName forPackName:packName];
}

+ (void)reloadThemeAssetsForPackName:(NSString *)packName
{
    [self ag_reloadAssetsWithName:kAGThemeAssetsName forPackName:packName];
}

@end

@implementation AGAssetsModuleA (UIImage)

+ (nullable UIImage *)imageForIcon
{
    return [self ag_imageForKey:kAGThemePackHomeCellIconImageName];
}

@end

@implementation AGAssetsModuleA (UIFont)

+ (nullable UIFont *)fontForContentText
{
    return [self ag_fontDynamicForKey:kAGThemePackHomeCellContentTextFont];
}

@end

@implementation AGAssetsModuleA (Localization)

+ (nullable NSString *)localizedCellTitle
{
    return [self ag_localizedStringForKey:@"cellTitle"];
}

+ (nullable NSString *)localizedCellText
{
    return [self ag_localizedStringForKey:@"cellText"];
}

@end

@implementation AGAssetsModuleA (UIColor)

+ (nullable UIColor *)colorForContentText
{
    return [self ag_colorForKey:kAGThemePackHomeCellContentTextColor];
}

@end
