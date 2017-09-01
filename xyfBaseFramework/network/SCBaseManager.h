//
//  SCBaseManger.h
//  SmartCity
//
//  Created by sea on 14-2-27.
//  Copyright (c) 2014年 sea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCApiProxy.h"
#import "SCNetworkingConfigurationManager.h"
#import <objc/runtime.h>

typedef NS_ENUM(NSInteger, CallbackTypeForManager) {
    
    CallbackFromDataBase        =   0,                    //从数据库读取完数据后返回
    CallbackFromRequest,                     //从网络获取完数据后返回
    CallbackFromCancel,                     //操作被取消后,返回标识
};


//定义从数据库获取业务数据的block别名
typedef id (^BizDataGetter)(void);

//定义构建网络请求的block别名
typedef NSURLRequest *(^RequestGetter)(void);

//定义处理网络数据的block别名
typedef id (^NetWorkCompletionHandler)(NSURLResponse* response, NSData* data, NSError* connectionError);

//定义更新数据库的block别名
typedef BOOL (^UpdateDatabaseSetter)(id data);



@interface SCBaseManager : NSObject {
    
    //查询数据库,返回UI所需要的结构化数据
    BizDataGetter                   bizDataGetter;
    
    //构建网络服务的request,并返回NSURLRequest 对象
    RequestGetter                   requestGetter;
    
    //配置网络服务返回后数据的处理流程
    NetWorkCompletionHandler        handler;
    
    //配置数据库数据更新流程
    UpdateDatabaseSetter            updateDatabaseSetter;
    
    //用于存放database,http请求所需的各个参数
    NSMutableArray                  *_argList;
    
    __block NSError                 *_error;
}
@property (nonatomic, strong) NSMutableArray    *argList;
@property (nonatomic, strong) __block NSError   *error;
@property (atomic, assign,getter=isCancel) BOOL cancel;
//记录请求的类
@property (nonatomic,strong) id     targetSelf;
//记录请求的方法
@property (nonatomic,assign) SEL    requestAction;
//记录请求的回调方法
@property (nonatomic,assign) SEL    callBackAction;

//记录自动登录次数
@property (nonatomic,assign)       NSInteger  autoLoginCount;


/*!
 @method
 @abstract      程序入口管理类方法,该方法内部有一个固定模式的流程
 
                1.配置entrance方法中的设置(BizDataGetter,RequestGetter,NetWorkCompletionHandler,UpdateDatabaseSetter)
                2.
 
 
 
 @param         entrance
                继承SCBaseManager的子类,根据具体业务功能,定义公开消息函数。entrance方法中需要设置(BizDataGetter,RequestGetter,NetWorkCompletionHandler,UpdateDatabaseSetter)
 
 @param         target
                方法中等待界面刷新的对象
 
 @param         method
                target对应的消息函数。method需要两个参数,例:- (void)testCallback:(id)data error:(NSError *)error
                data:已经被结构化的数据。数据由BizDataGetter,NetWorkCompletionHandler产生
                error:错误信息
 
 @param         arg
                可变参数队列,用于传入BizDataGetter,RequestGetter所需要的参数
                注:只可以是对象类型,且以nil结束
 
 
 @note          基类内部定义了6个步骤的处理流程
 
                a.根据entrance中配置的BizDataGetter,查询数据库,获取需要的结构化数据,如果获取成功,则至b;否则,该方法结束
                b.通知UI更新
                c.根据entrance中配置的RequestGetter,获取需要发送的NSURLRequest对象,获取成功,则至d;否则,该方法结束
                d.发送request请求
                e.将网络服务返回的数据交给NetWorkCompletionHandler处理。数据正确,返回结构化数据,至f;否则,该方法结束
                f.通知UI更新
                g.将步骤e返回的数据交给UpdateDatabaseSetter做数据库更新
                h.方法正式结束
 
 @result        无
 */
+ (void)execute:(SEL)entrance target:(id)target callback:(SEL)method args:(id)arg,...;

//+ (void)execute:(SEL)entrance target:(id)target callback:(SEL)method args:(id)arg,...;

#pragma mark -

/*!
 @function
 @abstract      设置异步请求时的入口方法
 
 @param         entrance                入口方法
 @param         args                    入口方法中将调用的方法的参数
 
 @result        自身实例
 */
- (id)initWithExecuteAsynchronous:(SEL)entrance args:(id)arg,...;



/*!
 @function
 @abstract      设置异步请求时接收到响应头时的回调方法
 
 @param         target                  回调方法所在的目标
 @param         callback                回调方法    该方法需要一个参数,为返回的ResponseHeaders
 
 @note          *******未实现*******
 
 @result
 */
- (void)setReceiveResponseHeaders:(id)target callback:(SEL)callback;



/*!
 @function
 @abstract      设置异步请求完成时的回调方法
 
 @param         target                  回调方法所在的目标
 @param         callback                回调方法 该方法需要两个参数,第一个为response，类型任意; 第二个为NSError
 
 @result
 */
- (void)setRequestFinished:(id)target callBack:(SEL)callback;



/*!
 @function
 @abstract      入口方法开始执行
 
 @result
 */
- (void)executeAsynchronous;



/*!
 @function
 @abstract      取消接收到http请求头的回调方法
 
 @result
 */
- (void)cancelReceiveResponseHeadersCallback;



/*!
 @function
 @abstract      取消http请求完成的回调方法
 
 @result
 */
- (void)cancelRequestFinishedCallback;


/*!
 @function
 @abstract      取消全部http请求的回调方法
 
 @result
 */
- (void)cancelAllCallback;

/*!
 *  回调token失效的接口
 */
+ (void)execute:(SEL)entrance target:(id)target callback:(SEL)method argsList:(id)argList;

/*!
 *  @abstract   返回参数解密
 */
- (NSData*)decryptDataIfEncrypted:(NSData*)data;
@end
