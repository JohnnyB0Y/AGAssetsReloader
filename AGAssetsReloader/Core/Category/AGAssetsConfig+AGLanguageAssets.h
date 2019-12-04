//
//  AGBaseAssetsConfig+AGLanguageAssets.h
//  AGAssetsReloader
//
//  Created by JohnnyB0Y on 2019/12/4.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//

#import "AGBaseAssetsConfig.h"
#import "AGLanguageAssets.h"

NS_ASSUME_NONNULL_BEGIN

@interface AGBaseAssetsConfig (AGLanguageAssets)

#pragma mark - 对语言重载响应者的相关操作
/// 添加语言重载支持
+ (void)ag_addLanguageReloadResponder:(id<UITraitEnvironment>)responder;

/// 移除语言重载支持
+ (void)ag_removeLanguageReloadResponder:(id<UITraitEnvironment>)responder;

/// 执行语言重载修改
+ (void)ag_executeLanguageReloadResponder:(id<UITraitEnvironment>)responder;

/// 添加语言重载支持并执行修改
+ (void)ag_addAndExecuteLanguageReloadResponder:(id<UITraitEnvironment>)responder;


#pragma mark - NSString
/// 获取当前语言的字符串
/// @param key 键
+ (nullable NSString *)ag_localizedStringForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
