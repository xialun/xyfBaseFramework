//
//  PacketHandle.m
//  NetworkHandle
//
//  Created by xyf on 17/7/18.
//  Copyright © 2017年 xyf. All rights reserved.ik
//

#import "SCPacketHandle.h"
#import "SCUserEntity.h"
#import "SystemInfo.h"
#import "NSString+Additional.h"
#import "NSData+CustomExtensions.h"
#import "SCBaseObserveDefine.h"
@implementation SCPacketHandle

+ (NSData *)appendingPostDataWithBodyDictionary:(id)body {
    
    SystemInfo *systemInfo = [SystemInfo shareSystemInfo];
    SCUserEntity *userEntity = [SCUserEntity shareInstance];
    
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    NSMutableDictionary *header = [[NSMutableDictionary alloc] initWithCapacity:11];
    
    [header setObject:@"" forKey:@"retStatus"];
    [header setObject:@"" forKey:@"retMessage"];
    [header setObject:systemInfo.deviceId forKey:@"devId"];//设备ID
    [header setObject:@"3" forKey:@"devType"];//设备类型
    [header setObject:systemInfo.appId forKey:@"appId"];//应用ID
    if ([Appkey isEqualToString:@"gaochun"]) {
        [header setObject:@"gaochun" forKey:@"appName"];
    }else if([Appkey isEqualToString:@"pukou"]){
        [header setObject:@"pukou" forKey:@"appName"];
    }else if ([Appkey isEqualToString:@"lishui"]){
        [header setObject:@"lishui" forKey:@"appName"];
    }else{
        [header setObject:@"" forKey:@"appName"];
    }
    [header setObject:@"" forKey:@"funcId"];//功能ID ********功能未知,暂填空
    [header setObject:systemInfo.appVersion forKey:@"appVersion"];//版本，必填
    [header setObject:[systemInfo  devicePlatformString] forKey:@"deviceModel"];
    
    [header setObject:@"0" forKey:@"userType"];//用户类型，公积金明细需要. 0实名   1注册  2游客
    
    //uid
    NSString *uid = userEntity.uid;//2.0 0000改造
    
    //AES加密，hex编码,UID AES加密
    NSString *encryptUIDKey = [NSString stringWithFormat:@"%@%@", kEncryptKeyHeader, systemInfo.deviceId];
    
    encryptUIDKey = [NSData fitAES256EncryptKey:encryptUIDKey];
    
    NSData *uidEncryptedData = [[uid dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptWithKey:encryptUIDKey keyEncoding:NSASCIIStringEncoding];
    NSString *uidString = [uidEncryptedData stringWithHexBytes];
    [header setObject:uidString forKey:@"userId"];//用户ID     *******需登录后获取
    
    if (userEntity.checkToken.length>0) {
        
        [header setObject:userEntity.checkToken forKey:@"accessToken"];//鉴权认证    ****需游客和用户登录后获取
    }
    else {
        
        [header setObject:@"" forKey:@"accessToken"];
    }
    
    [header setObject:[NSString stringWithFormat:@"%ld",userEntity.permission] forKey:@"userType"];//用户类型   ******需登录后获取,默认为0
    
    //systemInfo.appVersion
    //  [header setObject:systemInfo.appVersion forKey:@"appVersion"];//应用版本
    [header setObject:systemInfo.OSVersion forKey:@"osVersion"];//操作系统版本
    
    [params setObject:header forKey:@"header"];
    
    [params setObject:body forKey:@"body"];
    
    __autoreleasing NSError *error = nil;
    
    //NSData *paramsData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
    
    //add by gao_yufeng begin
    NSData *headerData = [NSJSONSerialization dataWithJSONObject:header options:NSJSONWritingPrettyPrinted error:&error];
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *headerString = [[NSString alloc] initWithData:headerData encoding:NSUTF8StringEncoding];
    NSString *notEncrptbodyString = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
    DLog(@"==未加密body===%@",notEncrptbodyString);
    //AES加密，hex编码
    NSString *encryptKey = [NSString stringWithFormat:@"%@%@", kEncryptKeyHeader, systemInfo.deviceId];
    
    encryptKey = [NSData fitAES256EncryptKey:encryptKey];
    
    NSData *bodyEncryptedData = [bodyData AES256EncryptWithKey:encryptKey keyEncoding:NSASCIIStringEncoding];
    NSString *bodyString = [bodyEncryptedData stringWithHexBytes];
    
    //add by gao_yufeng end
    if (bodyString == nil || [bodyString isEqualToString:@""]) {
        bodyString = @"{ \n}";
    }
    //NSString *paramsString = [[NSString alloc] initWithData:paramsData encoding:NSUTF8StringEncoding];
    NSString *paramsString = [NSString stringWithFormat:@"{\n \"header\": %@, \n \"body\": %@\n}", headerString, bodyString];
    
    NSString *postString = [NSString stringWithFormat:@"params=%@",paramsString];
    
    postString = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)postString,
                                                                           NULL,
                                                                           (CFStringRef)@"+&",
                                                                           kCFStringEncodingUTF8));
    DLog(@"======请求 url=====%@",paramsString);
    
    
    //    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingMacChineseSimp);
    //    NSData *postData = [postString dataUsingEncoding: enc allowLossyConversion: YES];
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
    if (!error) {
        
        return postData;
    }
    
    return nil;
}

@end
