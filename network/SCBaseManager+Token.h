//
//  SCBaseManager+Token.h
//  SmartCity
//
//  Created by 时永健 on 2017/6/26.
//  Copyright © 2017年 sea. All rights reserved.
//

#import "SCBaseManager.h"

@interface SCBaseManager (Token)

FOUNDATION_EXPORT       NSString                *const touristPublicKey;
//记录token失效信息
@property (nonatomic,strong)       NSString *tokenErrorMessage;

- (void)parseToken:(NSDictionary *)headerDic urlResponse:(SCURLResponse *)urlResponse;
@end
