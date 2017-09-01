//
//  SGDatabaseQueue.m
//  SmartCity
//
//  Created by sea on 14-2-27.
//  Copyright (c) 2014年 sea. All rights reserved.
//

#import "SCDatabaseQueue.h"

NSString *const databaseKey = @"Comprise";

NSString *const dbManagerVersion = @"DBManagerVersion";

const static NSInteger DB_Manager_VER = 1;

static NSString *databasePath = nil;

FMDatabaseQueue *queue = nil;

@implementation SCDatabaseQueue


/*!
 @method
 @abstract      数据库队列的实体单例
 
 @note          该对象中的对象属性不可被多线程共享访问修改
 
 @result        返回数据库队列的单例对象
 */
+ (FMDatabaseQueue *)shareInstance {
    
//    static dispatch_once_t onceToken;
//    
//    dispatch_once(&onceToken, ^{
    
    if (!queue) {
        
        databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
                        stringByAppendingPathComponent: @"sqlcipher.db"];
        
        queue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
        
        FMDatabase *db = [queue valueForKey:@"_db"];
        
        //对打开的数据库进行加密（新的数据库）或者解密（已经加密的数据库），在数据库关闭之前，这个方法只能使用一次
        if ([db setKey:databaseKey]) {

//            DLog(@"encrypt success");
        }
    }
//    });
    
    return queue;
}

+ (void)resetDatabase {
    
    [queue close];
    
    queue = nil;
    
    databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
                    stringByAppendingPathComponent: @"sqlcipher.db"];
    [[NSFileManager defaultManager] removeItemAtPath:databasePath error:nil];
    
    [SCDatabaseQueue shareInstance];
}

+ (BOOL)isExistsDataPath{
    
    databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
                    stringByAppendingPathComponent: @"sqlcipher.db"];
    
    return [[NSFileManager defaultManager]fileExistsAtPath:databasePath];
}
+ (void)updateDataBase{
    
    NSInteger ver = [[NSUserDefaults standardUserDefaults] integerForKey:dbManagerVersion];
    
    if (ver <DB_Manager_VER) {
        
        [[self class] changeDataBase];
    }
    [[self class] saveVersion];
}
+ (void)saveVersion{
    
    [[NSUserDefaults standardUserDefaults] setInteger:DB_Manager_VER forKey:dbManagerVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (void)changeDataBase{
    
    [SCDatabaseQueue shareInstance];
    
//    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
    
//        [db executeUpdate:@"ALERT TABLE table ADD tabelname TEXT"];
//    }];
}
@end
