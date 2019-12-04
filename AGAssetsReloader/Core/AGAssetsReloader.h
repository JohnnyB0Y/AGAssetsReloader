//
//  AGAssetsReloader.h
//  
//
//  Created by JohnnyB0Y on 2019/8/4.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AGBaseAssets;

NS_ASSUME_NONNULL_BEGIN

@interface AGAssetsReloader : NSObject

@property (class, readonly) AGAssetsReloader *sharedInstance;


#pragma mark 持久化记录📝
- (BOOL)ag_followSystemStateForKey:(NSString *)key;
- (void)ag_SetFollowSystemState:(BOOL)state forKey:(NSString *)key;

- (nullable NSString *)ag_usingPackNameForKey:(NSString *)key;
- (void)ag_setUsingPackName:(NSString *)packName forKey:(NSString *)key;


#pragma mark 注册资源集合

/// 注册资源集合
/// @param assets 资源集合
/// @param name 资源类型
/// @param moduleName 存储资源集合的 key
- (void)ag_registerAssets:(nullable AGBaseAssets *)assets
                 withName:(NSString *)name
            forModuleName:(NSString *)moduleName;


/// 取出资源集合
/// @param name 资源类型
/// @param moduleName 存储资源集合的 key
- (nullable AGBaseAssets *)ag_assetsWithName:(NSString *)name forModuleName:(NSString *)moduleName;

#pragma mark 执行资源重载

/// 重载资源集合
/// @param name 资源类型
/// @param packName 包名
- (void)ag_reloadAssetsWithName:(NSString *)name forPackName:(NSString *)packName;


#pragma mark -
/// 打开调试
@property (nonatomic, assign) BOOL openLog;


- (instancetype) init NS_UNAVAILABLE;
+ (instancetype) new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
