//
//  AGDarkThemePackB.m
//  AGAssetsReloader
//
//  Created by JohnnyB0Y on 2019/12/1.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//

#import "AGDarkThemePackB.h"
#import <UIKit/UIKit.h>

@implementation AGDarkThemePackB

+ (instancetype)newWithPackName:(NSString *)name
{
    return [[self alloc] initWithPackName:name];
}

- (instancetype)initWithPackName:(NSString *)name
{
    self = [super initWithPackName:name];
    
    if ( self ) {
        
        // 添加元素
        self[kAGThemePackHomeCellContentTextColor] = [UIColor whiteColor];
        self[kAGThemePackHomeCellContentTextFont] = [UIFont systemFontOfSize:18];
        self[kAGThemePackHomeCellIconImageName] = @"ic_dark_icon";
    }
    
    return self;
}

@end
