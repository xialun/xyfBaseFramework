//
//  SCIntermediateHandle.h
//  NetworkHandle
//
//  Created by xyf on 17/7/14.
//  Copyright © 2017年 xyf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCIntermediateHandle : NSObject
{
    //参数列表
    NSMutableArray *_argList;
}
+(instancetype)shareIntermediateHandle;

/**
 *  @abstract   现适用于两个参数的方法调用
 *
 *  @param  target      需要调用对象
 *  @param  methodName  对象的方法
 *  @param  arg,...     传入参数列表
 *
 *  @return
 */
- (void)preformTarget:(NSString *)target method:(NSString *)methodName args:(id)arg,...;

/**
 *  @abstract   现适用于一个参数的方法调用
 *
 *  @param  target      需要调用对象
 *  @param  methodName  对象的方法
 *  @param  arg,...     传入参数列表
 *
 *  @return id          返回数据类型
 */
- (id)preformTarget:(NSString *)target methodWithRequest:(NSString *)methodName args:(id)arg,...;

@end
