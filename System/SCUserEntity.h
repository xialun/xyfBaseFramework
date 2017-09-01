//
//  SCUserEntity.h
//  SmartCity
//
//  Created by sea on 14-2-26.
//  Copyright (c) 2014年 sea. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, SCUserPermission) {
    SCUserAuthenticated,                    //已认证用户
    SCUserGuest,                            //游客用户
    SCUserRegister                     //注册用户 -->//取消了
};


@interface SCUserEntity : NSObject

/*!
 @property
 @abstract      用户唯一id
 
 */
@property (nonatomic, strong)   NSString *uid;

/*!
 @property  
 @absract   用户权限
 
 */
@property (nonatomic,strong)   NSString *isRoleAuth;
/*!
 @property
 @absract   用户是否已经登录
 
 */
@property (nonatomic,assign)    BOOL isLogin;

/*!
 @property
 @abstract      用户手机号
 
 */
@property (nonatomic, strong)   NSString *mobile;



/*!
 @property
 @abstract      单点登录需使用的token
 
 */
@property (nonatomic, strong)   NSString *accessToken;



/*!
 @property
 @abstract      登录名
 
 */
@property (nonatomic, strong)   NSString *loginName;



/*!
 @property
 @abstract      密码

 */
@property (nonatomic, strong)   NSString *password;


/*!
 @property
 @abstract      明文密码
 
 */
@property (nonatomic, strong)   NSString *passwordOfPlaintext;



/*!
 @property
 @abstract      手势密码
 
 */
@property (nonatomic, strong)   NSString *gesturePassword;


/*!
 @property
 @abstract      手势密码开关
 
 */
@property (nonatomic, strong)   NSString *squredFlag;



/*!
 @property
 @abstract      用户名
 
 */
@property (nonatomic, strong)   NSString *username;



/*!
 @property
 @abstract      用户权限
 
 */
@property (nonatomic, assign)   SCUserPermission    permission;



/*!
 @property
 @abstract      市民卡卡号
 
 */
@property (nonatomic, strong) NSString *citizenCard;



/*!
 @property
 @abstract      身份证号码
 
 */
@property (nonatomic, strong) NSString *idNumber;



/*!
 @property
 @abstract      实名状态
 
 */
@property (nonatomic, strong) NSString *realNameState;



/*!
 @property
 @abstract
 
 */
@property (nonatomic, strong) NSString *familyId;

/*!
 @property
 @abstract
 
 */
@property (nonatomic, strong) NSString *bloodUrl;


/*!
 @property
 @result        用户积分
 
 */
@property (nonatomic, strong) NSString *score;



/*!
 @property
 @result        用户头像ID
 
 */
@property (nonatomic, strong) NSString *headPortraitID;

/*!
 @property
 @result        token信息，此值用于校验用户名是否有效
 */
@property (nonatomic,strong) NSString *checkToken;

//-----------v1.9------------//
//当前设备是否支持指纹
@property (nonatomic, assign) BOOL isSupportFinger;
//当前用户是选择那种验证方式:0代表没有验证方式（既刚注册成功用户),1 密码验证，2 手势验证，3 指纹验证 @""代表没有选择辅助验证方式
@property (nonatomic, strong) NSString *verification;

/*!
 @property      存储消息数
 */
@property (nonatomic,strong) NSMutableDictionary *msgNumberDic;

/*!
 @property     判断用户是普通用户还是开发组用户  0--显示工作圈创客   1--不显示
 */
@property (nonatomic,strong)NSString *userRoleFlag;



+ (instancetype)shareInstance;

- (NSDictionary*)bodyDic;

- (void)clearUserData;
//形成关于密码验证的字典类型
- (NSDictionary *)bodyDicForver;

@end


