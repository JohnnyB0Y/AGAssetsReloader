//
//  AGArrangedView.m
//  
//
//  Created by JohnnyB0Y on 2019/8/27.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//

#import "AGArrangedView.h"
#import <Masonry.h>

@interface AGArrangedView ()

@property (nonatomic, strong, readwrite) AGReusePool *reusePool; /// 视图复用池
@property (nonatomic, strong) NSMutableArray<UIView *> *arrangedViewArrM;

@property (nonatomic, strong, readwrite) UIImageView *bgImageView;

@end

@implementation AGArrangedView {
    
    struct AGResponeMethods {
        unsigned int alignmentForArrangedSubView : 1;
        unsigned int sizeForArrangedSubView      : 1;
        unsigned int didClickArrangedSubView     : 1;
        unsigned int displayArrangedSubView      : 1;
    } _responeMethod;
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _itemSpaceH = 0;
        _itemSpaceV = 0;
        _edgeInsets = UIEdgeInsetsZero;
        _itemMaxH = 20;
        _alignment = AGArrangedViewAlignmentCenter;
        _responeMethod.alignmentForArrangedSubView = NO;
        _responeMethod.sizeForArrangedSubView = NO;
        _responeMethod.didClickArrangedSubView = NO;
        _responeMethod.displayArrangedSubView = NO;
        _itemSizeEqually = YES;
        _itemAutoStretch = YES;
        _numberOfItemForRow = 3;
        _axis = AGArrangedViewAxisHorizontal;
        _bgImageViewFillContentSize = YES;
        _itemAspectRatio = 1.0;
    }
    
    return self;
}

- (void)ag_addArrangedSubView:(UIView *)lv
{
    if ([lv isKindOfClass:[UIView class]]) {
        [self.arrangedViewArrM addObject:lv];
        if (lv.superview != self) {
            [self addSubview:lv];
        }
    }
}

- (void)ag_insertArrangedSubView:(UIView *)lv atIndex:(NSUInteger)idx
{
    if ([lv isKindOfClass:[UIView class]]) {
        
        if ([self.arrangedViewArrM containsObject:lv]) {
            [self.arrangedViewArrM removeObject:lv];
        }
        
        idx < _arrangedViewArrM.count ? [self.arrangedViewArrM insertObject:lv atIndex:idx] : [self.arrangedViewArrM addObject:lv];
        
        if (lv.superview != self) {
            [self addSubview:lv];
        }
    }
}

- (void)ag_removeArrangedSubView:(UIView *)lv
{
    if ([lv isKindOfClass:[UIView class]]) {
        [self.arrangedViewArrM removeObject:lv];
        if (lv.superview == self) {
            [lv removeFromSuperview];
        }
    }
}

- (void)ag_removeAllArrangedSubViews
{
    for (UIView *lv in self.arrangedViewArrM) {
        [self ag_removeArrangedSubView:lv];
    }
}

- (void)ag_rearrangementArrangedSubViewsToIndex:(NSUInteger)idx
{
    NSUInteger needCount = idx+1 - _arrangedViewArrM.count;
    if (_reusePool.generateBlock && needCount > 0) { // 添加视图
        for (NSInteger i = 0; i<needCount; i++) {
            [self ag_addArrangedSubView:[_reusePool ag_dequeueAnyObj]];
        }
    }
    
    [_arrangedViewArrM enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger _idx, BOOL *stop) {
        obj.hidden = _idx > idx;
    }];
    
    [self ag_rearrangementArrangedSubViews];
}

- (void)ag_rearrangementNumberOfArrangedSubViews:(NSUInteger)count
{
    [self ag_rearrangementArrangedSubViewsToIndex:count-1];
}

- (void)ag_rearrangementCurrentArrangedSubViews:(NSArray<UIView *> *)arrangedSubViews
{
    if (arrangedSubViews.count <= 0) return;
    [self ag_makeArrangedSubViewsSetHidden:YES];
    
    [arrangedSubViews enumerateObjectsUsingBlock:^(UIView *lv, NSUInteger idx, BOOL *stop) {
        if (lv.superview != self) {
            [self addSubview:lv];
        }
    }];
    
    _displayViewArr = [arrangedSubViews copy];
    
    [self rearrangementSubView];
}

