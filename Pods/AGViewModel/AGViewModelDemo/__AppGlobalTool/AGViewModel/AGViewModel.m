//
//  AGViewModel.m
//  Architecture
//
//  Created by JohnnyB0Y on 2017/4/23.
//  Copyright © 2017年 JohnnyB0Y. All rights reserved.
//  视图-模型 绑定

#import "AGViewModel.h"
#import "AGVMFunction.h"
#import "AGVMNotifier.h"
#import "AGVMCommand.h"
#import "NSNotification+AGViewModel.h"

@interface AGViewModel ()

@property (nonatomic, strong) AGVMNotifier *notifier;
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *archivedDictM; ///< 归档字典
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *serializationDictM; ///< 序列化字典
@property (nonatomic, strong) NSMutableDictionary<NSString *, AGVMCommand *> *commandDictM; ///< 命令字典
@property (nonatomic, strong) NSMapTable *weaklyMT; ///< 弱引用 map

@end

#pragma mark - implementation
@implementation AGViewModel {
    AGVMConfigDataBlock _configDataBlock;
    
    struct AGResponeMethods {
        unsigned int ag_callDelegateToDoForAction       : 1;
        unsigned int ag_callDelegateToDoForActionInfo   : 1;
        unsigned int ag_callDelegateReceiveNotification : 1;
    } _responeMethod;
    
    struct AGIfNeededTags {
        unsigned int ag_cachedBindingViewSize           : 1;
        unsigned int ag_refreshUI                       : 1;
        unsigned int ag_removeObserver                  : 1;
    } _ifNeededTags;
    
}

#pragma mark - ----------- Life Cycle ----------
+ (instancetype) newWithModel:(NSDictionary *)bindingModel
                     capacity:(NSInteger)capacity
{
    AGViewModel *vm = [[self alloc] initWithModel:ag_newNSMutableDictionary(capacity)];
    [vm ag_mergeModelFromDictionary:bindingModel];
    return vm;
}

+ (instancetype) newWithModel:(NSDictionary *)bindingModel
{
    NSMutableDictionary *dictM = bindingModel ? [bindingModel mutableCopy] : ag_newNSMutableDictionary(6);
    AGViewModel *vm = [[self alloc] initWithModel:dictM];
    return vm;
}

- (instancetype) initWithModel:(NSMutableDictionary *)bindingModel
{
    self = [super init];
    if (self) {
        _bindingModel = bindingModel;
        _ifNeededTags.ag_cachedBindingViewSize = YES;
        _ifNeededTags.ag_removeObserver = NO;
    }
    return self;
}

