//
//  SCBaseManager.m
//  SmartCity
//
//  Created by sea on 14-2-27.
//  Copyright (c) 2014年 sea. All rights reserved.
//

#import "SCBaseManager.h"
#import "SystemInfo.h"

#import "NSString+Additional.h"
#import "NSData+CustomExtensions.h"

#import "AFNetworking.h"
#import "SCBaseManager+Token.h"

@interface SCBaseManager (){
    
    SEL             _entranceMethod;
    
    id              _finishTarget;
    Class           _originalfinishTargetClass;
    
    SEL             _finishCallback;
    
    //初始化全局变量
    Class           m_originalTargetClass;
    
    id              m_target;
    
    SEL             m_method;
    
    
}

@property (nonatomic,strong,readwrite) NSMutableArray *requestIDList;

@end

@implementation SCBaseManager

@synthesize argList = _argList;

#pragma mark -getter And setter
- (NSMutableArray *)requestIDList{
    
    if (_requestIDList == nil) {
        
        _requestIDList = [[NSMutableArray alloc]init];
    }
    return _requestIDList;
}

#pragma mark -public Method
+ (void)execute:(SEL)entrance target:(id)target callback:(SEL)method args:(id)arg,... {
    
    va_list args;
    
    SCBaseManager *object = [[self alloc] init];
    
    va_start(args, arg);
    
    [object setArguments:args arg:arg];
    
    va_end(args);
    
    //变量赋值
    object.targetSelf = target;
    
    object.requestAction = entrance;
    
    object.callBackAction = method;
    
    IMP imp = [object methodForSelector:entrance];
    void (*func)(__strong id, SEL,...) = (void(*)(__strong id, SEL,...))imp;
    
    func(object, entrance);
    
    [object actual:target callback:method];
}
#pragma mark -重写execute方法,此方法只针对登录成功之后调用token失效接口
+ (void)execute:(SEL)entrance target:(id)target callback:(SEL)method argsList:(id)argList{
    
    SCBaseManager *object = [[self alloc] init];
    
    object.argList = [[NSMutableArray alloc]initWithArray:argList];
    
    //此处用来检测entrance是否为空
    if (![object respondsToSelector:entrance]) {
        //        [object  initAlert:NSStringFromSelector(entrance)];
        return;
    }
    IMP imp = [object methodForSelector:entrance];
    
    void (*func)(__strong id, SEL,...) = (void(*)(__strong id, SEL,...))imp;
    
    func(object, entrance);
    
    [object actual:target callback:method];
}
#pragma mark -private method
- (void)actual:(id)target callback:(SEL)method {
    
    Class originalTargetClass = object_getClass(target);
    
    if (bizDataGetter != NULL) {
        
        //查询数据库
        id bizData = bizDataGetter();
        
        if (bizData) {//如果获取到数据库数据,则回调UI方法进行刷新
            
            //显式调用更新UI函数
            if (originalTargetClass == object_getClass(target)) {
                
                if (method) {
                    
                    void (*imp)(id, SEL, id, NSError *,CallbackTypeForManager ) = (void(*)(id, SEL, id, NSError *,CallbackTypeForManager ))[target methodForSelector:method];
                    
                    if (self.isCancel) {
                        
                        return;
                    }
                    else {
                    
                        (*imp)(target, method, bizData, nil,CallbackFromDataBase);
                    }
                }
            }
        }
    }
    

    if (requestGetter != NULL) {
        
        //获取request对象
        NSURLRequest *request = requestGetter();
        //请求不为空并且当前有网络
        if (request && [SCNetworkingConfigurationManager sharedInstance].isReachable) {
            
            NSNumber *requestID = [[SCApiProxy sharedInstance] callAPIWithRequest:request success:^(SCURLResponse *urlResponse) {
                //可优先处理数据的共通
                //增加解密
                NSData *decryptedData = [self decryptDataIfEncrypted:urlResponse.responseData];
                
                //如果解密失败，则返回原始数据
                if (!decryptedData) {
                    
                    decryptedData = urlResponse.responseData;
                }
                
                //数据校验-对返回的数据做非空和NSNULL判断，并且判断token是否有效
                decryptedData = [self checkAndDealBody:decryptedData response:urlResponse];
                
                if (handler != NULL) {
                    
                    //将报文数据交由解析模块处理
                    id bizData = handler(urlResponse.response, decryptedData,nil);
                    
                    //取消，则统一将落脚点抛出
                    if (self.isCancel) {
                        
                        return;
                    }
                    //将最新数据更新到页面
                    if (originalTargetClass == object_getClass(target)) {
                        
                        if (method) {
                            
                            //展示结构化数据
                            void (*imp)(id, SEL, id, NSError *,CallbackTypeForManager) = (void(*)(id, SEL, id, NSError *,CallbackTypeForManager))[target methodForSelector:method];
                            
                            (*imp)(target, method, bizData, _error,CallbackFromRequest);
                        }
                    }
                    
                    if (updateDatabaseSetter != NULL) {
                        
                        if (bizData) {
                            
                            dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                            dispatch_async(concurrentQueue, ^{
                                
                                //更新数据库
                                updateDatabaseSetter(bizData);
                                
                            });
                        }
                    }
                }
            } fail:^(SCURLResponse *urlResponse) {
                
                if (originalTargetClass == object_getClass(target)) {
                    
                    if (method) {
                        
                        if (self.isCancel) {
                            
                            return;
                        }
                        //展示结构化数据
                        void (*imp)(id, SEL, id, NSError *,CallbackTypeForManager) = (void(*)(id, SEL, id, NSError *,CallbackTypeForManager))[target methodForSelector:method];
                        
                        (*imp)(target, method, nil, urlResponse.error,CallbackFromRequest);
                    }
                }

            }];
            
            [self.requestIDList addObject:requestID];
        }
        else {//无请求时(NSURLRequest构建失败),返回空
            
            if (handler != NULL) {
                
                //将报文数据交由解析模块处理
                id bizData = nil;
                
                //将最新数据更新到页面
                if (originalTargetClass == object_getClass(target)) {
                    
                    if (method) {
                        
                        //展示结构化数据
                        void (*imp)(id, SEL, id, NSError *,CallbackTypeForManager) = (void(*)(id, SEL, id, NSError *,CallbackTypeForManager))[target methodForSelector:method];
                        
                        if (self.isCancel) {
                            
                            return;
                        }
                        else {
                            
                            NSError *error = [NSError errorWithDomain:@"请求构建失败" code:-10 userInfo:nil];
                            
                            (*imp)(target, method, bizData, error,CallbackFromRequest);
                        }
                    }
                }
            }
        }
    }
}

