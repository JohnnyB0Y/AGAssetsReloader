//
//  AGAssetsReloadProtocol.h
//  AGAssetsReloader
//
//  Created by JohnnyB0Y on 2019/10/1.
//  Copyright © 2019 JohnnyB0Y. All rights reserved.
//

#ifndef AGAssetsReloadProtocol_h
#define AGAssetsReloadProtocol_h

#import <UIKit/UIKit.h>

@protocol AGAssetsDelegate <NSObject>

#pragma mark - 注册、移除[资源包]
- (void)ag_registerAssetsPack:(id)pack forName:(NSString *)key;
- (void)ag_removeAssetsPack:(id)pack forName:(NSString *)key;


#pragma mark - 添加、删除、执行[资源包重载]响应者
- (void)ag_addReloadResponder:(id<UITraitEnvironment>)responder;
- (void)ag_removeReloadResponder:(id<UITraitEnvironment>)responder;
- (void)ag_executeReloadResponder:(id<UITraitEnvironment>)responder;


@end

#endif /* AGAssetsReloadProtocol_h */
