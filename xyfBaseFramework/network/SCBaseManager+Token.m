//
//  SCBaseManager+Token.m
//  SmartCity
//
//  Created by 时永健 on 2017/6/26.
//  Copyright © 2017年 sea. All rights reserved.
//

#import "SCBaseManager+Token.h"
#import "SCIntermediateHandle.h"
#import "SystemInfo.h"
#import "SCRSACryptor.h"
#import "SCUserEntity.h"

//游客登录公钥
NSString *const touristPublicKey = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCvcU4b67TM893babGOTANWsFlm2zyvhaOJg7eivbUfPO4oR7TYFYmTxekOKydQvlKns6+lPDvwCHpbSOuf7YpZgOsyJSUDNenBxdgYbrO4uuXIYNfGfgT6jiLv9T6R9xxkCyYqtXRZOSag+mMXa0zIM1jEBR5foPVzNZTt3WG4mQIDAQAB";

//自动登录队列
static dispatch_queue_t token_manager_sync_Login_queue(){
    static dispatch_once_t onceToken;
    static dispatch_queue_t token_manager_sync_Login_queue ;
    dispatch_once(&onceToken, ^{
        
        token_manager_sync_Login_queue = dispatch_queue_create("com.SmartCity.token.manager.Login", DISPATCH_QUEUE_SERIAL);
    });
    return token_manager_sync_Login_queue;
}

static NSString *tokenErrorMessageKey = @"tokenErrorMessage";

@implementation SCBaseManager (Token)

#pragma mark -setter And getter
- (void)setTokenErrorMessage:(NSString *)tokenErrorMessage{
    
    objc_setAssociatedObject(self, &tokenErrorMessageKey, tokenErrorMessage, OBJC_ASSOCIATION_COPY);
}
- (NSString *)tokenErrorMessage{
    
    return objc_getAssociatedObject(self, &tokenErrorMessageKey);
}

#pragma mark -解析token机制
- (void)parseToken:(NSDictionary *)headerDic urlResponse:(SCURLResponse *)urlResponse{
    
    if (headerDic) {
        //token提示信息
        NSString *retMessage = [headerDic objectForKey:@"retMessage"];
        //Token 状态 99代表token失效 其他正常
        NSString *retStatus = [headerDic objectForKey:@"retStatus"];
        
        if (retStatus) {
            
            if ([retStatus isEqualToString:@"99"]) {
                
                [[SCNetworkingConfigurationManager sharedInstance].tokenValidTarget_Array addObject:self];
                
                if (!retMessage || [retMessage isEqualToString:@""]) {
                    
                    retMessage = @"由于你长时间未操作，请重新登录";
                }
                
                self.cancel = YES;//取消回调
                [[SCApiProxy sharedInstance] cancelAllRequest];//取消所有未发出的请求
 
                //token处理线程,异步方法，执行串行队列
                dispatch_async(token_manager_sync_Login_queue(), ^{
                    
                    [self dealToken:retMessage response:urlResponse];
                });
            }else{//token正常，则将token失效的接口从config移除
                
                [[SCNetworkingConfigurationManager sharedInstance].tokenValidTarget_Array removeObject:self];
            }
        }
    }
}
#pragma mark -token处理
- (void)dealToken:(NSString *)retMessage response:(SCURLResponse *)response{
    
    NSLog(@"==1==处理token==1==%@",response.urlRequest);
    
    if (![SCNetworkingConfigurationManager sharedInstance].tokenValid) {
        
        if (![SCNetworkingConfigurationManager sharedInstance].tokenValidToCreateFail) {
            
            NSLog(@"==1==处理token==2==%@",response.urlRequest);
            
            [SCNetworkingConfigurationManager sharedInstance].tokenValidToCreateFail = YES;
            
            //设置自动登录次数
            self.autoLoginCount = 0;
            //设置token失效信息
            self.tokenErrorMessage = retMessage;
            
            if ([SCUserEntity shareInstance].isLogin) {
                //调用自动登录接口
                [self autoLogin:retMessage];
            }else{
                //调用游客登录接口
                [self touristLogin:retMessage];
            }
        }
        
    }
}
//游客自动登录
- (void)touristLogin:(NSString *)message{
    
    NSLog(@"游客token失效");
    //如果已经跳转到登录界面，则不再进行自动登录
    if ([SCNetworkingConfigurationManager sharedInstance].tokenValid) {
        return;
    }
    
    if (self.autoLoginCount >=3) {
        //如果已经跳转到登录界面，则不再进行跳转事件
        if (![SCNetworkingConfigurationManager sharedInstance].tokenValid) {
            [self initAlert:message];
        }
        return;
    }
    //登录次数加1
    self.autoLoginCount++;
    
    //1.时间戳
    NSDate *date = [NSDate date];
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    
    NSNumber *floatNumber = [NSNumber numberWithDouble:timeInterval*1000];
    //明文
    NSString *expressString = [NSString stringWithFormat:@"%@&%@",[SystemInfo shareSystemInfo].deviceId,floatNumber];
    
    //rsa加密
    SCRSACryptor *rsaCryptor = [[SCRSACryptor alloc]initWithPrivateKey:@"" publicKey:touristPublicKey];
    NSString *encryptString = [rsaCryptor encryptString:expressString];
    
    //请求参数
    NSDictionary *bodyDic = [NSDictionary dictionaryWithObject:encryptString forKey:@"ciphertext"];
    
    //*************记录日志*******//
    NSDictionary *args = @{@"operator":@"touristAutoLogin"};
    [[SCIntermediateHandle shareIntermediateHandle]preformTarget:@"SCLogInfoAction" method:@"writeLogInfo:args:" args:@"2",args,nil];
    
    NSURLRequest *request = [[SCIntermediateHandle shareIntermediateHandle]preformTarget:@"SCRegisterRequest" methodWithRequest:@"touristRequest" args:bodyDic,nil];
    
    if (request) {
        [self autoLoginAndTouristLogin:request type:0];
    }
    
}

