//
//  AGThemeAssets.h
//  
//
//  Created by JohnnyB0Y on 2019/8/4.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//  主题包集合

#import <UIKit/UIKit.h>
#import "AGBaseAssets.h"
@class AGThemePack;

NS_ASSUME_NONNULL_BEGIN

/// 主题资产名
FOUNDATION_EXTERN NSString * const kAGThemeAssetsName;


@interface AGThemeAssets : AGBaseAssets

@property (nonatomic, strong, readonly) AGThemePack *currentPack;

/// 当使用跟随系统主题时，需要自行处理主题匹配问题
@property (nonatomic, copy) NSString *_Nullable (^followSystemThemeHandleBlock)(UITraitCollection *traitCollection);

#pragma mark 字体
///< 打开内容伸缩通知, default is YES
@property (nonatomic, assign) BOOL openContentSizeChangeNotification;

/// 指定默认的伸缩值作为 scale=0 参考值，default is UIContentSizeCategoryMedium
@property (nonatomic, copy) UIContentSizeCategory defaultContentSizeCategory;

///< 字体伸缩 size
@property (nonatomic, assign, readonly) NSInteger fontScaleSize;

@end

NS_ASSUME_NONNULL_END
