//
//  AGLanguageAssets.h
//  AGAssetsReloader
//
//  Created by JohnnyB0Y on 2019/12/1.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGBaseAssets.h"

NS_ASSUME_NONNULL_BEGIN

/// 语言资产名
FOUNDATION_EXTERN NSString * const kAGLanguageAssetsName;

@interface AGLanguageAssets : AGBaseAssets

/// 当使用跟随系统语言时，需要自行处理语言匹配问题
@property (nonatomic, copy) NSString *_Nullable (^followSystemLanguageHandleBlock)(NSString *systemLanguage);

/// 用户预设语言，第一个为当前系统使用语言
+ (NSArray<NSString *> *)ag_allLanguages;

@end

NS_ASSUME_NONNULL_END
