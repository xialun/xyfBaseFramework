//
//  SCURLResponse.m
//  SmartCity
//
//  Created by 时永健 on 2017/6/23.
//  Copyright © 2017年 sea. All rights reserved.
//

#import "SCURLResponse.h"

@interface SCURLResponse ()

//返回报文
@property (nonatomic,strong,readwrite) NSData *responseData;
@property (nonatomic,strong,readwrite) NSError *error;
@property (nonatomic,strong,readwrite) NSURLResponse *response;

//状态
@property (nonatomic,assign,readwrite) SCResponseStatus status;
//请求内容
@property (nonatomic,strong,readwrite) NSURLRequest *urlRequest;

//发起请求identify
@property (nonatomic,strong,readwrite) NSNumber *requestId;

@end
@implementation SCURLResponse


- (id)initWithResponse:(NSURLResponse *)response requestId:(NSNumber *)requestId request:(NSURLRequest *)request responseData:(NSData *)responseData error:(NSError *)error{
    
    self = [super init];
    
    if (self) {
        
        self.responseData = responseData;
        self.error = error;
        self.response = response;
        
        self.status = [self responsestatusWithError:error];
        
        self.urlRequest = request;
        
        self.requestId = requestId;
    }
    return self;
}

#pragma mark -private method
- (SCResponseStatus)responsestatusWithError:(NSError *)error{
    
    if (error) {
        
        SCResponseStatus status = SCResponseStatusErrorFail;
        
        if (error.code == NSURLErrorTimedOut) {
            
            status = SCResponseStatusErrorTimeOut;
        }
        
        return status;
    }else{
        
        return SCResponseStatusSuccess;
    }
    
}
@end
