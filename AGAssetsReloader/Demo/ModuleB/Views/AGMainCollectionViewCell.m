//
//  AGMainCollectionViewCell.m
//  
//
//  Created by JohnnyB0Y on 2019/8/4.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//

#import "AGMainCollectionViewCell.h"
#import "AGAssetsModuleB.h"
#import "AGArrangedView.h"
#import <Masonry.h>

@interface AGMainCollectionViewCell ()
<AGArrangedViewDelegate>

@property (nonatomic, strong) AGArrangedView *arrangedImageView;

@end

@implementation AGMainCollectionViewCell

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if ( self ) {
        [self setup];
    }
    
    return self;
}

- (void) setup
{
    [self.contentView addSubview:self.arrangedImageView];
    
    [self.arrangedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    [AGAssetsModuleB ag_addAndExecuteThemeReloadResponder:self];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];
    
    self.backgroundColor = [AGAssetsModuleB colorForContentText];

    // 一般我们不会让这么多图片跟随主题切换
    [self.arrangedImageView ag_rearrangementNumberOfArrangedSubViews:9];
}

#pragma mark
- (void)ag_arrangedView:(AGArrangedView *)av didDisplayArrangedSubView:(UIImageView *)subView atIndex:(NSInteger)idx
{
    // 一般我们不会让这么多图片跟随主题切换
    subView.image = [AGAssetsModuleB imageForIcon];
}

#pragma mark - ----------- Getter Methods -----------
- (AGArrangedView *)arrangedImageView
{
    if ( nil == _arrangedImageView ) {
        _arrangedImageView = [AGArrangedView new];
        _arrangedImageView.delegate = self;
        _arrangedImageView.itemSpaceH = 2;
        _arrangedImageView.itemSpaceV = 2;
        _arrangedImageView.backgroundColor = [UIColor brownColor];
        
        [_arrangedImageView.reusePool ag_registerGenerateUsingBlock:^id _Nonnull(NSInteger tag) {
            
            UIImageView *imageView = [UIImageView new];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            return imageView;
            
        }];
    }
    return _arrangedImageView;
}

@end