- (void)ag_rearrangementArrangedSubViews
{
    if (_arrangedViewArrM.count <= 0) return;
    
    NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:_arrangedViewArrM.count];
    [_arrangedViewArrM enumerateObjectsUsingBlock:^(UIView *subView, NSUInteger idx, BOOL *stop) {
        if (NO == subView.hidden) {
            [arrM addObject:subView];
        }
    }];
    
    _displayViewArr = [arrM copy];
    
    // 重排子视图
    [self rearrangementSubView];
}

- (void)ag_makeArrangedSubViewsSetHidden:(BOOL)hidden
{
    [self.arrangedViewArrM enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        [obj setHidden:hidden];
    }];
}

#pragma mark - ---------- Private Methods ----------
- (CGFloat)currentYWithItemH:(CGFloat)itemH pointY:(CGFloat)pointY forAlignment:(AGArrangedViewAlignment)alignment
{
    // 垂直布局
    if (self.axis == AGArrangedViewAxisVertical) {
        return pointY + self.edgeInsets.top;
    }
    
    // 水平布局
    switch (alignment) {
        case AGArrangedViewAlignmentBottom: {
            return self.itemMaxH - itemH + self.edgeInsets.top + pointY;
            
        } break;
            
        case AGArrangedViewAlignmentTop: {
            return self.edgeInsets.top + pointY;
            
        } break;
            
        default: {
            return fabs(self.itemMaxH - itemH) * 0.5 + self.edgeInsets.top + pointY;
        } break;
    }
    
}

- (CGFloat)currentXWithItemW:(CGFloat)itemW pointX:(CGFloat)pointX forAlignment:(AGArrangedViewAlignment)alignment
{
    // 水平布局
    if (self.axis == AGArrangedViewAxisHorizontal) {
        return self.edgeInsets.left + pointX;
    }
    
    // 垂直布局
    switch (alignment) {
        case AGArrangedViewAlignmentLeft: {
            return self.edgeInsets.left;
            
        } break;
            
        case AGArrangedViewAlignmentRight: {
            return self.frame.size.width - (self.edgeInsets.left + itemW + self.edgeInsets.right);
            
        } break;
            
        default: {
            return fabs(self.frame.size.width - itemW) * 0.5;
        } break;
    }
}

- (void)updateSizeIfNeeded:(CGSize)size
{
    if (size.height != self.frame.size.height) {
        
        CGRect frame = self.frame;
        frame.size.height = size.height;
        self.frame = frame;
    }
}

- (void)rearrangementSubView
{
    // 排列子视图
    [self removeArrangedViewsConstraints];
    
    if (self.itemSizeEqually) {
        [self layoutSizeEquallyArrangedViews];
    }
    else {
        [self layoutSizeCustomArrangedViews];
    }
}

