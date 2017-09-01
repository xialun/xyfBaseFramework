//
//  SCApiProxy.m
//  SmartCity
//
//  Created by 时永健 on 2017/6/23.
//  Copyright © 2017年 sea. All rights reserved.
//

#import "SCApiProxy.h"
#import "AFNetworking.h"

@interface SCApiProxy ()

@property (nonatomic,strong) NSMutableDictionary *dispatchTable;

@property (nonatomic,strong) NSNumber *recordedRequestId;

@property (nonatomic,strong) AFHTTPSessionManager *sessionManager;

@end

@implementation SCApiProxy
#pragma mark -setter and getter
- (NSMutableDictionary *)dispatchTable{
    
    if (_dispatchTable == nil) {
        
        _dispatchTable = [[NSMutableDictionary alloc]init];
        
    }
    return _dispatchTable;
}

- (AFHTTPSessionManager *)sessionManager{
    
    if (_sessionManager == nil) {
        
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.responseSerializer = [[AFHTTPResponseSerializer alloc]init];
        _sessionManager.securityPolicy.allowInvalidCertificates = YES;
        _sessionManager.securityPolicy.validatesDomainName = NO;
        
    }
    return _sessionManager;
}

#pragma mark -life cycle
+ (instancetype)sharedInstance{
    
    static SCApiProxy *proxy = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    
        proxy = [[SCApiProxy alloc]init];
    });
    return proxy;
}

#pragma mark -public method
- (void)cancelRequestWithRequestID:(NSNumber *)requestID{
    
    NSURLSessionDataTask *dataTask = self.dispatchTable[requestID];
    [dataTask cancel];
    [self.dispatchTable removeObjectForKey:requestID];
}
- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList{
    
    for (NSNumber *requestID in requestIDList) {
        
        [self cancelRequestWithRequestID:requestID];
    }
}

- (void)cancelAllRequest{
    
    if (self.dispatchTable.count >0) {
        
        for (NSNumber *requestID in [self.dispatchTable allKeys]) {
            
            [self cancelRequestWithRequestID:requestID];
        }
    }
}

- (NSNumber *)callAPIWithRequest:(NSURLRequest *)request success:(APICallBack)success fail:(APICallBack)fail{
    
    NSLog(@"start===========\n%@\n===========",request.URL);
    
    __block NSURLSessionDataTask *dataTask = nil;
    
    dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        //请求成功则将请求数据从数组中移除
        NSNumber *requestID = @([dataTask taskIdentifier]);
        [self.dispatchTable removeObjectForKey:requestID];
        NSData *responseData = responseObject;
        
        SCURLResponse *scResponse = [[SCURLResponse alloc]initWithResponse:response requestId:requestID request:request responseData:responseData error:error];
        
        if (error) {
            
            fail?fail(scResponse):nil;
        }else{
            
            success?success(scResponse):nil;
        }
        
    }];
    
    NSNumber *requestId = @([dataTask taskIdentifier]);
    self.dispatchTable[requestId] = dataTask;
    
    NSLog(@"end===========\n%@\n===========",requestId);
    [dataTask resume];//开始网络请求
    
    return requestId;
}
@end