- (void)dealloc
{
    _configDataBlock = nil;
    _notifier = nil;
    _archivedDictM = nil;
    _commandDictM = nil;
    _weaklyMT = nil;
    
    if (_ifNeededTags.ag_removeObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

#pragma mark - ---------- Public Methods ----------
#pragma mark 绑定视图可以计算自己的Size，并提供给外界使用。
- (CGSize) ag_sizeOfBindingView
{
    if ( _ifNeededTags.ag_cachedBindingViewSize ) {
        return [self ag_cachedSizeByBindingView:_bindingView];
    }
    
    CGFloat height = [self[kAGVMViewH] floatValue];
    CGFloat width = [self[kAGVMViewW] floatValue];
    return CGSizeMake(width, height);
}

- (CGSize) ag_sizeForBindingView:(UIView<AGVMResponsive> *)bv
{
    if ( _ifNeededTags.ag_cachedBindingViewSize ) {
        return [self ag_cachedSizeByBindingView:bv];
    }
    
    CGFloat height = [self[kAGVMViewH] floatValue];
    CGFloat width = [self[kAGVMViewW] floatValue];
    CGSize bvSize = CGSizeMake(width, height);
    if ( [bv respondsToSelector:@selector(ag_viewModel:sizeForLayout:)] ) {
        return [bv ag_viewModel:self sizeForLayout:[UIScreen mainScreen]];
    }
    else {
        NSAssert(NO, @"绑定视图未实现 AGVMResponsive 协议方法：ag_viewModel:sizeForBindingView:");
    }
    return bvSize;
}

/** 计算并缓存绑定视图的Size */
- (CGSize) ag_cachedSizeByBindingView:(UIView<AGVMResponsive> *)bv
{
    // old bv size
    CGFloat height = [self[kAGVMViewH] floatValue];
    CGFloat width = [self[kAGVMViewW] floatValue];
    CGSize bvSize = CGSizeMake(width, height);
    
    // 预防性
    if ( bv == nil ) {
        return bvSize;
    }
    
    if ( [bv respondsToSelector:@selector(ag_viewModel:sizeForLayout:)] ) {
        // new bv size
        bvSize = [bv ag_viewModel:self sizeForLayout:[UIScreen mainScreen]];
        // cache size
        if ( height != bvSize.height ) {
            self[kAGVMViewH] = @(bvSize. height);
        }
        
        if ( width != bvSize.width ) {
            self[kAGVMViewW] = @(bvSize. width);
        }
        // cached
        _ifNeededTags.ag_cachedBindingViewSize = NO;
    }
    else {
        NSAssert(NO, @"绑定视图未实现 AGVMResponsive 协议方法：ag_viewModel:sizeForBindingView:");
    }
    return bvSize;
}

- (void) ag_setNeedsCachedBindingViewSize
{
    _ifNeededTags.ag_cachedBindingViewSize = YES;
}

- (void) ag_cachedBindingViewSizeIfNeeded
{
    if ( _ifNeededTags.ag_cachedBindingViewSize ) {
        [self ag_cachedSizeByBindingView:_bindingView];
    }
}

#pragma mark 更新数据，刷新界面
/** 删除数据 */
- (void) ag_removeObjectForKey:(NSString *)key
{
    NSParameterAssert(key);
    [_bindingModel removeObjectForKey:key];
}

/** 删除所有数据 */
- (void) ag_removeAllObjects
{
    [_bindingModel removeAllObjects];
}

- (void) ag_refreshUIByUpdateModelUsingBlock:(NS_NOESCAPE AGVMUpdateModelBlock)block
{
    [self ag_setNeedsRefreshUIModelUsingBlock:block];
    [self ag_refreshUI];
}

/** 更新数据，并对“需要刷新UI”进行标记；当调用ag_refreshUIIfNeeded时，刷新UI界面。*/
- (void) ag_setNeedsRefreshUIModelUsingBlock:(NS_NOESCAPE AGVMUpdateModelBlock)block
{
    if ( block ) block( self );
    [self ag_setNeedsRefreshUI];
}

/** 对“需要刷新UI”进行标记；当调用ag_refreshUIIfNeeded时，刷新UI界面。*/
- (void) ag_setNeedsRefreshUI
{
    _ifNeededTags.ag_refreshUI = YES;
}

/** 刷新UI界面。*/
- (void) ag_refreshUI
{
    if ( _bindingView.viewModel != self ) {
        return;
    }
    
    if ( _configDataBlock ) {
        _configDataBlock( self, _bindingView );
    }
    else {
        [_bindingView setViewModel:self];
    }
    
    _ifNeededTags.ag_refreshUI = NO;
}

/** 如果有“需要刷新UI”的标记，马上刷新界面。 */
- (void) ag_refreshUIIfNeeded
{
    if ( _ifNeededTags.ag_refreshUI ) {
        [self ag_refreshUI];
    }
}

#pragma mark 数据合并
/** 合并 bindingModel */
- (void) ag_mergeModelFromViewModel:(AGViewModel *)vm
{
    [self ag_mergeModelFromDictionary:vm.bindingModel];
}

- (void) ag_mergeModelFromDictionary:(NSDictionary *)dict
{
    if ( dict.count <= 0 ) return;
    [_bindingModel addEntriesFromDictionary:dict];
}

- (void) ag_mergeModelFromDictionary:(NSDictionary *)dict forKeys:(NSArray<NSString *> *)keys
{
    if ( dict.count <= 0 ) return;
    [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        self[key] = dict[key];
    }];
}

- (void) ag_mergeModelFromViewModel:(AGViewModel *)vm forKeys:(NSArray<NSString *> *)keys
{
    [self ag_mergeModelFromDictionary:vm.bindingModel forKeys:keys];
}

#pragma mark Other method.
- (void)ag_makeDelegateHandleAction:(SEL)action
{
    if ( _responeMethod.ag_callDelegateToDoForAction ) {
        [_delegate ag_viewModel:self handleAction:action];
    }
    else {
        SEL sel = @selector(ag_viewModel:handleAction:);
        NSLog(@"Delegate not implementation %@!", NSStringFromSelector(sel));
    }
}

- (void)ag_makeDelegateHandleAction:(SEL)action info:(AGViewModel *)info
{
    if ( _responeMethod.ag_callDelegateToDoForActionInfo ) {
        [_delegate ag_viewModel:self handleAction:action info:info];
    }
    else {
        SEL sel = @selector(ag_viewModel:handleAction:info:);
        NSLog(@"Delegate not implementation %@!", NSStringFromSelector(sel));
    }
}

#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone
{
    AGViewModel *vm = [[self.class allocWithZone:zone] initWithModel:[_bindingModel mutableCopy]];
    vm->_bindingView = _bindingView;
    vm->_configDataBlock = [_configDataBlock copy];
    vm->_delegate = _delegate;
    vm->_indexPath = _indexPath;
    return vm;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    AGViewModel *vm = [[self.class allocWithZone:zone] initWithModel:[_bindingModel mutableCopy]];
    vm->_bindingView = _bindingView;
    vm->_configDataBlock = [_configDataBlock copy];
    vm->_delegate = _delegate;
    vm->_indexPath = _indexPath;
    vm->_archivedDictM = [_archivedDictM mutableCopy];
    vm->_weaklyMT = [_weaklyMT mutableCopy];
    vm->_commandDictM = [_commandDictM mutableCopy];
    vm->_serializationDictM = [_serializationDictM mutableCopy];
    return vm;
}

#pragma mark NSSecureCoding
+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if ( _archivedDictM ) {
        
        NSMutableDictionary *dictM = ag_newNSMutableDictionary(_archivedDictM.count);
        [_archivedDictM enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            id targetObj = self->_bindingModel[key];
            if ( targetObj ) {
                BOOL isConformsToProtocol = [targetObj conformsToProtocol:@protocol(NSCoding)];
                NSAssert(isConformsToProtocol, @"Archived object not conform to <NSCoding> protocol.");
                if ( isConformsToProtocol ) {
                    [dictM setObject:targetObj forKey:key];
                }
            }
        }];
        
        [aCoder encodeObject:dictM forKey:kAGVMDictionary];
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSMutableDictionary<NSString *, id> *bm = [[aDecoder decodeObjectOfClass:self.class forKey:kAGVMDictionary] mutableCopy];
    if ( bm == nil ) {
        bm = [NSMutableDictionary dictionaryWithCapacity:6];
    }
    
    self = [self initWithModel:bm];
    if ( self == nil ) return nil;
    
    self->_archivedDictM = [NSMutableDictionary dictionaryWithCapacity:bm.count];
    [bm enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self->_archivedDictM setObject:kAGVMObject forKey:key];
    }];
    
    return self;
}

