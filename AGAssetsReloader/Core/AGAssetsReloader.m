//
//  AGAssetsReloader.m
//  
//
//  Created by JohnnyB0Y on 2019/8/4.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//

#import "AGAssetsReloader.h"
#import "AGAssetsStateRecorder.h"
#import "AGBaseAssets.h"

@interface AGAssetsReloader ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableDictionary *> *assetsCollections;

@property (nonatomic, strong) NSMutableDictionary *assetsStates;

@end

@implementation AGAssetsReloader
#pragma mark - ----------- Life Cycle -----------
+ (instancetype)sharedInstance
{
    static AGAssetsReloader *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
#ifdef DEBUG
        instance.openLog = YES;
#else
#endif
    });
    return instance;
}

#pragma mark - ---------- Public Methods ----------
#pragma mark 注册资源集合
- (void)ag_registerAssets:(AGBaseAssets *)assets withName:(NSString *)name forModuleName:(NSString *)moduleName
{
    if (name == nil || moduleName == nil) {
        return;
    }
    
    NSMutableDictionary *dictM = self.assetsCollections[name];
    if (nil == dictM) {
        dictM = [NSMutableDictionary dictionaryWithCapacity:24];
        self.assetsCollections[name] = dictM;
    }
    
    dictM[moduleName] = assets;
}


- (AGBaseAssets *)ag_assetsWithName:(NSString *)name forModuleName:(NSString *)moduleName
{
    if (name == nil || moduleName == nil) {
        return nil;
    }
    
    return self.assetsCollections[name][moduleName];
}

#pragma mark 执行资源重载
- (void)ag_reloadAssetsWithName:(NSString *)name forPackName:(NSString *)packName
{
    if (name == nil) {
        return;
    }
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    
    __block NSString *usingPackNameKey;
    [self.assetsCollections[name] enumerateKeysAndObjectsUsingBlock:^(id key, AGBaseAssets *assets, BOOL *stop) {
        if ([assets ag_neededReloadWithTraitCollection:[UIScreen mainScreen].traitCollection forPackName:packName]) {
            [assets ag_reloadIfNeeded];
            usingPackNameKey = [assets ag_assetsUsingPackNameKey];
        }
    }];
    
    
    [self ag_setUsingPackName:packName forKey:usingPackNameKey];
    
    CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
    
    if ( _openLog ) {
        NSLog(@"Execute reload %@ assets in %f ms.", name, linkTime * 1000.0);
    }
}

#pragma mark - ----------- Getter Setter Methods -----------
- (NSMutableDictionary<NSString *,NSMutableDictionary *> *)assetsCollections
{
    if ( nil == _assetsCollections ) {
        _assetsCollections = [NSMutableDictionary dictionaryWithCapacity:8];
    }
    return _assetsCollections;
}

- (NSMutableDictionary *)assetsStates
{
    if ( nil == _assetsStates ) {
        _assetsStates = [NSMutableDictionary dictionaryWithCapacity:16];
    }
    return _assetsStates;
}

- (NSString *)ag_usingPackNameForKey:(NSString *)key
{
    if (nil == key) return nil;
    
    NSString *packName = self.assetsStates[key];
    if (nil == packName) {
        // 本地取出
        packName = [AGAssetsStateRecorder ag_usingPackNameForKey:key];
        if (nil != packName) {
            // 本地有数据
            self.assetsStates[key] = packName;
        }
    }
    return packName;
}

- (BOOL)ag_followSystemStateForKey:(NSString *)key
{
    if (nil == key) return YES;
    
    NSNumber *state = self.assetsStates[key];
    if (nil == state) {
        // 本地取出
        state = [AGAssetsStateRecorder ag_followSystemStateForKey:key];
        if (nil == state) {
            // 本地没有数据
            self.assetsStates[key] = @(YES);
            [AGAssetsStateRecorder ag_recordFollowSystemState:@(YES) forKey:key];
            return YES;
        }
        
        // 本地有数据
        self.assetsStates[key] = state;
        return [state boolValue];
    }
    
    return [state boolValue];
}

- (void)ag_setUsingPackName:(NSString *)packName forKey:(NSString *)key
{
    if (nil == key) return;
    
    if (![[self ag_usingPackNameForKey:key] isEqualToString:packName]) {
        self.assetsStates[key] = packName;
        [AGAssetsStateRecorder ag_recordUsingPackName:packName forKey:key];
    }
}

- (void)ag_SetFollowSystemState:(BOOL)state forKey:(NSString *)key
{
    if (nil == key) return;
    
    if ([self ag_followSystemStateForKey:key] != state) {
        self.assetsStates[key] = @(state);
        [AGAssetsStateRecorder ag_recordFollowSystemState:@(state) forKey:key];
    }
}

@end