//游客登录回调
- (void)touristCallBack:(id)data error:(NSError *)error{
    NSDictionary *callBackDic = (NSDictionary *)data;
    if (!callBackDic || error) {
        
        //*************记录日志*******//
        NSDictionary *args = @{@"operator":@"touristLoginFail"};
        [[SCIntermediateHandle shareIntermediateHandle]preformTarget:@"SCLogInfoAction" method:@"writeLogInfo:args:" args:@"2",args,nil];
        
        //登录失败继续调用登录接口
        [self touristLogin:self.tokenErrorMessage];
        return;
    }
    
    NSDictionary *bodyDic = [callBackDic objectForKey:@"body"];
    NSDictionary *headerDic = [callBackDic objectForKey:@"header"];
    
    if (headerDic) {
        
        NSString *retStatus = [headerDic valueForKey:@"retStatus"];
        
        //接口成功
        if ([@"0" isEqualToString:retStatus]) {
            //登录成功
            if (bodyDic) {
                
                NSLog(@"游客自动登录成功");
                
                if ([SCNetworkingConfigurationManager sharedInstance].tokenValid) {//如果已经跳转到登录界面，则结束调用token失效接口
                    
                    return;
                }
                
                self.cancel = NO;//将取消落脚点置为NO
                
                //userid
                [SCUserEntity shareInstance].uid = [bodyDic objectForKey:@"userId"];
                //授权token
                [SCUserEntity shareInstance].checkToken = [bodyDic objectForKey:@"token"];
                
                //*************记录日志*******//
                NSDictionary *args = @{@"operator":@"touristLoginSuccess"};
                [[SCIntermediateHandle shareIntermediateHandle]preformTarget:@"SCLogInfoAction" method:@"writeLogInfo:args:" args:@"2",args,nil];
                
                
                //同时处理在token失效期间，处理接口
                [[self class] todoTokenValidInter];
                
                return;
            }
        }
    }
    
    //*************记录日志*******//
    NSDictionary *args = @{@"operator":@"touristLoginFail"};
    [[SCIntermediateHandle shareIntermediateHandle]preformTarget:@"SCLogInfoAction" method:@"writeLogInfo:args:" args:@"2",args,nil];
    //登录失败继续调用登录接口
    [self touristLogin:self.tokenErrorMessage];
}
/*!
 *  @function 处理token失效期间，失败的接口
 */
+ (void)todoTokenValidInter{
    
    [SCNetworkingConfigurationManager sharedInstance].tokenValidToCreateFail = NO;
    
    NSArray *interfaceArray = [[NSArray alloc]initWithArray:[SCNetworkingConfigurationManager sharedInstance].tokenValidTarget_Array];
    
    [[SCNetworkingConfigurationManager sharedInstance].tokenValidTarget_Array removeAllObjects];
    
    if (interfaceArray.count >=1) {
        
        for (SCBaseManager *object in interfaceArray) {
            
            if (object) {
                
                if ([SCNetworkingConfigurationManager sharedInstance].tokenValid) { //如果已经跳转登录界面，则不再执行后续token失效接口
                    
                    return;
                }
                
                NSLog(@"token失效处理:%@==%@",NSStringFromSelector(object.requestAction),object.targetSelf);
                [[object class] execute:object.requestAction target:object.targetSelf callback:object.callBackAction argsList:object.argList];
            }
        }
    }
}
//自动登录
- (void)autoLogin:(NSString *)message{
    
    //如果已经跳转到登录界面，则不再进行自动登录
    if ([SCNetworkingConfigurationManager sharedInstance].tokenValid) {
        return;
    }
    NSString *mobile = [SCUserEntity shareInstance].mobile;
    if (mobile&& ![mobile isEqualToString:@""]) {
        NSDictionary *lastUserInfo =[[SCIntermediateHandle shareIntermediateHandle]preformTarget:@"SCRegisterDatabaseQueue" methodWithRequest:@"queryLastLoginUserInfoWithUserMobile:" args:mobile,nil];
        
        if (!lastUserInfo) {
            return;
        }
        NSString *lastUserPwd = [lastUserInfo objectForKey:@"passwordOfPlaintext"];
        if (lastUserPwd &&![lastUserPwd isEqualToString:@""]) {
            
            NSDictionary *bodyDic = @{@"password":lastUserPwd,@"loginName":mobile,@"loginType":@"6"};
            
            //如果自动登录次数大于等于3，则跳转到登录界面
            if (self.autoLoginCount >=3) {
                //如果已经跳转到登录界面，则不再进行跳转事件
                if (![SCNetworkingConfigurationManager sharedInstance].tokenValid) {
                    [self initAlert:message];
                }
                return;
            }
            
            //登录次数加1
            self.autoLoginCount++;
            
            //*************记录日志*******//
            NSDictionary *args = @{@"operator":@"autoLogin"};
            [[SCIntermediateHandle shareIntermediateHandle]preformTarget:@"SCLogInfoAction" method:@"writeLogInfo:args:" args:@"2",args,nil];
            
            NSURLRequest *request = [[SCIntermediateHandle shareIntermediateHandle]preformTarget:@"SCRegisterRequest" methodWithRequest:@"loginRequest:" args:bodyDic,nil];
            
            if (request) {
                [self autoLoginAndTouristLogin:request type:1];
            }
            
            
        }
    }
}
/**
 *  @abstract   游客和用户统一自动登录接口
 *
 *  @param  request 请求报文
 *  @param  type 1为用户，0位游客
 */
