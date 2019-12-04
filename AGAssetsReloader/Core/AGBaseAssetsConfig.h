//
//  AGBaseAssetsConfig.h
//  AGAssetsReloader
//
//  Created by JohnnyB0Y on 2019/12/1.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//

#import "AGBaseAssets.h"

NS_ASSUME_NONNULL_BEGIN

@interface AGBaseAssetsConfig : NSObject

/**
思路是这样的：
1，当一个模块有自己的AGThemeAssets；
2，那么就派生一个AGThemeConfig的子类，获取当前模块的AGThemeAssets对象，可以用静态变量在内部做缓存；
3，该子类还可以用类方法定义模块用到的颜色、图片、文字等；
4，在View用到的地方，直接使用类方法获取；
*/

#pragma mark - 需要 子类 override 实现
+ (AGBaseAssets *)ag_assetsForName:(NSString *)name;


#pragma mark - 执行资源重载
/// 执行资源重载，当packName 为 nil 时，设置成跟随系统
/// @param name 资源类型
/// @param packName 包名
+ (void)ag_reloadAssetsWithName:(NSString *)name forPackName:(NSString *)packName;


+ (void)ag_registerAssets:(AGBaseAssets *)assets forName:name;


+ (AGBaseAssets *)ag_assetsWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