- (void)layoutSizeCustomArrangedViews
{
    NSInteger count = _displayViewArr.count;
    CGFloat contentW = self.preferredMaxLayoutWidth;
    __block CGFloat x = 0;
    __block CGFloat y = 0;
    __block CGFloat maxX = 0;
    __block CGSize itemS;
    __block UIView *rightView;
    id<AGArrangedViewDataSource> strongDataSource = _dataSource;
    [_displayViewArr enumerateObjectsUsingBlock:^(UIView *subView, NSUInteger idx, BOOL *stop) {
        
        // 对齐形式？
        AGArrangedViewAlignment alignment = self.alignment;
        if (self->_responeMethod.alignmentForArrangedSubView) {
            alignment = [strongDataSource ag_arrangedView:self alignmentForArrangedSubView:subView atIndex:idx];
        }
        
        // 元素Size
        if (self->_responeMethod.sizeForArrangedSubView) {
            itemS = [strongDataSource ag_arrangedView:self sizeForArrangedSubView:subView atIndex:idx];
        }
        else {
            itemS = [subView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        }
        
        // 水平布局时，判断是否换行
        if (self.axis == AGArrangedViewAxisHorizontal && ((x+itemS.width) > contentW)) {
            // 换行
            y += (self.itemSpaceV + self.itemMaxH);
            x = 0;
        }
        
        CGFloat curY = [self currentYWithItemH:itemS.height pointY:y forAlignment:alignment];
        CGFloat curX = [self currentXWithItemW:itemS.width pointX:x forAlignment:alignment];
        [subView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(curX);
            make.top.mas_equalTo(curY);
            make.size.mas_equalTo(itemS);
            if (idx == count - 1) { // 最后一个
                make.bottom.mas_equalTo(-self.edgeInsets.bottom);
            }
        }];
        
        if (self.axis == AGArrangedViewAxisVertical) {
            // 记录下一个Y的位置
            y += (self.itemSpaceV + self.itemMaxH);
        }
        else {
            // 记录下一个X的位置
            x += (itemS.width + self.itemSpaceH);
        }
        
        if (maxX < curX + itemS.width) {
            maxX = curX + itemS.width;
            rightView = subView; // 记录最右视图
        }
        
        // 即将显示
        if (self->_responeMethod.displayArrangedSubView) {
            [self.delegate ag_arrangedView:self didDisplayArrangedSubView:subView atIndex:idx];
        }
    }];
    
    if (count > 0) {
        [self.bgImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.mas_equalTo(0);
            if (self.bgImageViewFillContentSize) {
                make.right.mas_equalTo(0);
            }
            else {
                make.right.mas_equalTo(rightView).mas_equalTo(self.edgeInsets.right);
            }
        }];
    }
}

- (void)layoutSizeEquallyArrangedViews
{
    NSInteger count = _displayViewArr.count;
    NSInteger col = self.numberOfItemForRow;
    NSInteger row = count % col == 0 ? count / col : count / col + 1;
    __block NSInteger curRow = 1;
    __block UIView *rightView;
    __block UIView *lastView;
    [_displayViewArr enumerateObjectsUsingBlock:^(UIView *subView, NSUInteger idx, BOOL *stop) {
        if (count == 1 || col <= 1 || self.axis == AGArrangedViewAxisVertical) { // 垂直
            if (lastView) { // 下一个
                [subView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self.edgeInsets.left);
                    make.right.mas_equalTo(-self.edgeInsets.right);
                    make.top.mas_equalTo(lastView.mas_bottom).mas_offset(self.itemSpaceV);
                    if (count == idx+1) { // 最后一个
                        make.bottom.mas_equalTo(-self.edgeInsets.bottom);
                    }
                    // size 是一样的
                    make.size.mas_equalTo(lastView);
                }];
            }
            else { // 第一个
                rightView = subView;
                [subView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self.edgeInsets.left);
                    make.right.mas_equalTo(-self.edgeInsets.right);
                    make.top.mas_equalTo(self.edgeInsets.top);
                    make.width.mas_equalTo(subView.mas_height).multipliedBy(self.itemAspectRatio);
                    if (count == 1) { // 只有一个
                        make.bottom.mas_equalTo(-self.edgeInsets.bottom);
                    }
                }];
            }
        }
        else { // 水平
            if (lastView) { // 下一个
                [subView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    if (idx%col == 0) { // 换行
                        make.left.mas_equalTo(self.edgeInsets.left);
                        make.top.mas_equalTo(lastView.mas_bottom).mas_offset(self.itemSpaceH);
                        
                        if (row == ++curRow) { // 最后一行
                            make.bottom.mas_equalTo(-self.edgeInsets.bottom);
                        }
                    }
                    else {
                        make.left.mas_equalTo(lastView.mas_right).mas_offset(self.itemSpaceH);
                        make.top.mas_equalTo(lastView);
                        
                        if (curRow == 1) { // 第一行, 最后一个
                            if (self.itemAutoStretch && (count < col) && (idx == count-1)) {
                                make.right.mas_equalTo(-self.edgeInsets.right);
                                rightView = subView;
                            }
                            else if (idx == col-1) {
                                make.right.mas_equalTo(-self.edgeInsets.right);
                                rightView = subView;
                            }
                        }
                    }
                    
                    make.size.mas_equalTo(lastView);
                }];
            }
            else { // 第一个
                [subView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self.edgeInsets.left);
                    make.top.mas_equalTo(self.edgeInsets.top);
                    make.width.mas_equalTo(subView.mas_height).multipliedBy(self.itemAspectRatio);
                    
                    if (count <= col) { // 只有一行
                        make.bottom.mas_equalTo(-self.edgeInsets.bottom);
                    }
                }];
            }
        }
        
        // 记录
        lastView = subView;
        
        // 即将显示
        if (self->_responeMethod.displayArrangedSubView) {
            [self.delegate ag_arrangedView:self didDisplayArrangedSubView:subView atIndex:idx];
        }
    }];
    
    if (count > 0) {
        [self.bgImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.mas_equalTo(0);
            if (self.bgImageViewFillContentSize) {
                make.right.mas_equalTo(0);
            }
            else {
                make.right.mas_equalTo(rightView).mas_equalTo(self.edgeInsets.right);
            }
        }];
    }
    
}

