//
//  SCURLResponse.h
//  SmartCity
//
//  Created by 时永健 on 2017/6/23.
//  Copyright © 2017年 sea. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger,SCResponseStatus){
    
    SCResponseStatusSuccess,//请求成功
    SCResponseStatusErrorFail,//请求失败
    SCResponseStatusErrorTimeOut//请求超时
};
@interface SCURLResponse : NSObject

//返回报文
@property (nonatomic,strong,readonly) NSData *responseData;
@property (nonatomic,strong,readonly) NSError *error;
@property (nonatomic,strong,readonly) NSURLResponse *response;

//状态
@property (nonatomic,assign,readonly) SCResponseStatus status;
//请求内容
@property (nonatomic,strong,readonly) NSURLRequest *urlRequest;

//发起请求identify
@property (nonatomic,strong,readonly) NSNumber *requestId;

//other

//初始化
- (instancetype)initWithResponse:(NSURLResponse *)response requestId:(NSNumber *)requestId request:(NSURLRequest *)request responseData:(NSData *)responseData error:(NSError *)error;
@end
