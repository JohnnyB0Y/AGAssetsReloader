//
//  AGBaseAssetsBox+AGThemeAssets.m
//  AGAssetsReloader
//
//  Created by JohnnyB0Y on 2019/12/4.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//  主题资产

#import "AGAssetsConfig+AGThemeAssets.h"
#import "AGAssetsReloader.h"
#import "AGThemePack.h"

@implementation AGBaseAssetsBox (AGThemeAssets)

+ (AGThemeAssets *)currentThemeAssets
{
    return (id)[self ag_assetsForName:kAGThemeAssetsName];
}

#pragma mark - 对主题重载响应者的相关操作
/// 添加主题重载支持
+ (void)ag_addThemeReloadResponder:(id<UITraitEnvironment>)responder
{
    [self.currentThemeAssets ag_addReloadResponder:responder];
}

/// 移除主题重载支持
+ (void)ag_removeThemeReloadResponder:(id<UITraitEnvironment>)responder
{
    [self.currentThemeAssets ag_removeReloadResponder:responder];
}

/// 执行主题重载修改
+ (void)ag_executeThemeReloadResponder:(id<UITraitEnvironment>)responder
{
    [self.currentThemeAssets ag_executeReloadResponder:responder];
}

/// 添加主题重载支持并执行修改
+ (void)ag_addAndExecuteThemeReloadResponder:(id<UITraitEnvironment>)responder
{
    [self.currentThemeAssets ag_addReloadResponder:responder];
    [self.currentThemeAssets ag_executeReloadResponder:responder];
}


#pragma mark - UIColor
/// 取出当前主题的颜色
/// @param key 键
+ (nullable UIColor *)ag_colorForKey:(NSString *)key
{
    UIColor *color = self.currentThemeAssets.currentPack[key];
    
    if ( [color isKindOfClass:[UIColor class]] ) {
        return color;
    }
    
    return nil;
}


/// 取出当前主题的颜色
/// @param key 键
+ (nullable UIColor *)ag_colorNamedForKey:(NSString *)key
{
    NSString *colorName = self.currentThemeAssets.currentPack[key];
    
    if ( [colorName isKindOfClass:[NSString class]] ) {
        if (@available(iOS 11.0, *)) {
            return [UIColor colorNamed:colorName];
        }
    }
    if ( [colorName isKindOfClass:[UIColor class]] ) {
        return (id)colorName;
    }
    
    return nil;
}


#pragma mark - UIImage
/// 获取当前主题图片
/// @param key 键
+ (nullable UIImage *)ag_imageForKey:(NSString *)key
{
    NSString *image = self.currentThemeAssets.currentPack[key];
    
    if ( [image isKindOfClass:[UIImage class]] ) {
        return (id)image;
    }
    else if ( [image isKindOfClass:[NSString class]] ) {
        return [UIImage imageNamed:image];
    }
    
    return nil;
}


/// 获取当前主题图片名
/// @param key 键
+ (nullable NSString *)ag_imageNameForKey:(NSString *)key
{
    NSString *image = self.currentThemeAssets.currentPack[key];
    
    if ( [image isKindOfClass:[NSString class]] ) {
        return image;
    }
    
    return nil;
}


/// 获取当前主题图片
/// @param key 键
+ (nullable UIImage *)ag_imageWithFilePathForKey:(NSString *)key
{
    NSString *path = self.currentThemeAssets.currentPack[key];
    
    if ( [path isKindOfClass:[NSString class]] ) {
        return [UIImage imageWithContentsOfFile:path];
    }
    else if ( [path isKindOfClass:[UIImage class]] ) {
        return (id)path;
    }
    
    return nil;
}


#pragma mark - UIFont
/// 获取当前主题字体
/// @param key 键
+ (nullable UIFont *)ag_fontForKey:(NSString *)key
{
    UIFont *font = self.currentThemeAssets.currentPack[key];
    
    if ( [font isKindOfClass:[UIFont class]] ) {
        return font;
    }
    
    return nil;
}


/// 获取当前主题系统动态字体(根据系统字体大小变化), [UIFont preferredFontForTextStyle:fontTextStyle]
/// @param key 键
+ (nullable UIFont *)ag_fontPreferredForKey:(NSString *)key
{
    UIFontTextStyle fontTextStyle = self.currentThemeAssets.currentPack[key];
    if ( [fontTextStyle isKindOfClass:[NSString class]] ) {
        return [UIFont preferredFontForTextStyle:fontTextStyle];
    }
    
    return nil;
}


/// 获取当前主题 UIFontTextStyle
/// @param key 键
+ (nullable UIFontTextStyle)ag_fontTextStyleForKey:(NSString *)key
{
    UIFontTextStyle fontTextStyle = self.currentThemeAssets.currentPack[key];
    if ( [fontTextStyle isKindOfClass:[NSString class]] ) {
        return fontTextStyle;
    }
    return nil;
}


/// 获取当前主题动态字体(根据系统字体大小变化)
/// @param key 键
+ (nullable UIFont *)ag_fontDynamicForKey:(NSString *)key
{
    AGThemeAssets *assets = self.currentThemeAssets;
    UIFont *font = assets.currentPack[key];
    
    if ( [font isKindOfClass:[UIFont class]] ) {
        if ( assets.openContentSizeChangeNotification ) {
            // 变化偏移
            NSInteger fontScaleSize = assets.fontScaleSize;
            NSInteger currentFontSize = font.pointSize + fontScaleSize;
            if ( currentFontSize != font.pointSize ) {
                return [UIFont fontWithDescriptor:font.fontDescriptor size:currentFontSize];
            }
        }
        return font;
    }
    
    return nil;
}


#pragma mark - NSURL
/// 获取当前主题URL
/// @param key 键
+ (nullable NSURL *)ag_URLForKey:(NSString *)key
{
    NSURL *url = self.currentThemeAssets.currentPack[key];
    if ( [url isKindOfClass:[NSURL class]] ) {
        return url;
    }
    else if ( [url isKindOfClass:[NSString class]] ) {
        return [NSURL URLWithString:(NSString *)url];
    }
    
    return nil;
    
}


/// 获取当前主题URLStr
/// @param key 键
+ (nullable NSString *)ag_URLStringForKey:(NSString *)key
{
    NSURL *url = self.currentThemeAssets.currentPack[key];
    if ( [url isKindOfClass:[NSURL class]] ) {
        return url.absoluteString;
    }
    else if ( [url isKindOfClass:[NSString class]] ) {
        return (id)url;
    }
    
    return nil;
}

@end
