//
//  SCBaseObserveDefine.h
//  NetworkHandle
//
//  Created by xyf on 17/7/17.
//  Copyright © 2017年 xyf. All rights reserved.
//

#ifndef SCBaseObserveDefine_h
#define SCBaseObserveDefine_h


#ifdef DEBUG
#   define DLog(format, ...) NSLog((@"%s [Line %d]:\n %s = " format), __PRETTY_FUNCTION__, __LINE__, #__VA_ARGS__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

//判断当前对象是否有效
#define isValid(object)     (object && ![object isEqual:[NSNull null]])

#define ios8x           ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)



/*******************网络请求使用的宏定义**********************************/
#define Appkey      @"lishui"

#endif /* SCBaseObserveDefine_h */
