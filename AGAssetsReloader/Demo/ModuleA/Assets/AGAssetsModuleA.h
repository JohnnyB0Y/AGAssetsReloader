//
//  AGAssetsModuleA.h
//  AGAssetsReloader
//
//  Created by JohnnyB0Y on 2019/12/1.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//

#import "AGBaseAssetsConfig.h"
#import "AGAssetsConfig+AGThemeAssets.h"
#import "AGAssetsConfig+AGLanguageAssets.h"

NS_ASSUME_NONNULL_BEGIN

@interface AGAssetsModuleA : AGBaseAssetsConfig

+ (void)reloadThemeAssetsForPackName:(NSString *)packName;
+ (void)reloadLanguageAssetsForPackName:(NSString *)packName;

@end

@interface AGAssetsModuleA (UIImage)

+ (nullable UIImage *)imageForIcon;

@end

@interface AGAssetsModuleA (UIFont)

+ (nullable UIFont *)fontForContentText;

@end

@interface AGAssetsModuleA (Localization)

+ (nullable NSString *)localizedCellTitle;

+ (nullable NSString *)localizedCellText;

@end

@interface AGAssetsModuleA (UIColor)

+ (nullable UIColor *)colorForContentText;

@end

NS_ASSUME_NONNULL_END