#pragma mark - ------------ Override Methods --------------
- (id)objectForKeyedSubscript:(NSString *)key;
{
    NSParameterAssert(key);
    if ( ! key ) return nil;
    return [_bindingModel objectForKeyedSubscript:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key;
{
    NSParameterAssert(key);
    if ( ! key ) return;
    [_bindingModel setObject:obj forKeyedSubscript:key];
}

- (NSString *)debugDescription
{
    return [self ag_debugString];
}

- (id)debugQuickLookObject
{
    return [self ag_debugString];
}

- (NSString *) ag_debugString
{
    NSMutableString *strM = [NSMutableString string];
    [strM appendFormat:@"  _delegate     [ weak ] : %@, \n", _delegate];
    [strM appendFormat:@"  _notifier     (strong) : %@, \n", _notifier];
    [strM appendFormat:@"  _indexPath    ( copy ) : %@, \n", _indexPath];
    [strM appendFormat:@"  _bindingView  [ weak ] : <%@: %p>, \n", [_bindingView class], _bindingView];
    
    NSMutableString *bmStrM = [NSMutableString stringWithFormat:@"{\n"];
    [_bindingModel enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [bmStrM appendFormat:@"    %@ = %@, \n", key, obj];
    }];
    [bmStrM appendFormat:@"  }"];
    
    [strM appendFormat:@"  _bindingModel (strong) : %@", bmStrM];
    return [NSString stringWithFormat:@"♦️ <%@: %p> ♦️ {\n%@\n}", [self class] , self, strM];
}

#pragma mark - ----------- Setter Methods ----------
- (void)setDelegate:(id<AGVMDelegate>)delegate
{
    if ( _delegate != delegate ) {
        _delegate = delegate;
        
        _responeMethod.ag_callDelegateToDoForAction
        = [_delegate respondsToSelector:@selector(ag_viewModel:handleAction:)];
        
        _responeMethod.ag_callDelegateToDoForActionInfo
        = [_delegate respondsToSelector:@selector(ag_viewModel:handleAction:info:)];
    }
}

- (void)setIndexPath:(NSIndexPath *)indexPath
{
    if ( _indexPath != indexPath ) {
        _indexPath = indexPath;
    }
}

#pragma mark - ----------- Getter Methods ----------
- (AGVMNotifier *)notifier
{
    if ( nil == _notifier ) {
        _notifier = [[AGVMNotifier alloc] initWithViewModel:self];
    }
    return _notifier;
}

- (NSMutableDictionary<NSString *,id> *)archivedDictM
{
    if ( nil == _archivedDictM ) {
        _archivedDictM = [NSMutableDictionary dictionaryWithCapacity:6];
    }
    return _archivedDictM;
}

- (NSMutableDictionary<NSString *,id> *)serializationDictM
{
    if ( nil == _serializationDictM ) {
        _serializationDictM = [NSMutableDictionary dictionaryWithCapacity:6];
    }
    return _serializationDictM;
}

- (NSMutableDictionary<NSString *, AGVMCommand *> *)commandDictM
{
    if ( nil == _commandDictM ) {
        _commandDictM = [NSMutableDictionary dictionaryWithCapacity:6];
    }
    return _commandDictM;
}

- (NSMapTable *)weaklyMT
{
    if ( nil == _weaklyMT ) {
        _weaklyMT = [NSMapTable strongToWeakObjectsMapTable];
    }
    return _weaklyMT;
}

@end

@implementation AGViewModel (AGVMArchived)

- (void) ag_addArchivedKey:(NSString *)key
{
    NSParameterAssert(key);
    [self.archivedDictM setObject:kAGVMObject forKey:key];
}

- (void) ag_removeArchivedKey:(NSString *)key
{
    NSParameterAssert(key);
    [_archivedDictM removeObjectForKey:key];
}

- (void) ag_removeAllArchivedKeys
{
    [_archivedDictM removeAllObjects];
}

@end

@implementation AGViewModel (AGVMSerializable)

- (void) ag_addSerializableKey:(NSString *)key
{
    NSParameterAssert(key);
    [self.serializationDictM setObject:kAGVMObject forKey:key];
}

- (void) ag_removeSerializableKey:(NSString *)key
{
    NSParameterAssert(key);
    [_serializationDictM removeObjectForKey:key];
}

- (void) ag_removeAllSerializableKeys
{
    [_serializationDictM removeAllObjects];
}

#pragma mark AGVMJSONTransformable
- (NSString *) ag_toJSONStringWithExchangeKey:(AGViewModel *)vm
                              customTransform:(NS_NOESCAPE AGVMJSONTransformBlock)block
{
    if ( _serializationDictM.count <= 0 ) return nil;
    
    NSMutableDictionary *dictM = ag_newNSMutableDictionary(_serializationDictM.count);
    [_serializationDictM enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        id targetObj = self->_bindingModel[key];
        if ( targetObj ) {
            [dictM setObject:targetObj forKey:key];
        }
    }];
    
    return ag_newJSONStringWithDictionary(dictM, vm, block);
}