- (void)setArguments:(va_list)args arg:(id)arg {
    
    if (arg) {
        
        _argList = [[NSMutableArray alloc] initWithObjects:arg, nil];
        
        while (YES) {
            
            id obj = nil;
            
            obj = va_arg(args, id);
            
            if (!obj ) {
                
                break;
            }
            
            [_argList addObject:obj];
        }
    }
}
/**
 *  将网络接口返回的数据做统一处理，如果body里为NSNULL或者空字符串，或者为nil，则统一将body设为nil，否则按源码返回
 *
 *  1.如果data为空，则返回data不作处理
 *  2.如果json解析失败，则返回参数data
 *  3.如果data中body不为NSNULL或者空字符串，则返回参数data
 *  4.如果data中body为NSNUll或者空字符串，则返回修改之后的数据
 *
 *  @param  网络返回NSData
 *  @return 处理之后的NSData
 */
- (NSData *)checkAndDealBody:(NSData *)data response:(SCURLResponse *)urlResponse{
    
    //1.
    if (!data) {
        
        return data;
    }
    NSError __autoreleasing *error = nil;
    
    id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    NSLog(@"middle:%@\n======\n%@\n====%@",urlResponse.urlRequest,result,urlResponse.requestId);
    //2.
    if (result && !error) {
        
        NSDictionary *body = [result objectForKey:@"body"];
        
        //根据开关检验token
        if ([SCNetworkingConfigurationManager sharedInstance].isCheckToken) {
            
            [self parseToken:[result objectForKey:@"header"] urlResponse:urlResponse];//解析token
        }
        NSLog(@"==1==返回结果==2===%@",urlResponse.urlRequest);
        
        NSMutableDictionary *resultDic = [[NSMutableDictionary alloc]init];
        
        //3.
        if (body) {
            
            if ([result objectForKey:@"header"]) {
                
                [resultDic setObject:[result objectForKey:@"header"] forKey:@"header"];
                
                NSData *resultData = [NSJSONSerialization dataWithJSONObject:resultDic options:NSJSONWritingPrettyPrinted error:&error];
                
                if (resultData && !error) {
                    
                    return resultData;
                }
            }
        }
    }
    return data;
}


