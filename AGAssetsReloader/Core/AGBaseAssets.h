//
//  AGBaseAssets.h
//  AGAssetsReloader
//
//  Created by JohnnyB0Y on 2019/12/4.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//

#import "AGAssetsReloadProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface AGBaseAssets : NSObject
<AGAssetsDelegate>

{
    NSString *_systemPackName;
}

@property (nonatomic, strong, readonly) NSMutableDictionary *packDictM;
@property (nonatomic, strong, readonly) NSHashTable *weakHashTable;

@property (nonatomic, strong) NSBundle *currentBundle;

@property (nonatomic, copy, readonly) NSString *prevPackName;
@property (nonatomic, copy, readonly) NSString *currentPackName;
@property (nonatomic, copy, readonly) NSString *defaultPackName;
@property (nonatomic, copy, readonly) NSString *systemPackName;

/// 上一个环境变量集
@property (nonatomic, strong) UITraitCollection *prevTraintCollection;

/// 判断是否当前使用中的包名
- (BOOL)ag_isUsingPackName:(NSString *)packName;


#pragma mark 子类重写
/// 需要重载资源吗？
- (BOOL)ag_neededReloadWithTraitCollection:(UITraitCollection *)traitCollection forPackName:(NSString *)packName NS_REQUIRES_SUPER;


/// 重载资源，如果需要的话
- (void)ag_reloadIfNeeded NS_REQUIRES_SUPER;


/// 初始化后做的事，如果有，重写它
- (void)ag_didInitialize NS_REQUIRES_SUPER;


/// 资产名 key
- (NSString *)ag_assetsNameKey;
/// 是否跟随系统 key
- (NSString *)ag_assetsFollowSystemStateKey;
/// 使用中的包名 key
- (NSString *)ag_assetsUsingPackNameKey;


#pragma mark 推荐初始化方法
+ (instancetype)newWithDefaultPackName:(NSString *)packName;
- (instancetype)initWithDefaultPackName:(NSString *)packName;

- (instancetype) init NS_UNAVAILABLE;
+ (instancetype) new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
