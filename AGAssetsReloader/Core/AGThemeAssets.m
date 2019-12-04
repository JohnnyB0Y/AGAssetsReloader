//
//  AGThemeAssets.m
//  
//
//  Created by JohnnyB0Y on 2019/8/4.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//

#import "AGThemeAssets.h"
#import "AGThemePack.h"
#import "AGAssetsReloader.h"

/// 主题是否跟随系统
FOUNDATION_EXTERN NSString * const kAGThemeFollowSystemState;
/// 使用中的主题包名
FOUNDATION_EXTERN NSString * const kAGThemeUsingPackName;

@interface AGThemeAssets ()

@property (nonatomic, copy) UIContentSizeCategory prevContentSizeCategory;
@property (nonatomic, copy) UIContentSizeCategory currentContentSizeCategory;
@property (nonatomic, assign) NSInteger fontScaleSize;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *fontSizeOffsetDictM;
@property (nonatomic, strong) UITraitCollection *systemTraitCollection; /// 记录系统模式是否切换

@end

@implementation AGThemeAssets
#pragma mark - ----------- Life Cycle -----------
- (void)ag_didInitialize
{
    [super ag_didInitialize];
    _prevContentSizeCategory = @"";
    _openContentSizeChangeNotification = YES;
}

#pragma mark - ---------- Public Methods ----------
- (BOOL)ag_neededReloadWithTraitCollection:(UITraitCollection *)traitCollection forPackName:(NSString *)packName
{
    if ([AGAssetsReloader.sharedInstance ag_followSystemStateForKey:kAGThemeFollowSystemState]) { // 跟随系统模式
        return ! [self ag_isUsingPackName:self.systemPackName];
    }
    return [super ag_neededReloadWithTraitCollection:traitCollection forPackName:packName];
}

#pragma mark - ---------- Setter Methods ----------
- (void)setFollowSystemThemeHandleBlock:(NSString * _Nullable (^)(UITraitCollection * _Nonnull))followSystemThemeHandleBlock
{
    _followSystemThemeHandleBlock = [followSystemThemeHandleBlock copy];
    if (_followSystemThemeHandleBlock) {
        self->_systemPackName = _followSystemThemeHandleBlock([UIScreen mainScreen].traitCollection);
    }
}

#pragma mark - ----------- Getter Methods -----------
- (AGThemePack *)currentPack
{
    return [self.packDictM objectForKey:self.currentPackName];
}

- (UIContentSizeCategory)defaultContentSizeCategory
{
    if ( nil == _defaultContentSizeCategory ) {
        _defaultContentSizeCategory = UIContentSizeCategoryMedium;
    }
    return _defaultContentSizeCategory;
}

- (NSString *)systemPackName
{
    if (self.systemTraitCollection != [UIScreen mainScreen].traitCollection) {
        if (_followSystemThemeHandleBlock) {
            _systemPackName = _followSystemThemeHandleBlock([UIScreen mainScreen].traitCollection);
        }
        self.systemTraitCollection = [UIScreen mainScreen].traitCollection;
    }
    return _systemPackName;
}

- (NSInteger)fontScaleSize
{
    UIContentSizeCategory contentSizeCategory = [UIApplication sharedApplication].preferredContentSizeCategory;
    if ( ! [_currentContentSizeCategory isEqualToString:contentSizeCategory] ) {
        _prevContentSizeCategory = _currentContentSizeCategory;
        _currentContentSizeCategory = contentSizeCategory;
        
        if ( _openContentSizeChangeNotification ) {
            NSInteger defaultSizeOffset = self.fontSizeOffsetDictM[self.defaultContentSizeCategory].integerValue;
            NSInteger currentSizeOffset = self.fontSizeOffsetDictM[_currentContentSizeCategory].integerValue;
            _fontScaleSize = currentSizeOffset - defaultSizeOffset;
        }
    }
    return _fontScaleSize;
}

- (NSMutableDictionary *)fontSizeOffsetDictM
{
    if ( nil == _fontSizeOffsetDictM ) {
        _fontSizeOffsetDictM = [NSMutableDictionary dictionaryWithCapacity:15];
        if (@available(iOS 10.0, *)) {
            _fontSizeOffsetDictM[UIContentSizeCategoryUnspecified] = @(2); // 未定义，就默认吧！
        }
        _fontSizeOffsetDictM[UIContentSizeCategoryExtraSmall] = @(0); // XS (0), offset 0
        _fontSizeOffsetDictM[UIContentSizeCategorySmall] = @(1); // S (1), offset 1
        _fontSizeOffsetDictM[UIContentSizeCategoryMedium] = @(2);// M (1), offset 2, default
        _fontSizeOffsetDictM[UIContentSizeCategoryLarge] = @(3); // L (1), offset 3
        _fontSizeOffsetDictM[UIContentSizeCategoryExtraLarge] = @(5); // XL (2), offset 5
        _fontSizeOffsetDictM[UIContentSizeCategoryExtraExtraLarge] = @(7); // XXL (2), offset 7
        _fontSizeOffsetDictM[UIContentSizeCategoryExtraExtraExtraLarge] = @(9); // XXXL (2), offset 9
        
        _fontSizeOffsetDictM[UIContentSizeCategoryAccessibilityMedium] = @(14); // AM (5), offset 14
        _fontSizeOffsetDictM[UIContentSizeCategoryAccessibilityLarge] = @(19); // AL (5), offset 19
        _fontSizeOffsetDictM[UIContentSizeCategoryAccessibilityExtraLarge] = @(26); // AXL (7), offset 26
        _fontSizeOffsetDictM[UIContentSizeCategoryAccessibilityExtraExtraLarge] = @(33); // AXXL (7), offset 33
        _fontSizeOffsetDictM[UIContentSizeCategoryAccessibilityExtraExtraExtraLarge] = @(39); // AXXXL (6), offset 39
        
    }
    return _fontSizeOffsetDictM;
}

/// 资产名 key
- (NSString *)ag_assetsNameKey
{
    return kAGThemeAssetsName;
}

/// 是否跟随系统 key
- (NSString *)ag_assetsFollowSystemStateKey
{
    return kAGThemeFollowSystemState;
}

/// 使用中的包名 key
- (NSString *)ag_assetsUsingPackNameKey
{
    return kAGThemeUsingPackName;
}

@end

NSString * const kAGThemeAssetsName = @"kAGThemeAssetsName";
/// 主题是否跟随系统
NSString * const kAGThemeFollowSystemState = @"kAGThemeFollowSystemState";
/// 使用中的主题包名
NSString * const kAGThemeUsingPackName = @"kAGThemeUsingPackName";