- (NSString *)ag_toJSONStringWithCustomTransform:(NS_NOESCAPE AGVMJSONTransformBlock)block
{
    return [self ag_toJSONStringWithExchangeKey:nil customTransform:block];
}

- (NSString *)ag_toJSONString
{
    return [self ag_toJSONStringWithCustomTransform:nil];
}

@end

#pragma mark -
@implementation AGViewModel (AGVMObserverRegistration)
#pragma mark readd observer
- (void) ag_readdObserver:(NSObject *)observer
				   forKey:(NSString *)key
               usingBlock:(AGVMNotificationBlock)block
{
	[self.notifier ag_readdObserver:observer forKey:key usingBlock:block];
}

- (void) ag_readdObserver:(NSObject *)observer
				  forKeys:(NSArray<NSString *> *)keys
					usingBlock:(AGVMNotificationBlock)block
{
	[self.notifier ag_readdObserver:observer forKeys:keys usingBlock:block];
}

- (void) ag_readdObserver:(NSObject *)observer
                   forKey:(NSString *)key
                  options:(NSKeyValueObservingOptions)options
               usingBlock:(AGVMNotificationBlock)block
{
	[self.notifier ag_readdObserver:observer forKey:key options:options usingBlock:block];
}

- (void)ag_readdObserver:(NSObject *)observer
                 forKeys:(NSArray<NSString *> *)keys
                 options:(NSKeyValueObservingOptions)options
              usingBlock:(AGVMNotificationBlock)block
{
	[self.notifier ag_readdObserver:observer forKeys:keys options:options usingBlock:block];
}

#pragma mark add observer
- (void) ag_addObserver:(NSObject *)observer
				 forKey:(NSString *)key
             usingBlock:(AGVMNotificationBlock)block
{
	[self.notifier ag_addObserver:observer forKey:key usingBlock:block];
}

- (void) ag_addObserver:(NSObject *)observer
				forKeys:(NSArray<NSString *> *)keys
             usingBlock:(AGVMNotificationBlock)block
{
	[self.notifier ag_addObserver:observer forKeys:keys usingBlock:block];
}

- (void) ag_addObserver:(NSObject *)observer
				 forKey:(NSString *)key
				options:(NSKeyValueObservingOptions)options
             usingBlock:(AGVMNotificationBlock)block
{
	[self.notifier ag_addObserver:observer forKey:key options:options usingBlock:block];
}

- (void) ag_addObserver:(NSObject *)observer
				forKeys:(NSArray<NSString *> *)keys
				options:(NSKeyValueObservingOptions)options
             usingBlock:(AGVMNotificationBlock)block
{
	[self.notifier ag_addObserver:observer forKeys:keys options:options usingBlock:block];
}

#pragma mark remove observer
- (void) ag_removeObserver:(NSObject *)observer
					forKey:(NSString *)key
{
	[_notifier ag_removeObserver:observer forKey:key];
}

- (void) ag_removeObserver:(NSObject *)observer
				   forKeys:(NSArray<NSString *> *)keys
{
	[_notifier ag_removeObserver:observer forKeys:keys];
}

