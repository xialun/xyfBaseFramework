//
//  SGDatabaseQueue.h
//  SmartCity
//
//  Created by sea on 14-2-27.
//  Copyright (c) 2014年 sea. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FMDatabaseQueue.h"
#import "FMDatabase.h"

FOUNDATION_EXPORT      NSString             *const databaseKey;

@interface SCDatabaseQueue : NSObject


/*!
 @method
 @abstract      数据库队列的实体单例
 
 @note          该对象中的对象属性不可被多线程共享访问修改
 
 @result        返回数据库队列的单例对象
 */
+ (FMDatabaseQueue *)shareInstance;

+ (void)resetDatabase;

//判断数据库是否存在
+ (BOOL)isExistsDataPath;

/**
 *数据库升级，如果需要更新数据表结构，需要在此方法里更新数据表结构
 */
+ (void)updateDataBase;
@end
