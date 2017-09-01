//
//  SCNetworkingConfigurationManager.m
//  SmartCity
//
//  Created by 时永健 on 2017/6/23.
//  Copyright © 2017年 sea. All rights reserved.
//

#import "SCNetworkingConfigurationManager.h"
#import "AFNetworking.h"

@implementation SCNetworkingConfigurationManager

+ (instancetype)sharedInstance{
    
    static SCNetworkingConfigurationManager *configurationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        configurationManager = [[SCNetworkingConfigurationManager alloc]init];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    });
    return configurationManager;
}

#pragma mark -getter And setter
- (BOOL)isReachable
{
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        return YES;
    } else {
        return [[AFNetworkReachabilityManager sharedManager] isReachable];
    }
}

- (NSMutableArray *)tokenValidTarget_Array{
    
    if (!_tokenValidTarget_Array) {
        
        _tokenValidTarget_Array = [[NSMutableArray alloc]init];
    }
    
    return _tokenValidTarget_Array;
}

- (BOOL)isCheckToken{
    
    return YES;
}
@end