- (void)autoLoginAndTouristLogin:(NSURLRequest *)request type:(NSInteger)type{
    
    __weak typeof(self) weakSelf = self;
    NSNumber *number = [[SCApiProxy sharedInstance] callAPIWithRequest:request success:^(SCURLResponse *urlResponse) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        NSData *decryptedData = [self decryptDataIfEncrypted:urlResponse.responseData];
        
        if (!decryptedData) {
            
            decryptedData = urlResponse.responseData;
        }
        NSError __autoreleasing *error = nil;
        
        id result = nil;
        
        if (decryptedData){
            
            result = [NSJSONSerialization JSONObjectWithData:decryptedData options:NSJSONReadingAllowFragments error:&error];
        }
        
        NSLog(@"自动登录成功%@/n=%@/n=%@",urlResponse.requestId,result,error);
        if (type == 1) {
            
            [strongSelf autoLoginCallBack:result error:error];
        }else{
            
            [strongSelf touristCallBack:result error:error];
        }
        
    } fail:^(SCURLResponse *urlResponse) {
        
        NSLog(@"自动登录失败%@",urlResponse.requestId);
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (type == 1) {
            
            [strongSelf autoLoginCallBack:nil error:urlResponse.error];
        }else{
            
            [strongSelf touristCallBack:nil error:urlResponse.error];
        }
    }];
    
    NSLog(@"自动登录开始%@",number);
}

//自动登录结果回调
- (void)autoLoginCallBack:(id)data error:(NSError *)error{
    
    NSDictionary *callBackDic = (NSDictionary *)data;
    if (!callBackDic || error) {
        //*************记录日志*******//
        NSDictionary *args = @{@"operator":@"loginFail"};
        [[SCIntermediateHandle shareIntermediateHandle]preformTarget:@"SCLogInfoAction" method:@"writeLogInfo:args:" args:@"2",args,nil];
        
        //登录失败继续调用登录接口
        [self autoLogin:self.tokenErrorMessage];
        return;
    }
    
    NSDictionary *bodyDic = [callBackDic objectForKey:@"body"];
    
    if (bodyDic) {
        
        id resultFlag = [bodyDic objectForKey:@"resultFlag"];
        
        if ([resultFlag intValue] == 1) {
            
            NSLog(@"自动登录token成功");
            
            if ([SCNetworkingConfigurationManager sharedInstance].tokenValid) {//如果已经跳转到登录界面，则结束调用token失效接口
                
                return;
            }
            
            //userid
            [SCUserEntity shareInstance].uid = [bodyDic objectForKey:@"userId"];
            //授权token
            [SCUserEntity shareInstance].checkToken = [bodyDic objectForKey:@"token"];
            //用户权限
            [SCUserEntity shareInstance].userRoleFlag = [bodyDic objectForKey:@"developFlag"];
            
            //*************记录日志*******//
            NSDictionary *args = @{@"operator":@"loginSuccess"};
            [[SCIntermediateHandle shareIntermediateHandle]preformTarget:@"SCLogInfoAction" method:@"writeLogInfo:args:" args:@"2",args,nil];
            
            //同时处理在token失效期间，处理接口
            [[self class] todoTokenValidInter];
            return;
        }
    }
    //*************记录日志*******//
    NSDictionary *args = @{@"operator":@"loginFail"};
    [[SCIntermediateHandle shareIntermediateHandle]preformTarget:@"SCLogInfoAction" method:@"writeLogInfo:args:" args:@"2",args,nil];
    
    //登录失败继续调用登录接口
    [self autoLogin:self.tokenErrorMessage];
}
//初始化Alert
- (void)initAlert:(NSString *)message{
    
    [[SCIntermediateHandle shareIntermediateHandle]preformTarget:@"AppDelegate" method:@"showTokenErr:" args:message,nil];
   
}

@end
