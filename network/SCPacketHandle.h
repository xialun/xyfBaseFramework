//
//  PacketHandle.h
//  NetworkHandle
//
//  Created by xyf on 17/7/18.
//  Copyright © 2017年 xyf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCPacketHandle : NSObject

+ (NSData *)appendingPostDataWithBodyDictionary:(id)body;
@end
