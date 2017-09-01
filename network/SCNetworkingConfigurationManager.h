//
//  SCNetworkingConfigurationManager.h
//  SmartCity
//
//  Created by 时永健 on 2017/6/23.
//  Copyright © 2017年 sea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCNetworkingConfigurationManager : NSObject

+ (instancetype)sharedInstance;

//网络状态
@property (nonatomic, assign, readonly) BOOL isReachable;

//token检验开关
@property (nonatomic,assign,readonly) BOOL isCheckToken;

//token失效接口数组
@property (nonatomic,strong,readwrite) NSMutableArray *tokenValidTarget_Array;

//是否处于登录界面
@property (nonatomic,assign,readwrite) BOOL tokenValid;

//token是否失效
@property (nonatomic,assign,readwrite) BOOL tokenValidToCreateFail;
@end
