//
//  SCIntermediateHandle.m
//  NetworkHandle
//
//  Created by xyf on 17/7/14.
//  Copyright © 2017年 xyf. All rights reserved.
//

#import "SCIntermediateHandle.h"

@implementation SCIntermediateHandle

static SCIntermediateHandle *shareIntermediaHandle = nil;
+(instancetype)shareIntermediateHandle
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (!shareIntermediaHandle) {
            
            shareIntermediaHandle = [[SCIntermediateHandle alloc]init];
        }
    });
    return shareIntermediaHandle;
}

- (void)preformTarget:(NSString *)target method:(NSString *)methodName args:(id)arg,...
{

    va_list args;
    
    va_start(args, arg);
    
    [[SCIntermediateHandle shareIntermediateHandle] setArguments:args arg:arg];
    
    va_end(args);
    
    Class targetClass;
    if (target) {
        targetClass = NSClassFromString(target);
    }
    
    SEL method = NULL;
    if (methodName) {
        
        method = NSSelectorFromString(methodName);
    }
    if (targetClass == Nil) {
        
        return;
    }
    //类的方法是否存在
    if ([targetClass respondsToSelector:method]) {
        
        IMP imp = [targetClass methodForSelector:method];
        if (_argList.count > 1) {
           
            void (*func)(__strong id, SEL, id, id) = (void(*)(__strong id, SEL,id,id))imp;
            func(targetClass, method, [_argList firstObject], [_argList objectAtIndex:1]);
        }else if (_argList.count == 1){
            
            id (*func)(__strong id, SEL, id) = (id (*)(__strong id, SEL, id))imp;
            func(targetClass, method, [_argList firstObject]);
        }
        
        
    }
   
}

- (id)preformTarget:(NSString *)target methodWithRequest:(NSString *)methodName args:(id)arg,...
{
    va_list args;
    
    va_start(args, arg);
    
    [[SCIntermediateHandle shareIntermediateHandle] setArguments:args arg:arg];
    
    va_end(args);
    
    Class targetClass;
    if (target) {
        targetClass = NSClassFromString(target);
    }
    
    SEL method = NULL;
    if (methodName) {
        
        method = NSSelectorFromString(methodName);
    }
    if (targetClass == Nil) {
        
        return nil;
    }
    
    if ([targetClass respondsToSelector:method]) {
        
        IMP imp = [targetClass methodForSelector:method];
        
        id (*func)(__strong id, SEL, id) = (id (*)(__strong id, SEL, id))imp;
        return  func(targetClass, method, [_argList firstObject]);
    }
    
    return nil;
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

@end
