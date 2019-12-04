//
//  AGBaseAssets.m
//  AGAssetsReloader
//
//  Created by JohnnyB0Y on 2019/12/4.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//

#import "AGBaseAssets.h"
#import "AGAssetsReloader.h"

@interface AGBaseAssets ()

@property (nonatomic, strong) NSMutableDictionary *packDictM;
@property (nonatomic, strong) NSHashTable *weakHashTable;

@property (nonatomic, assign) BOOL firstLoad;

@end

@implementation AGBaseAssets
@synthesize currentPackName = _currentPackName;

#pragma mark - ----------- Life Cycle -----------
+ (instancetype)newWithDefaultPackName:(NSString *)packName
{
    return [[self alloc] initWithDefaultPackName:packName];
}

- (instancetype)initWithDefaultPackName:(NSString *)packName
{
    self = [super init];
    
    if ( self ) {
        NSParameterAssert(packName);
        _defaultPackName = [packName copy];
        _currentPackName = [AGAssetsReloader.sharedInstance ag_usingPackNameForKey:[self ag_assetsUsingPackNameKey]] ?: _defaultPackName;
        [self ag_didInitialize];
    }
    
    return self;
}

- (void)ag_didInitialize
{
    _firstLoad = YES;
}

#pragma mark - ---------- Public Methods ----------
- (void)ag_registerAssetsPack:(id)pack forName:(NSString *)key
{
    if ( key ) {
        [self.packDictM setObject:pack forKey:key];
    }
}

- (void)ag_removeAssetsPack:(id)pack forName:(NSString *)key
{
    if ( key ) {
        [_packDictM removeObjectForKey:key];
    }
}

- (void)ag_addReloadResponder:(id<UITraitEnvironment>)responder
{
    if ( [responder respondsToSelector:@selector(traitCollectionDidChange:)] ) {
        [self.weakHashTable addObject:responder];
    }
}

- (void)ag_removeReloadResponder:(id<UITraitEnvironment>)responder
{
    [self.weakHashTable removeObject:responder];
}

- (void)ag_executeReloadResponder:(id<UITraitEnvironment>)responder
{
    [responder traitCollectionDidChange:nil];
}

- (BOOL)ag_isUsingPackName:(NSString *)packName
{
    return [_currentPackName isEqualToString:packName];
}

- (NSString *)ag_useDefaultIfNoFindPackName:(NSString *)packName
{
    NSString *usingPackName;
    for (NSString *key in self.packDictM.allKeys) {
        if ( [key isEqualToString:packName] ) { // 找到
            usingPackName = packName;
            break;
        }
    }
    
    if (nil == usingPackName) { // 找不到,用默认
        usingPackName = _defaultPackName;
    }
    return usingPackName;
}

#pragma mark -
- (BOOL)ag_neededReloadWithTraitCollection:(UITraitCollection *)traitCollection forPackName:(NSString *)packName
{
    BOOL reloadTag = NO;
    if (NO == [packName isEqualToString:_currentPackName]) {
        reloadTag = YES;
        _prevPackName = _currentPackName;
        _currentPackName = [self ag_useDefaultIfNoFindPackName:packName];
    }
    return reloadTag;
}

- (void)ag_reloadIfNeeded
{
    if (_currentPackName) {
        [self.weakHashTable.allObjects enumerateObjectsUsingBlock:^(id<UITraitEnvironment> obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj traitCollectionDidChange:nil];
        }];
    }
}

#pragma mark - ----------- Getter Methods ----------
- (NSMutableDictionary *)packDictM
{
    if ( nil == _packDictM ) {
        _packDictM = [NSMutableDictionary dictionaryWithCapacity:12];
    }
    return _packDictM;
}

- (NSHashTable *)weakHashTable
{
    if ( nil == _weakHashTable ) {
        _weakHashTable = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory capacity:240];
    }
    return _weakHashTable;
}

- (NSString *)currentPackName
{
    if ([AGAssetsReloader.sharedInstance ag_followSystemStateForKey:[self ag_assetsFollowSystemStateKey]]) {
        _currentPackName = self.systemPackName ?: self.defaultPackName;
    }
    
    if (_firstLoad) {
        _currentPackName = [self ag_useDefaultIfNoFindPackName:_currentPackName];
        _firstLoad = NO;
    }
    
    return _currentPackName;
}

- (NSBundle *)currentBundle
{
    if ( nil == _currentBundle ) {
        _currentBundle = [NSBundle mainBundle];
    }
    return _currentBundle;
}

/// 资产名 key
- (NSString *)ag_assetsNameKey
{
    NSAssert(NO, @"子类重写！");
    return nil;
}

/// 是否跟随系统 key
- (NSString *)ag_assetsFollowSystemStateKey
{
    NSAssert(NO, @"子类重写！");
    return nil;
}

/// 使用中的包名 key
- (NSString *)ag_assetsUsingPackNameKey
{
    NSAssert(NO, @"子类重写！");
    return nil;
}

@end
