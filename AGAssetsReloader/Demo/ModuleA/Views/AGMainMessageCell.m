//
//  AGMainMessageCell.m
//  
//
//  Created by JohnnyB0Y on 2019/8/4.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//

#import "AGMainMessageCell.h"
#import "AGAssetsModuleA.h"

@interface AGMainMessageCell ()

@end

@implementation AGMainMessageCell

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
    self.textLabel.numberOfLines = 0;
    self.backgroundColor = [UIColor clearColor];
//    self.textLabel.text = @"MIT License \n\nA short and simple permissive license with conditions only requiring preservation of copyright and license notices. Licensed works, modifications, and larger works may be distributed under different terms and without source code.";
    
    
    [AGAssetsModuleA ag_addAndExecuteThemeReloadResponder:self];
    [AGAssetsModuleA ag_addLanguageReloadResponder:self];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];
    
    self.textLabel.font = [AGAssetsModuleA fontForContentText];
    self.textLabel.textColor = [AGAssetsModuleA colorForContentText];
    
    NSString *title = [AGAssetsModuleA localizedCellTitle];
    NSString *text = [AGAssetsModuleA localizedCellText];
    self.textLabel.text = [NSString stringWithFormat:@"%@ \n\nA %@", title, text];
    
}

@end
