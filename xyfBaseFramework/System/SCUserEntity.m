//
//  SCUserEntity.m
//  SmartCity
//
//  Created by sea on 14-2-26.
//  Copyright (c) 2014年 sea. All rights reserved.
//

#import "SCUserEntity.h"
#import <UIKit/UIKit.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "SCBaseObserveDefine.h"
static SCUserEntity *userEntity = nil;

@implementation SCUserEntity


/*!
 @function
 @abstract      用户对象的实体单例
 
 @note          该对象中的对象属性不可被多线程共享访问修改
 
 @result        返回用户的单例对象
 */
+ (instancetype)shareInstance {
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        userEntity = [SCUserEntity new];
        
    });
    
    return userEntity;
}


//--------------------做非空判断--------------------
- (NSString *)uid{
    if (!isValid(_uid)){
        _uid = @"";
    }
    return _uid;
}

- (NSString *)mobile{
    if (!isValid(_mobile)){
        _mobile = @"";
    }
    return _mobile;
}

- (NSString *)accessToken{
    if (!isValid(_accessToken)){
        _accessToken = @"";
    }
    return _accessToken;
}

- (NSString *)loginName{
    if (!isValid(_loginName)){
        _loginName = @"";
    }
    return _loginName;
}

- (NSString *)password{
    if (!isValid(_password)){
        _password = @"";
    }
    return _password;
}

- (NSString *)passwordOfPlaintext{
    if (!isValid(_passwordOfPlaintext)) {
        _passwordOfPlaintext = @"";
    }
    
    return _passwordOfPlaintext;
}

- (NSString *)gesturePassword{
    if (!isValid(_gesturePassword)){
        _gesturePassword = @"";
    }
    return _gesturePassword;
}

- (NSString *)squredFlag{
    if (!isValid(_squredFlag)) {
        _squredFlag = @"";
    }
    
    return _squredFlag;
}

- (NSString *)username{
    if (!isValid(_username)){
        _username = @"";
    }
    return _username;
}

- (NSString *)citizenCard{
    if (!isValid(_citizenCard)){
        _citizenCard = @"";
    }
    return _citizenCard;
}

- (NSString *)idNumber{
    if (!isValid(_idNumber)){
        _idNumber = @"";
    }
    return _idNumber;
}

- (NSString *)realNameState{
    if (!isValid(_realNameState)){
        _realNameState = @"";
    }
    return _realNameState;
}

- (NSString *)familyId{
    if (!isValid(_familyId)){
        _familyId = @"";
    }
    return _familyId;
}

- (NSString *)bloodUrl{
    if (!isValid(_bloodUrl)){
        _bloodUrl = @"";
    }
    return _bloodUrl;
}

- (NSString *)score{
    if (!isValid(_score)){
        _score = @"";
    }
    return _score;
}

//--------------------↑做非空判断↑--------------------

//---------v1.9----//
- (BOOL)isSupportFinger
{
    if ([[UIDevice currentDevice].systemVersion floatValue]<8.0) {
        return NO;
    }else{
        LAContext *context = [[LAContext alloc]init];
        return [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
    }
}
- (NSString *)verification
{
    if (!isValid(_verification)) {
        _verification = @"";
    }
    return _verification;
}

- (NSString *)checkToken{
    
    if (!isValid(_checkToken)) {
        _checkToken = @"";
    }
    return _checkToken;
}

- (NSMutableDictionary *)msgNumberDic{
    
    if (!isValid(_msgNumberDic)) {
        
        _msgNumberDic = [[NSMutableDictionary alloc]init];
    }
    return _msgNumberDic;
}

- (NSString *)userRoleFlag{
    if (!isValid(_userRoleFlag)) {
        
        _userRoleFlag = @"";
    }
    return _userRoleFlag;
}
- (NSDictionary*)bodyDic{
    NSDictionary *bodyDic = @{@"userId":            self.uid ? self.uid : @"",
                              @"loginName":         self.loginName ? self.loginName : @"",
                              @"password":          self.password ? self.password : @"",
                              @"gesturePassword":   self.gesturePassword ? self.gesturePassword : @"",
                              @"userName":          self.username ? self.username : @"",
                              @"permission":        [NSString stringWithFormat:@"%d", self.permission],
                              @"citizenCard":       self.citizenCard ? self.citizenCard : @"",
                              @"idNumber":          self.idNumber ? self.idNumber : @"",
                              @"realNameState":     self.realNameState ? self.realNameState : @"",
                              @"mobile":            self.mobile ? self.mobile : @"",
                              @"passwordOfPlaintext":self.passwordOfPlaintext ? self.passwordOfPlaintext : @""};
    return bodyDic;
}
- (NSDictionary *)bodyDicForver
{
    NSDictionary *bodyDic = @{@"userId":        self.uid ? self.uid :@"",
                              @"verification":  self.verification ? self.verification : @"",
                              @"userMobile":    self.mobile ? self.mobile : @""
                              };
    return bodyDic;
}
- (void)clearUserData{
    userEntity.uid                          = nil;
    userEntity.mobile                       = nil;
    userEntity.accessToken                  = nil;
    userEntity.loginName                    = nil;
    userEntity.password                     = nil;
    userEntity.passwordOfPlaintext          = nil;
    userEntity.gesturePassword              = nil;
    userEntity.username                     = nil;
    userEntity.permission                   = SCUserGuest;//此值不能改
    userEntity.citizenCard                  = nil;
    userEntity.idNumber                     = nil;

    userEntity.realNameState                = nil;
    userEntity.squredFlag                   = nil;
    userEntity.score                        = nil;
    
    userEntity.bloodUrl                     = nil;
    userEntity.familyId                     = nil;
    userEntity.verification                 = nil;
    
    userEntity.isRoleAuth                   = nil;
    
    //清除token
    userEntity.checkToken                   = nil;
    //清除消息数
    userEntity.msgNumberDic                 = nil;
    //用户分权
    userEntity.userRoleFlag                 = nil;
    
}

@end
