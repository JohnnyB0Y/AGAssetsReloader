//
//  AGAssetsStateRecorder.m
//  AGAssetsReloader
//
//  Created by JohnnyB0Y on 2019/12/2.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//

#import "AGAssetsStateRecorder.h"

static NSString * const kAGThemeManagerUserInfo = @"kAGThemeManagerUserInfo";

@implementation AGAssetsStateRecorder

+ (NSNumber *)ag_followSystemStateForKey:(NSString *)key
{
    return [[self ag_userInfo] objectForKey:key];
}

+ (void)ag_recordFollowSystemState:(NSNumber *)state forKey:(NSString *)key
{
    NSMutableDictionary *userInfo = [self ag_userInfo];
    [userInfo setObject:state forKey:key];
    [self ag_recordUserInfo:userInfo];
}

+ (nullable NSString *)ag_usingPackNameForKey:(NSString *)key
{
    return [[self ag_userInfo] objectForKey:key];
}

+ (void)ag_recordUsingPackName:(NSString *)packName forKey:(NSString *)key
{
    if (key == nil) return;
    
    NSMutableDictionary *userInfo = [self ag_userInfo];
    if (nil == packName) {
        [userInfo removeObjectForKey:key];
    }
    else {
        [userInfo setObject:packName forKey:key];
    }
    [self ag_recordUserInfo:userInfo];
}

#pragma mark -
+ (NSMutableDictionary *)ag_userInfo
{
    NSMutableDictionary *userInfo = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:kAGThemeManagerUserInfo] mutableCopy];
    if (nil == userInfo) {
        userInfo = [NSMutableDictionary dictionary];
    }
    return userInfo;
}

+ (void)ag_recordUserInfo:(NSMutableDictionary *)userInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userInfo forKey:kAGThemeManagerUserInfo];
    [userDefaults synchronize];
}

@end
