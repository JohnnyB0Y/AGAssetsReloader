//
//  AGBaseAssetsConfig.m
//  AGAssetsReloader
//
//  Created by JohnnyB0Y on 2019/12/1.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//

#import "AGBaseAssetsConfig.h"
#import "AGAssetsReloader.h"

@implementation AGBaseAssetsConfig

#pragma mark - 需要 子类 override 实现
+ (AGBaseAssets *)ag_assetsForName:(NSString *)name
{
    NSAssert(NO, @"记得子类重写！");
    return nil;
}

#pragma mark - 执行资源重载
+ (void)ag_reloadAssetsWithName:(NSString *)name forPackName:(NSString *)packName
{
    if (nil == name) return;
    
    AGBaseAssets *assets = [[AGAssetsReloader sharedInstance] ag_assetsWithName:name forModuleName:[self ag_moduleName]];
    [[AGAssetsReloader sharedInstance] ag_SetFollowSystemState:!packName forKey:[assets ag_assetsFollowSystemStateKey]];
    [[AGAssetsReloader sharedInstance] ag_reloadAssetsWithName:name forPackName:packName];
}

+ (void)ag_registerAssets:(AGBaseAssets *)assets forName:name
{
    [[AGAssetsReloader sharedInstance] ag_registerAssets:assets withName:name forModuleName:[self ag_moduleName]];
}

+ (AGBaseAssets *)ag_assetsWithName:(NSString *)name
{
    return [[AGAssetsReloader sharedInstance] ag_assetsWithName:name forModuleName:[self ag_moduleName]];
}

+ (NSString *)ag_moduleName
{
    return NSStringFromClass(self);
}

@end
