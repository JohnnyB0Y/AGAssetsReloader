//
//  AGReusePool.m
//  
//
//  Created by JohnnyB0Y on 2019/10/9.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//  对象复用池

#import "AGReusePool.h"

@interface AGReusePool ()

@property (nonatomic, strong) NSMutableSet *reuseViewPool; ///< 对象池
@property (nonatomic, strong) NSMutableSet *usingViewPool; ///< 使用中的对象池

@end

@implementation AGReusePool {
    NSInteger _tag;
}

- (void)ag_registerGenerateUsingBlock:(AGReusePoolGenerateBlock)block
{
    _generateBlock = [block copy];
}

- (id)ag_dequeueAnyObj
{
    id anyObj = [self.reuseViewPool anyObject];
    
    if (nil == anyObj) {
        if (_generateBlock) {
            anyObj = _generateBlock(_tag++);
        }
    }
    else {
        [self.reuseViewPool removeObject:anyObj];
    }
    
    if (anyObj) {
        [self.usingViewPool addObject:anyObj];
    }
    
    return anyObj;
}

- (void)ag_giveBack:(id)anyObj
{
    if (anyObj) {
        [self.usingViewPool removeObject:anyObj];
        [self.reuseViewPool addObject:anyObj];
    }
}

- (void)ag_giveBackAll
{
    [self.usingViewPool enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self.reuseViewPool addObject:obj];
    }];
    [self.usingViewPool removeAllObjects];
}

#pragma mark - ----------- Getter Methods -----------
- (NSMutableSet *)reuseViewPool
{
    if (nil == _reuseViewPool) {
        _reuseViewPool = [NSMutableSet set];
    }
    return _reuseViewPool;
}

- (NSMutableSet *)usingViewPool
{
    if (nil == _usingViewPool) {
        _usingViewPool = [NSMutableSet set];
    }
    return _usingViewPool;
}

- (NSUInteger)numberOfUsingObj
{
    return _usingViewPool.count;
}

@end
