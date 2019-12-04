//
//  AGMainImageCell.m
//  
//
//  Created by JohnnyB0Y on 2019/8/4.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//

#import "AGMainImageCell.h"
#import "AGAssetsModuleA.h"

@interface AGMainImageCell ()

@end

@implementation AGMainImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if ( self ) {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    // 根据主题，配置好
    [AGAssetsModuleA ag_addThemeReloadResponder:self];
    
    // 根据主题，直接执行
    [AGAssetsModuleA ag_executeThemeReloadResponder:self];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];
    
    self.imageView.image = [AGAssetsModuleA imageForIcon];
}

@end