- (void) ag_removeObserver:(NSObject *)observer
{
	[_notifier ag_removeObserver:observer];
}

- (void) ag_removeAllObservers
{
	[_notifier ag_removeAllObservers];
}

@end

#pragma mark -
@implementation AGViewModel (AGVMSafeAccessible)

#pragma mark safe number
- (id) ag_safeSetNumber:(id)value forKey:(NSString *)key
{
	return [self ag_safeSetNumber:value forKey:key handle:nil];
}
- (NSNumber *) ag_safeNumberForKey:(NSString *)key
{
	return [self ag_safeNumberForKey:key handle:nil];
}
- (id) ag_safeSetNumber:(id)value forKey:(NSString *)key handle:(NS_NOESCAPE AGVMSafeSetHandleBlock)block
{
	return [self _setNewObject:ag_safeNumber(value) forKey:key withObject:value handle:block];
}
- (NSNumber *) ag_safeNumberForKey:(NSString *)key handle:(NS_NOESCAPE AGVMSafeGetHandleBlock)block
{
	id value = self[key];
	return [self _getNewObject:ag_safeNumber(value) withObject:value handle:block];
}


#pragma mark safe string
- (id) ag_safeSetString:(id)value forKey:(NSString *)key
{
	return [self ag_safeSetString:value forKey:key handle:nil];
}
- (NSString *) ag_safeStringForKey:(NSString *)key
{
	return [self ag_safeStringForKey:key handle:nil];
}
- (id) ag_safeSetString:(id)value forKey:(NSString *)key handle:(NS_NOESCAPE AGVMSafeSetHandleBlock)block
{
	return [self _setNewObject:ag_safeString(value) forKey:key withObject:value handle:block];
}
- (NSString *) ag_safeStringForKey:(NSString *)key handle:(NS_NOESCAPE AGVMSafeGetHandleBlock)block
{
	id value = self[key];
	return [self _getNewObject:ag_safeString(value) withObject:value handle:block];
}
- (NSString *) ag_safeNumberStringForKey:(NSString *)key
{
    return [self ag_safeNumberStringForKey:key handle:nil];
}
- (NSString *) ag_safeNumberStringForKey:(NSString *)key handle:(NS_NOESCAPE AGVMSafeGetHandleBlock)block
{
    id value = self[key];
    return [self _getNewObject:ag_newNSStringWithObj(value) withObject:value handle:block];
}



#pragma mark safe array
- (id) ag_safeSetArray:(id)value forKey:(NSString *)key
{
	return [self ag_safeSetArray:value forKey:key handle:nil];
}
- (NSArray *) ag_safeArrayForKey:(NSString *)key
{
	return [self ag_safeArrayForKey:key handle:nil];
}
- (id) ag_safeSetArray:(id)value forKey:(NSString *)key handle:(NS_NOESCAPE AGVMSafeSetHandleBlock)block
{
	return [self _setNewObject:ag_safeArray(value) forKey:key withObject:value handle:block];
}
- (NSArray *) ag_safeArrayForKey:(NSString *)key handle:(NS_NOESCAPE AGVMSafeGetHandleBlock)block
{
	id value = self[key];
	return [self _getNewObject:ag_safeArray(value) withObject:value handle:block];
}


#pragma mark safe dictionary
- (id) ag_safeSetDictionary:(id)value forKey:(NSString *)key
{
	return [self ag_safeSetDictionary:value forKey:key handle:nil];
}
- (NSDictionary *) ag_safeDictionaryForKey:(NSString *)key
{
	return [self ag_safeDictionaryForKey:key handle:nil];
}
- (id) ag_safeSetDictionary:(id)value forKey:(NSString *)key handle:(NS_NOESCAPE AGVMSafeSetHandleBlock)block
{
	return [self _setNewObject:ag_safeDictionary(value) forKey:key withObject:value handle:block];
}
- (NSDictionary *) ag_safeDictionaryForKey:(NSString *)key handle:(NS_NOESCAPE AGVMSafeGetHandleBlock)block
{
	id value = self[key];
	return [self _getNewObject:ag_safeDictionary(value) withObject:value handle:block];
}


#pragma mark safe url
- (NSURL *) ag_safeURLForKey:(NSString *)key
{
	return [self ag_safeURLForKey:key handle:nil];
}
- (NSURL *) ag_safeURLForKey:(NSString *)key handle:(NS_NOESCAPE AGVMSafeGetHandleBlock)block
{
	id value = self[key];
	NSURL *url = ag_safeObj(value, [NSURL class]);
	if ( url == nil ) {
		NSString *urlStr = ag_safeString(value);
		if ( urlStr ) {
			url = [NSURL URLWithString:urlStr];
		}
	}
	return [self _getNewObject:url withObject:value handle:block];
}


