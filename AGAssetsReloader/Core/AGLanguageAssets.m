//
//  AGLanguageAssets.m
//  AGAssetsReloader
//
//  Created by JohnnyB0Y on 2019/12/1.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//

#import "AGLanguageAssets.h"
#import "AGAssetsReloader.h"

/// 语言是否跟随系统
FOUNDATION_EXTERN NSString * const kAGLanguageFollowSystemState;
/// 使用中的语言包名
FOUNDATION_EXTERN NSString * const kAGLanguageUsingPackName;

@interface AGLanguageAssets ()


@end

@implementation AGLanguageAssets
#pragma mark - 更换语言
- (BOOL)ag_neededReloadWithTraitCollection:(UITraitCollection *)traitCollection forPackName:(NSString *)packname
{
    if ([AGAssetsReloader.sharedInstance ag_followSystemStateForKey:kAGLanguageFollowSystemState]) {
        return ! [self ag_isUsingPackName:self.systemPackName];
    }
    return [super ag_neededReloadWithTraitCollection:traitCollection forPackName:packname];
}

#pragma mark - ----------- Setter Methods ----------
- (void)setFollowSystemLanguageHandleBlock:(NSString * _Nullable (^)(NSString * _Nonnull))followSystemLanguageHandleBlock
{
    _followSystemLanguageHandleBlock = [followSystemLanguageHandleBlock copy];
    if (_followSystemLanguageHandleBlock) {
        _systemPackName = _followSystemLanguageHandleBlock([self.class ag_allLanguages].firstObject);
    }
}

#pragma mark - ----------- Getter Methods ----------
/// 资产名 key
- (NSString *)ag_assetsNameKey
{
    return kAGLanguageAssetsName;
}

/// 是否跟随系统 key
- (NSString *)ag_assetsFollowSystemStateKey
{
    return kAGLanguageFollowSystemState;
}

/// 使用中的包名 key
- (NSString *)ag_assetsUsingPackNameKey
{
    return kAGLanguageUsingPackName;
}

+ (NSArray<NSString *> *)ag_allLanguages
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
}

@end

/// 语言资产名
NSString * const kAGLanguageAssetsName = @"kAGLanguageAssetsName";
/// 语言是否跟随系统
NSString * const kAGLanguageFollowSystemState = @"kAGLanguageFollowSystemState";
/// 使用中的语言包名
NSString * const kAGLanguageUsingPackName = @"kAGLanguageUsingPackName";
