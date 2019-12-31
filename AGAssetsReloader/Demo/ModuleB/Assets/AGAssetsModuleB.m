//
//  AGAssetsModuleB.m
//  AGAssetsReloader
//
//  Created by JohnnyB0Y on 2019/12/1.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//

#import "AGAssetsModuleB.h"
#import "AGCustomThemeConstKeys.h"
#import "AGOrangeThemePack.h"
#import "AGPurpleThemePack.h"
#import "AGBlueThemePack.h"
#import "AGDarkThemePackB.h"
#import "AGLightThemePackB.h"

@implementation AGAssetsModuleB

+ (AGBaseAssets *)ag_assetsForName:(NSString *)name
{
    if ([name isEqualToString:kAGThemeAssetsName]) {
        static AGThemeAssets *collection;
        if (nil == collection) {
            
            // 配置模块主题
            collection = [AGThemeAssets newWithDefaultPackName:kAGPurpleThemePack];
            [collection ag_registerAssetsPack:[AGPurpleThemePack newWithPackName:kAGPurpleThemePack] forName:kAGPurpleThemePack];
            [collection ag_registerAssetsPack:[AGBlueThemePack newWithPackName:kAGBlueThemePack] forName:kAGBlueThemePack];
            [collection ag_registerAssetsPack:[AGDarkThemePackB newWithPackName:kAGDarkThemePack] forName:kAGDarkThemePack];
            [collection ag_registerAssetsPack:[AGLightThemePackB newWithPackName:kAGLightThemePack] forName:kAGLightThemePack];
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
    return nil;
}

+ (void)reloadThemeAssetsForPackName:(NSString *)packName
{
    [self ag_reloadAssetsWithName:kAGThemeAssetsName forPackName:packName];
}

#pragma mark - ----------- Getter Methods ----------
+ (nullable UIColor *)colorForContentText
{
    return [self ag_colorForKey:kAGThemePackHomeCellContentTextColor];
}

+ (nullable UIFont *)fontForContentText
{
    return [self ag_fontDynamicForKey:kAGThemePackHomeCellContentTextFont];
}

+ (nullable UIImage *)imageForIcon
{
    return [self ag_imageForKey:kAGThemePackHomeCellIconImageName];
}

@end