#pragma mark safe value type
- (double) ag_safeDoubleValueForKey:(NSString *)key
{
	return [self ag_safeDoubleValueForKey:key handle:nil];
}
- (double) ag_safeDoubleValueForKey:(NSString *)key handle:(NS_NOESCAPE AGVMSafeGetNumberHandleBlock)block
{
	id value = self[key];
	BOOL respond = [value respondsToSelector:@selector(doubleValue)];
	NSNumber *number = [self _getNewNumber:value respond:respond handle:block];
	return [number doubleValue];
}


- (float) ag_safeFloatValueForKey:(NSString *)key
{
	return [self ag_safeFloatValueForKey:key handle:nil];
}
- (float) ag_safeFloatValueForKey:(NSString *)key handle:(NS_NOESCAPE AGVMSafeGetNumberHandleBlock)block
{
	id value = self[key];
	BOOL respond = [value respondsToSelector:@selector(floatValue)];
	NSNumber *number = [self _getNewNumber:value respond:respond handle:block];
	return [number floatValue];
}


- (int) ag_safeIntValueForKey:(NSString *)key
{
	return [self ag_safeIntValueForKey:key handle:nil];
}
- (int) ag_safeIntValueForKey:(NSString *)key handle:(NS_NOESCAPE AGVMSafeGetNumberHandleBlock)block
{
	id value = self[key];
	BOOL respond = [value respondsToSelector:@selector(intValue)];
	NSNumber *number = [self _getNewNumber:value respond:respond handle:block];
	return [number intValue];
}


- (NSInteger) ag_safeIntegerValueForKey:(NSString *)key
{
	return [self ag_safeIntegerValueForKey:key handle:nil];
}
- (NSInteger) ag_safeIntegerValueForKey:(NSString *)key handle:(NS_NOESCAPE AGVMSafeGetNumberHandleBlock)block
{
	id value = self[key];
	BOOL respond = [value respondsToSelector:@selector(integerValue)];
	NSNumber *number = [self _getNewNumber:value respond:respond handle:block];
	return [number integerValue];
}


- (long long) ag_safeLongLongValueForKey:(NSString *)key
{
	return [self ag_safeLongLongValueForKey:key handle:nil];
}
- (long long) ag_safeLongLongValueForKey:(NSString *)key handle:(NS_NOESCAPE AGVMSafeGetNumberHandleBlock)block
{
	id value = self[key];
	BOOL respond = [value respondsToSelector:@selector(longLongValue)];
	NSNumber *number = [self _getNewNumber:value respond:respond handle:block];
	return [number longLongValue];
}


- (BOOL) ag_safeBoolValueForKey:(NSString *)key
{
	return [self ag_safeBoolValueForKey:key handle:nil];
}
- (BOOL) ag_safeBoolValueForKey:(NSString *)key handle:(NS_NOESCAPE AGVMSafeGetNumberHandleBlock)block
{
	id value = self[key];
	BOOL respond = [value respondsToSelector:@selector(boolValue)];
	NSNumber *number = [self _getNewNumber:value respond:respond handle:block];
	return [number boolValue];
}

#pragma mark - ---------- Private Methods ----------
- (id) _setNewObject:(id)newObj
              forKey:(NSString *)key
          withObject:(id)obj
              handle:(AGVMSafeSetHandleBlock)block
{
	self[key] = newObj;
	block ? block(obj, newObj != nil) : nil;
	return newObj;
}

- (id) _getNewObject:(id)newObj
	      withObject:(id)obj
              handle:(AGVMSafeGetHandleBlock)block
{
	if ( block ) {
		newObj = block(obj, newObj != nil);
	}
	return newObj;
}

- (NSNumber *) _getNewNumber:(id)obj
                     respond:(BOOL)respond
                      handle:(AGVMSafeGetNumberHandleBlock)block
{
	if ( block ) {
		return block(obj, respond);
	}
	return respond ? obj : nil;
}

@end


@implementation AGViewModel (AGVMWeakly)

- (void)ag_setWeaklyObject:(id)obj forKey:(NSString *)key
{
    AGAssertParameter(key);
    [self.weaklyMT setObject:obj forKey:key];
}

- (void)ag_removeWeaklyObjectForKey:(NSString *)key
{
    AGAssertParameter(key);
    [_weaklyMT removeObjectForKey:key];
}

- (id)ag_weaklyObjectForKey:(NSString *)key
{
    AGAssertParameter(key);
    return [_weaklyMT objectForKey:key];
}

@end


@implementation AGViewModel (AGVMCommandExecutable)

- (void)ag_setCommandBlock:(AGVMCommandExecutableBlock)block forKey:(NSString *)key
{
    AGAssertParameter(key);
    AGAssertParameter(block);
    
    if ( key && block ) {
        AGVMCommand *cmd = [AGVMCommand newWithExecuteBlock:block undoBlock:nil];
        [self.commandDictM setObject:cmd forKey:key];
    }
}

