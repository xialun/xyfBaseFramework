//
//  SCApiProxy.h
//  SmartCity
//
//  Created by 时永健 on 2017/6/23.
//  Copyright © 2017年 sea. All rights reserved.
//

/**
 *  此类用作网络发起请求核心类，只做发起请求，获取返回报文，不对报文做任何处理
 */
#import <Foundation/Foundation.h>
#import "SCURLResponse.h"

typedef void(^APICallBack)(SCURLResponse *urlResponse);

@interface SCApiProxy : NSObject

/**
 *  @abstract   初始化方法
 */
+ (instancetype)sharedInstance;

/**
 *  @abstract   发起请求
 *
 *  @param  request 请求对象
 *  @param  success 成功回调报文
 *  @param  fail    失败回调报文
 *
 *  @return NSNumber [NSUrlDataTask taskIdentifier]
 */
- (NSNumber *)callAPIWithRequest:(NSURLRequest *)request success:(APICallBack)success fail:(APICallBack)fail;

/**
 *  @abstract   取消单个id的请求
 * 
 *  @param      requestID 发起请求id
 */
- (void)cancelRequestWithRequestID:(NSNumber *)requestID;

/**
 *  @abstract   取消数组请求
 *
 *  @param      requestIDList   数组请求id
 */
- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList;

/**
 *  @abstract   取消所有未发出的请求
 */
- (void)cancelAllRequest;
@end