#pragma mark - 对象方法

/*!
 @function
 @abstract      设置异步请求时的入口方法
 
 @param         entrance                入口方法
 @param         args                    入口方法中将调用的方法的参数
 
 @result        自身实例
 */
- (id)initWithExecuteAsynchronous:(SEL)entrance args:(id)arg,... {
    
    self = [super init];
    
    if (self && entrance) {
        
        _entranceMethod = entrance;
        
        va_list args;
        
        va_start(args, arg);
        
        [self setArguments:args arg:arg];
        
        va_end(args);
    }
    
    return self;
}



/*!
 @function
 @abstract      设置异步请求时接收到响应头时的回调方法
 
 @param         target                  回调方法所在的目标
 @param         callback                回调方法    该方法需要一个参数,为返回的ResponseHeaders
 
 @result
 */
- (void)setReceiveResponseHeaders:(id)target callback:(SEL)callback {
    
    
}



/*!
 @function
 @abstract      设置异步请求完成时的回调方法
 
 @param         target                  回调方法所在的目标
 @param         callback                回调方法 该方法需要两个参数,第一个为response，类型任意; 第二个为NSError
 
 @result
 */
- (void)setRequestFinished:(id)target callBack:(SEL)callback {
    
    _finishTarget = target;
    _originalfinishTargetClass = object_getClass(target);
    
    _finishCallback = callback;
}



/*!
 @function
 @abstract      入口方法开始执行
 
 @result
 */
- (void)executeAsynchronous {
    
    if (_entranceMethod) {
        
        IMP imp = [self methodForSelector:_entranceMethod];
        void (*func)(__strong id, SEL,...) = (void(*)(__strong id, SEL,...))imp;
        func(self, _entranceMethod);
        
        [self actual:_finishTarget callback:_finishCallback];
    }    
}



/*!
 @function
 @abstract      取消接收到http请求头的回调方法
 
 @result
 */
- (void)cancelReceiveResponseHeadersCallback {
    
    _cancel = YES;
}



/*!
 @function
 @abstract      取消http请求完成的回调方法
 
 @result
 */
- (void)cancelRequestFinishedCallback {
    
    _cancel = YES;
    
    if (_finishTarget && _finishCallback && _originalfinishTargetClass == object_getClass(_finishTarget)) {
        
        void (*imp)(id, SEL, id, NSError *,CallbackTypeForManager ) = (void(*)(id, SEL, id, NSError *,CallbackTypeForManager ))[_finishTarget methodForSelector:_finishCallback];
        
        NSError *error = [NSError errorWithDomain:@"操作被取消" code:2 userInfo:nil];
        (*imp)(_finishTarget, _finishCallback, nil, error,CallbackFromCancel);
    }
    
}


/*!
 @function
 @abstract      取消全部http请求的回调方法
 
 @result
 */
- (void)cancelAllCallback {
    
    _cancel = YES;
    
    [self cancelRequestFinishedCallback];
    
    _finishTarget = nil;
    _originalfinishTargetClass = NULL;
    
    _finishCallback = NULL;
    
    bizDataGetter = NULL;
    requestGetter = NULL;
    handler = NULL;
    updateDatabaseSetter = NULL;
    
    _entranceMethod = NULL;
}


#pragma mark -private method
//如果报文中是有加密body字段的，将其解析返回。必要条件是有header(包含devId字段)，并且有body。默认调用方法的报文都是body已加密的
- (NSData*)decryptDataIfEncrypted:(NSData*)data {
    
    if (data) {
        //解密data
        NSString *devId = [SystemInfo shareSystemInfo].deviceId;
        if (devId != nil && ![devId isEqualToString:@""]) {
            NSString *strEncryptedData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (strEncryptedData) {
                NSData *encryptedData = [strEncryptedData hexStringToNSData];
                if (encryptedData) {
                    NSString *encryptKey = [NSString stringWithFormat:@"%@%@", kEncryptKeyHeader, devId];
                    
                    encryptKey = [NSData fitAES256EncryptKey:encryptKey];
                    
                    NSData *decryptedData = [encryptedData AES256DecryptWithKey:encryptKey keyEncoding:NSASCIIStringEncoding];
                    
                    NSString *str = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
                    
                    if (str && str.length > 0){
                        str = nil;
                        return decryptedData;
                    }
                }
            }
        }
    }
    return data;
}

@end
