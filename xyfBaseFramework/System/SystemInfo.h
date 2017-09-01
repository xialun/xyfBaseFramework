//
//  SystemInfo.h
//  MIP
//
//  Created by sea on 13-11-29.
//  Copyright (c) 2013年 Sea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import <CoreMotion/CoreMotion.h>


FOUNDATION_EXTERN NSString *const kSystemNetworkChangedNotification;

typedef NS_ENUM(NSInteger, DeviceSize){
    iPhone35inch = 1,
    iPhone4inch = 2,
    iPhone47inch = 3,
    iPhone55inch = 4
};

@interface SystemInfo : NSObject {
    
    AFNetworkReachabilityManager            *_internetReach;
}


//静态绑定属性
@property (nonatomic, retain, readonly) NSString * appId;//应用标识
@property (nonatomic, retain, readonly) NSString * appVersion;//应用版本

@property (nonatomic, retain, readonly) NSString * deviceId;//设备唯一标识符
@property (nonatomic, retain, readonly) NSString * deviceType;//设备类型
@property (nonatomic, readonly) DeviceSize deviceSize;//设备屏幕尺寸

@property (nonatomic, retain, readonly) NSString * OSVersion;//设备操作系统版本
@property (nonatomic, retain, readonly) NSString * devicePlatformString;//设备名称(iPhone4s...)
//add by gao_yufeng
@property (nonatomic, strong)           NSString * upgradeUrl;//系统升级地址
@property (nonatomic, strong)           NSString * curVersion;//当前应用最新版本号（服务器获取）
@property (nonatomic,strong)            NSString * gpsOn;//当前gps开关
@property (nonatomic,assign)            BOOL isStepCountingAvailable;//是否支持运动与健身

+ (SystemInfo *)shareSystemInfo;

- (AFNetworkReachabilityStatus)currentNetworkStatus;

@end
