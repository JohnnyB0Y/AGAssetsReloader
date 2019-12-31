//
//  AGAssetsModuleB.h
//  AGAssetsReloader
//
//  Created by JohnnyB0Y on 2019/12/1.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//

#import "AGBaseAssetsBox.h"
#import "AGAssetsConfig+AGThemeAssets.h"
#import "AGAssetsConfig+AGLanguageAssets.h"

NS_ASSUME_NONNULL_BEGIN

@interface AGAssetsModuleB : AGBaseAssetsBox

+ (void)reloadThemeAssetsForPackName:(NSString *)packName;

+ (nullable UIColor *)colorForContentText;

+ (nullable UIFont *)fontForContentText;

+ (nullable UIImage *)imageForIcon;

@end

NS_ASSUME_NONNULL_END
