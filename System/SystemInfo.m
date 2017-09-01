//
//  SystemInfo.m
//  MIP
//
//  Created by sea on 13-11-29.
//  Copyright (c) 2013年 Sea. All rights reserved.
//

#import "SystemInfo.h"
#import <objc/runtime.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#import <CoreLocation/CoreLocation.h>

#import "SCBaseObserveDefine.h"
static SystemInfo *systemInfo = nil;

NSString *const kSystemNetworkChangedNotification = @"kNetworkReachabilityChangedNotification";

@interface SystemInfo () {
    
    Class               _originalClass; //用于检测代理有效性
}

@end


@implementation SystemInfo

@synthesize appId;
@synthesize appVersion;
@synthesize deviceId;
@synthesize deviceType;
@synthesize OSVersion;


- (NSString *)appId {
    
    if (!appId) {
        
        appId = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey];
    }
    
    return appId;
}

- (NSString *)appVersion {
    
    if (!appVersion) {
        
        appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        
    }
    
    return appVersion;
}


- (NSString *)deviceId {
    
    if (!deviceId) {
        
        deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    
    return deviceId;
}

- (NSString *)deviceType {
    
    if (!deviceType) {
        
        deviceType = [[UIDevice currentDevice] model];
    }
    
    return deviceType;
}

- (DeviceSize)deviceSize{
    CGFloat screenHeight = ({
        // consider landscape orientation status
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        
        BOOL isLandscape = (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight);
        
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
        CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
        screenHeight = isLandscape ? screenWidth : screenHeight;
    });
    
    if (screenHeight == 480)
        return iPhone35inch;
    else if(screenHeight == 568)
        return iPhone4inch;
    else if(screenHeight == 667)
        return  iPhone47inch;
    else if(screenHeight == 736)
        return iPhone55inch;
    else
        return 0;
}

- (NSString *)OSVersion {
    
    if (!OSVersion) {
        
        OSVersion = [[UIDevice currentDevice] systemVersion];
    }
    
    return OSVersion;
}

//added by guomin begin
- (NSString *)getDeviceVersion
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char*)malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    //NSString *platform = [NSStringstringWithUTF8String:machine];二者等效
    free(machine);
    return platform;
}

- (NSString *)devicePlatformString{
    NSString *platform = [self getDeviceVersion];
    
    //iPhone
    if ([platform isEqualToString:@"iPhone1,1"])   return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])   return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])   return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])   return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])   return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])   return @"iPhone 4 (CDMA)";
    if ([platform isEqualToString:@"iPhone4,1"])   return @"iPhone 4s";
    if ([platform isEqualToString:@"iPhone5,1"])   return @"iPhone 5 (GSM/WCDMA)";
    if ([platform isEqualToString:@"iPhone5,2"])   return @"iPhone 5(GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])   return @"iPhone 5c(GSM)";
    if ([platform isEqualToString:@"iPhone5,4"])   return @"iPhone 5c(Global)";
    if ([platform isEqualToString:@"iPhone6,1"])   return @"iphone 5s(GSM)";
    if ([platform isEqualToString:@"iPhone6,2"])   return @"iphone 5s(Global)";
    if ([platform isEqualToString:@"iPhone7,1"])   return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"])   return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,1"])   return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"])   return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"])   return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"])   return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,3"])   return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"])   return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone9,4"])   return @"iPhone 7 Plus";
    
    //iPot Touch
    if ([platform isEqualToString:@"iPod1,1"])     return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])     return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])     return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])     return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])     return @"iPod Touch 5G";
    
    //iPad
    if ([platform isEqualToString:@"iPad1,1"])     return@"iPad";
    if ([platform isEqualToString:@"iPad2,1"])     return@"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])     return@"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])     return@"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])     return@"iPad 2 New";
    if ([platform isEqualToString:@"iPad2,5"])     return@"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad3,1"])     return@"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])     return@"iPad 3 (CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])     return@"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])     return@"iPad 4 (WiFi)";
    
    if ([platform isEqualToString:@"i386"] || [platform isEqualToString:@"x86_64"])        return@"Simulator";
    
    return platform;
}
//added by guomin end


+ (SystemInfo *)shareSystemInfo {
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        systemInfo = [SystemInfo new];
        
    });
    
    return systemInfo;
}


- (id)init {
    
    self = [super init];
    
    if (self) {
        
        [self registerNetWorkMonitor];
    }
    
    return self;
}

- (void)registerNetWorkMonitor
{
    _internetReach = [AFNetworkReachabilityManager manager];

   [_internetReach startMonitoring];
}


- (AFNetworkReachabilityStatus)currentNetworkStatus{
    
    AFNetworkReachabilityStatus netStatus = [_internetReach networkReachabilityStatus];
    
    return netStatus;
}

- (NSString *)gpsOn{
    
    BOOL is = [CLLocationManager locationServicesEnabled];
    
    int status = [CLLocationManager authorizationStatus];
    
    if (is && status >= 3) {
        return @"1";
    }else{
        return @"0";
    }
}

- (BOOL)isStepCountingAvailable{
    
    if (ios8x) {
        
        return [CMPedometer isStepCountingAvailable];
    }else{
        
        return [CMStepCounter isStepCountingAvailable];
    }
}
@end
