//
//  AGReusePool.h
//  
//
//  Created by JohnnyB0Y on 2019/10/9.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//  对象复用池

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef id _Nonnull(^AGReusePoolGenerateBlock)(NSInteger tag);

@interface AGReusePool : NSObject

@property (nonatomic, copy, readonly) AGReusePoolGenerateBlock generateBlock;
@property (nonatomic, assign, readonly) NSUInteger numberOfUsingObj;

- (void)ag_registerGenerateUsingBlock:(AGReusePoolGenerateBlock)block;

- (id)ag_dequeueAnyObj;
- (void)ag_giveBack:(id)anyObj;
- (void)ag_giveBackAll;

@end

NS_ASSUME_NONNULL_END
