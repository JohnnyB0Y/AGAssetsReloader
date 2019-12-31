//
//  AGBaseAssetsBox+AGThemeAssets.h
//  AGAssetsReloader
//
//  Created by JohnnyB0Y on 2019/12/4.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//  主题资产

#import "AGBaseAssetsBox.h"
#import "AGThemeAssets.h"

NS_ASSUME_NONNULL_BEGIN

@interface AGBaseAssetsBox (AGThemeAssets)

#pragma mark - 对主题重载响应者的相关操作
/// 添加主题重载支持
+ (void)ag_addThemeReloadResponder:(id<UITraitEnvironment>)responder;

/// 移除主题重载支持
+ (void)ag_removeThemeReloadResponder:(id<UITraitEnvironment>)responder;

/// 执行主题重载修改
+ (void)ag_executeThemeReloadResponder:(id<UITraitEnvironment>)responder;

/// 添加主题重载支持并执行修改
+ (void)ag_addAndExecuteThemeReloadResponder:(id<UITraitEnvironment>)responder;


#pragma mark - UIColor
/// 取出当前主题的颜色
/// @param key 键
+ (nullable UIColor *)ag_colorForKey:(NSString *)key;


/// 取出当前主题的颜色
/// @param key 键
+ (nullable UIColor *)ag_colorNamedForKey:(NSString *)key;


#pragma mark - UIImage
/// 获取当前主题图片
/// @param key 键
+ (nullable UIImage *)ag_imageForKey:(NSString *)key;


/// 获取当前主题图片名
/// @param key 键
+ (nullable NSString *)ag_imageNameForKey:(NSString *)key;


/// 获取当前主题图片
/// @param key 键
+ (nullable UIImage *)ag_imageWithFilePathForKey:(NSString *)key;


#pragma mark - UIFont
/// 获取当前主题字体
/// @param key 键
+ (nullable UIFont *)ag_fontForKey:(NSString *)key;


/// 获取当前主题系统动态字体(根据系统字体大小变化), [UIFont preferredFontForTextStyle:fontTextStyle]
/// @param key 键
+ (nullable UIFont *)ag_fontPreferredForKey:(NSString *)key;


/// 获取当前主题 UIFontTextStyle
/// @param key 键
+ (nullable UIFontTextStyle)ag_fontTextStyleForKey:(NSString *)key;


/// 获取当前主题动态字体(根据系统字体大小变化)
/// @param key 键
+ (nullable UIFont *)ag_fontDynamicForKey:(NSString *)key;


#pragma mark - NSURL
/// 获取当前主题URL
/// @param key 键
+ (nullable NSURL *)ag_URLForKey:(NSString *)key;


/// 获取当前主题URLStr
/// @param key 键
+ (nullable NSString *)ag_URLStringForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