- (void)removeArrangedViewsConstraints
{
    [self.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint *obj, NSUInteger idx, BOOL *stop) {
        if (obj.firstItem != self) {
            [self removeConstraint:obj];
        }
    }];
}

#pragma mark - ----------- Event Methods -----------
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_responeMethod.didClickArrangedSubView) {
        UITouch *t = [touches anyObject];
        CGPoint point = [t locationInView:t.view];
        
        [_displayViewArr enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
            if (! obj.hidden && CGRectContainsPoint(obj.frame, point)) {
                [self.delegate ag_arrangedView:self didClickArrangedSubView:obj atIndex:idx];
            }
        }];
    }
    else {
        [super touchesBegan:touches withEvent:event];
    }
}

#pragma mark - ----------- Getter Methods -----------
- (NSMutableArray<UIView *> *)arrangedViewArrM
{
    if (nil == _arrangedViewArrM) {
        _arrangedViewArrM = [NSMutableArray arrayWithCapacity:10];
    }
    return _arrangedViewArrM;
}

- (UIImageView *)bgImageView
{
    if (nil == _bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        [self insertSubview:_bgImageView atIndex:0];
    }
    return _bgImageView;
}

- (NSArray<UIView *> *)arrangedViewArr
{
    return [_arrangedViewArrM copy];
}

- (AGReusePool *)reusePool
{
    if ( nil == _reusePool ) {
        _reusePool = [AGReusePool new];
    }
    return _reusePool;
}

#pragma mark - ----------- Setter Methods -----------
- (void)setDataSource:(id<AGArrangedViewDataSource>)dataSource
{
    _dataSource = dataSource;
    
    _responeMethod.sizeForArrangedSubView = [_dataSource respondsToSelector:@selector(ag_arrangedView:sizeForArrangedSubView:atIndex:)];
    _responeMethod.alignmentForArrangedSubView = [_dataSource respondsToSelector:@selector(ag_arrangedView:alignmentForArrangedSubView:atIndex:)];
    
    _itemSizeEqually = ! _responeMethod.sizeForArrangedSubView;
}

- (void)setDelegate:(id<AGArrangedViewDelegate>)delegate
{
    _delegate = delegate;
    
    _responeMethod.didClickArrangedSubView = [_delegate respondsToSelector:@selector(ag_arrangedView:didClickArrangedSubView:atIndex:)];
    _responeMethod.displayArrangedSubView = [_delegate respondsToSelector:@selector(ag_arrangedView:didDisplayArrangedSubView:atIndex:)];
}

@end
