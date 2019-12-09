//
//  AGArrangedView.h
//
//
//  Created by JohnnyB0Y on 2019/8/27.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//  排列视图

#import <UIKit/UIKit.h>
#import "AGReusePool.h"
@class AGArrangedView;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AGArrangedViewAlignment) {
    AGArrangedViewAlignmentCenter = 0, ///< 中心对齐
    AGArrangedViewAlignmentTop, ///< 顶部对齐
    AGArrangedViewAlignmentBottom, ///< 底部对齐
    
    AGArrangedViewAlignmentLeft = AGArrangedViewAlignmentTop,///< 左对齐
    AGArrangedViewAlignmentRight = AGArrangedViewAlignmentBottom, ///< 右对齐
};

typedef NS_ENUM(NSUInteger, AGArrangedViewAxis) {
    AGArrangedViewAxisHorizontal = 0, ///< 水平布局
    AGArrangedViewAxisVertical = 1 ///< 垂直布局
};

@protocol AGArrangedViewDataSource <NSObject>
@optional
///< 返回每个标签的size
- (CGSize)ag_arrangedView:(AGArrangedView *)av sizeForArrangedSubView:(UIView *)subView atIndex:(NSInteger)idx;

///< 返回每个标签的对齐方式
- (AGArrangedViewAlignment)ag_arrangedView:(AGArrangedView *)av alignmentForArrangedSubView:(UIView *)subView atIndex:(NSInteger)idx;

@end

@protocol AGArrangedViewDelegate <NSObject>
@optional
///< 点击某个子视图
- (void)ag_arrangedView:(AGArrangedView *)av didClickArrangedSubView:(UIView *)subView atIndex:(NSInteger)idx;

///< 重排显示调用
- (void)ag_arrangedView:(AGArrangedView *)av didDisplayArrangedSubView:(UIView *)subView atIndex:(NSInteger)idx;

@end


@interface AGArrangedView : UIView


@property (nonatomic, copy, readonly, nullable) NSArray<UIView *> *displayViewArr; ///< 显示视图数组
@property (nonatomic, copy, readonly, nullable) NSArray<UIView *> *arrangedViewArr; ///< 添加排列的视图

@property (nonatomic, strong, readonly) UIImageView *bgImageView; ///< 背景视图
@property (nonatomic, assign) BOOL bgImageViewFillContentSize; ///< 背景填充内容Size，default is YES


@property (nonatomic, weak) id<AGArrangedViewDataSource> dataSource;
@property (nonatomic, weak) id<AGArrangedViewDelegate> delegate;


@property (nonatomic, strong, readonly) AGReusePool *reusePool; ///< 视图复用池
@property (nonatomic, assign) BOOL itemSizeEqually; ///< item的Size相等？default is YES
@property (nonatomic, assign) NSInteger numberOfItemForRow; ///< 每行item数，itemSizeEqually == YES 时有效，default is 3
@property (nonatomic, assign) CGFloat itemAspectRatio; ///< 宽高比，itemSizeEqually == YES 时有效，default is 1.0
@property (nonatomic, assign) BOOL itemAutoStretch; /// item 不够一行，自动拉伸? default is YES


@property (nonatomic, assign) CGFloat preferredMaxLayoutWidth; /// 最大宽度，排列时换行要用到
@property (nonatomic, assign) CGFloat itemSpaceH; ///< default is 0
@property (nonatomic, assign) CGFloat itemSpaceV; ///< default is 0
@property (nonatomic, assign) CGFloat itemMaxH; ///< Only use for AGArrangedViewAxisHorizontal, default is 20

@property (nonatomic, assign) UIEdgeInsets edgeInsets; ///< default is UIEdgeInsetsZero
@property (nonatomic, assign) AGArrangedViewAlignment alignment; ///< default is AGArrangedViewAlignmentCenter
@property (nonatomic, assign) AGArrangedViewAxis axis; ///< default is AGArrangedViewAxisHorizontal

#pragma mark 增删
- (void)ag_addArrangedSubView:(UIView *)subView; ///< 添加🏷
- (void)ag_insertArrangedSubView:(UIView *)subView atIndex:(NSUInteger)idx; ///< 插入🏷
- (void)ag_removeArrangedSubView:(UIView *)subView; ///< 移除🏷
- (void)ag_removeAllArrangedSubViews; ///< 移除所有🏷

- (void)ag_makeArrangedSubViewsSetHidden:(BOOL)hidden; ///< 隐藏所有视图

#pragma mark 重排
- (void)ag_rearrangementArrangedSubViewsToIndex:(NSUInteger)idx; ///< 重排下标idx(包含idx)前的子视图，后面的会被隐藏
- (void)ag_rearrangementNumberOfArrangedSubViews:(NSUInteger)count; ///< 重排前count个视图
- (void)ag_rearrangementCurrentArrangedSubViews:(NSArray<UIView *> *)arrangedSubViews; ///< 排列传入的视图s
- (void)ag_rearrangementArrangedSubViews; ///< 重排需要显示的子视图

@end

NS_ASSUME_NONNULL_END
