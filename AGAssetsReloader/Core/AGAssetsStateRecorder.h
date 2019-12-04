//
//  AGAssetsStateRecorder.h
//  AGAssetsReloader
//
//  Created by JohnnyB0Y on 2019/12/2.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AGAssetsStateRecorder : NSObject

+ (NSNumber *)ag_followSystemStateForKey:(NSString *)key;
+ (void)ag_recordFollowSystemState:(NSNumber *)state forKey:(NSString *)key;

+ (nullable NSString *)ag_usingPackNameForKey:(NSString *)key;
+ (void)ag_recordUsingPackName:(NSString *)packName forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
