//
//  NSString+Additional.m
//  SCBaseFoundation
//
//  Created by xyf on 17/8/2.
//  Copyright © 2017年 xyf. All rights reserved.
//

#import "NSString+Additional.h"

@implementation NSString (Additional)

//16进制字符转换为NSData
-(NSData *) hexStringToNSData
{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= self.length; idx += 2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [self substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        uint intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

@end
