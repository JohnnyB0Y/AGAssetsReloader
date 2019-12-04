//
//  AGBaseAssetsConfig+AGLanguageAssets.m
//  AGAssetsReloader
//
//  Created by JohnnyB0Y on 2019/12/4.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//

#import "AGAssetsConfig+AGLanguageAssets.h"
#import "AGAssetsReloader.h"

@implementation AGBaseAssetsConfig (AGLanguageAssets)

#pragma mark - 对语言重载响应者的相关操作
/// 添加语言重载支持
+ (void)ag_addLanguageReloadResponder:(id<UITraitEnvironment>)responder
{
    [[self ag_assetsForName:kAGLanguageAssetsName] ag_addReloadResponder:responder];
}

/// 移除语言重载支持
+ (void)ag_removeLanguageReloadResponder:(id<UITraitEnvironment>)responder
{
    [[self ag_assetsForName:kAGLanguageAssetsName] ag_removeReloadResponder:responder];
}

/// 执行语言重载修改
+ (void)ag_executeLanguageReloadResponder:(id<UITraitEnvironment>)responder
{
    [[self ag_assetsForName:kAGLanguageAssetsName] ag_executeReloadResponder:responder];
}

/// 添加语言重载支持并执行修改
+ (void)ag_addAndExecuteLanguageReloadResponder:(id<UITraitEnvironment>)responder
{
    [[self ag_assetsForName:kAGLanguageAssetsName] ag_addReloadResponder:responder];
    [[self ag_assetsForName:kAGLanguageAssetsName] ag_executeReloadResponder:responder];
}


#pragma mark - NSString
+ (NSString *)ag_localizedStringForKey:(NSString *)key
{
    AGLanguageAssets *assets = (id)[self ag_assetsForName:kAGLanguageAssetsName];
    return NSLocalizedStringFromTableInBundle(key,
                                              assets.currentPackName,
                                              assets.currentBundle,
                                              nil);
}

@end