- (void)ag_setCommand:(AGVMCommand *)command forKey:(NSString *)key
{
    AGAssertParameter(key);
    AGAssertParameter(command);
    
    [self.commandDictM setObject:command forKey:key];
}

- (void)ag_removeCommandForKey:(NSString *)key
{
    AGAssertParameter(key);
    [_commandDictM removeObjectForKey:key];
}

- (id)ag_executeCommandForKey:(NSString *)key
{
    AGAssertParameter(key);
    
    AGVMCommand *cmd = [_commandDictM objectForKey:key];
    if ( cmd ) {
        cmd.executable = YES;
        id object = [cmd ag_execute:self];
        cmd.executable = NO;
        if ( object ) { // 每次执行都存一次结果
            [_bindingModel setObject:object forKey:key];
        }
        else {
            [_bindingModel removeObjectForKey:key];
        }
        return object;
    }
    return [_bindingModel objectForKey:key]; // 执行到这里，说明 Block 不存在了，直接返回保存的数据。
}

- (void)ag_setNeedsExecuteCommandForKey:(NSString *)key
{
    AGAssertParameter(key);
    [_commandDictM objectForKey:key].executable = YES;
}

- (id)ag_executeCommandIfNeededForKey:(NSString *)key
{
    AGAssertParameter(key);
    
    AGVMCommand *cmd = [_commandDictM objectForKey:key];
    if ( cmd.isExecutable ) {
        id object = [cmd ag_execute:self];
        cmd.executable = NO;
        if ( object ) { // 每次执行都存一次结果
            [_bindingModel setObject:object forKey:key];
        }
        else {
            [_bindingModel removeObjectForKey:key];
        }
        return object;
    }
    return [_bindingModel objectForKey:key]; // 直接取值
}

@end

@implementation AGViewModel (AGVMMethodChaining)

+ (AGViewModel *)defaultInstance
{
    return [self newWithModel:nil];
}

- (AGVMSetObjectForKeyBlock)setObjectForKey
{
    return ^AGViewModel * _Nonnull(id  _Nullable object, NSString * _Nonnull forKey) {
        [self setObject:object forKeyedSubscript:forKey];
        return self;
    };
}

- (AGVMRemoveObjectForKeyBlock)removeObjectForKey
{
    return ^AGViewModel * _Nonnull(NSString * _Nonnull key) {
        [self ag_removeObjectForKey:key];
        return self;
    };
}

- (AGViewModel * _Nonnull (^)(NSDictionary * _Nonnull))mergeDictionary
{
    return ^AGViewModel * _Nonnull(NSDictionary * _Nonnull dict) {
        [self ag_mergeModelFromDictionary:dict];
        return self;
    };
}

- (AGViewModel * _Nonnull (^)(NSDictionary * _Nonnull, NSArray<NSString *> * _Nonnull))mergeDictionaryForKeys
{
    return ^AGViewModel * _Nonnull(NSDictionary * _Nonnull dict, NSArray<NSString *> * _Nonnull keys) {
        [self ag_mergeModelFromDictionary:dict forKeys:keys];
        return self;
    };
}

- (AGViewModel * _Nonnull (^)(AGViewModel * _Nonnull))mergeViewModel
{
    return ^AGViewModel * _Nonnull(AGViewModel * _Nonnull vm) {
        [self ag_mergeModelFromViewModel:vm];
        return self;
    };
}

- (AGViewModel * _Nonnull (^)(AGViewModel * _Nonnull, NSArray<NSString *> * _Nonnull))mergeViewModelForKeys
{
    return ^AGViewModel * _Nonnull(AGViewModel * _Nonnull vm, NSArray<NSString *> * _Nonnull keys) {
        [self ag_mergeModelFromViewModel:vm forKeys:keys];
        return self;
    };
}

- (AGViewModel * _Nonnull (^)(NSIndexPath * _Nullable))setIndexPath
{
    return ^AGViewModel * _Nonnull(NSIndexPath * _Nullable indexPath) {
        self.indexPath = indexPath;
        return self;
    };
}

- (AGViewModel * _Nonnull (^)(id<AGVMDelegate> _Nullable))setDelegate
{
    return ^AGViewModel * _Nonnull(id<AGVMDelegate> _Nullable delegate) {
        self.delegate = delegate;
        return self;
    };
}

- (AGViewModel * _Nonnull (^)(UIView<AGVMResponsive> * _Nullable))setBindingView
{
    return ^AGViewModel * _Nonnull(UIView<AGVMResponsive> * _Nullable view) {
        self->_bindingView = view;
        return self;
    };
}

- (AGViewModel * _Nonnull (^)(AGVMConfigDataBlock _Nonnull))setBindingViewConfigDataBlock
{
    return ^AGViewModel * _Nonnull(AGVMConfigDataBlock _Nonnull configDataBlock) {
        self->_configDataBlock = [configDataBlock copy];
        return self;
    };
}

- (AGViewModel * _Nonnull (^)(AGVMCommand * _Nonnull, NSString * _Nonnull))setCommandForKey
{
    return ^AGViewModel * _Nonnull(AGVMCommand * _Nonnull command, NSString * _Nonnull key) {
        [self ag_setCommand:command forKey:key];
        return self;
    };
}

- (AGViewModel * _Nonnull (^)(NSString * _Nonnull))removeCommandForKey
{
    return ^AGViewModel * _Nonnull(NSString * _Nonnull key) {
        [self ag_removeCommandForKey:key];
        return self;
    };
}

- (AGVMSetObjectForKeyBlock)setWeaklyForKey
{
    return ^AGViewModel * _Nonnull(id  _Nullable object, NSString * _Nonnull key) {
        [self ag_setWeaklyObject:object forKey:key];
        return self;
    };
}

- (AGVMRemoveObjectForKeyBlock)removeWeaklyForKey
{
    return ^AGViewModel * _Nonnull(NSString * _Nonnull key) {
        [self ag_removeWeaklyObjectForKey:key];
        return self;
    };
}

- (AGViewModel * _Nonnull (^)(NSString * _Nonnull))addArchivedKey
{
    return ^AGViewModel * _Nonnull(NSString * _Nonnull key) {
        [self ag_addArchivedKey:key];
        return self;
    };
}

- (AGViewModel * _Nonnull (^)(NSString * _Nonnull))removeArchivedKey
{
    return ^AGViewModel * _Nonnull(NSString * _Nonnull key) {
        [self ag_removeArchivedKey:key];
        return self;
    };
}

- (AGViewModel * _Nonnull (^)(void))removeAllArchivedKeys
{
    return ^AGViewModel * _Nonnull{
        [self ag_removeAllArchivedKeys];
        return self;
    };
}

- (AGViewModel * _Nonnull (^)(NSString * _Nonnull))addSerializableKey
{
    return ^AGViewModel * _Nonnull(NSString * _Nonnull key) {
        [self ag_addSerializableKey:key];
        return self;
    };
}

- (AGViewModel * _Nonnull (^)(NSString * _Nonnull))removeSerializableKey
{
    return ^AGViewModel * _Nonnull(NSString * _Nonnull key) {
        [self ag_removeSerializableKey:key];
        return self;
    };
}

- (AGViewModel * _Nonnull (^)(void))removeAllSerializableKeys
{
    return ^AGViewModel * _Nonnull{
        [self ag_removeAllSerializableKeys];
        return self;
    };
}

@end

AGVMStaticConstKeyNameDefine(__kAGVMNotificationDelegate__);

@implementation AGViewModel (NSNotificationCenter)

- (void) ag_postNotificationName:(NSNotificationName)notificationName
{
    [self ag_postNotificationName:notificationName object:nil];
}

- (void) ag_postNotificationName:(NSNotificationName)notificationName
                          object:(nullable id)object
{
    NSNotification *notification = [NSNotification notificationWithName:notificationName object:object viewModel:self];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void) ag_addObserveNotificationName:(NSNotificationName)notificationName
                                object:(nullable id)object
{
    if (notificationName.length > 0) {
        _ifNeededTags.ag_removeObserver = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ag_viewModelReceiveNotification:) name:notificationName object:object];
    }
}

- (void) ag_addObserveNotificationName:(NSNotificationName)notificationName
{
    [self ag_addObserveNotificationName:notificationName object:nil];
}

- (void) ag_removeObserveNotificationName:(NSNotificationName)notificationName
{
    [self ag_removeObserveNotificationName:notificationName object:nil];
}

- (void) ag_removeObserveNotificationName:(NSNotificationName)notificationName
                                   object:(nullable id)object
{
    if (notificationName.length > 0) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:object];
    }
}

#pragma mark - ----------- Getter Setter Methods ----------
- (id<AGVMNotificationDelegate>)notificationDelegate
{
    return [self ag_weaklyObjectForKey:__kAGVMNotificationDelegate__];
}

- (void)setNotificationDelegate:(id<AGVMNotificationDelegate>)notificationDelegate
{
    if ( self.notificationDelegate != notificationDelegate ) {
        [self ag_setWeaklyObject:notificationDelegate forKey:__kAGVMNotificationDelegate__];
        _responeMethod.ag_callDelegateReceiveNotification
        = [self.notificationDelegate respondsToSelector:@selector(ag_viewModel:receiveNotification:info:)];
    }
}

#pragma mark - ---------- Event Methods ----------
- (void) ag_viewModelReceiveNotification:(NSNotification *)notification
{
    if (_responeMethod.ag_callDelegateReceiveNotification) {
        [self.notificationDelegate ag_viewModel:self receiveNotification:notification info:notification.viewModel];
    }
}

@end
