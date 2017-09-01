//
//  NSString+DESEncrypt.h
//  SmartCity
//
//  Created by Raykle on 15-1-8.
//  Copyright (c) 2015年 sea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DESEncrypt)

///DES加密
+ (NSString *)DESEncryptWithText:(NSString *)plainText theKey:(NSString *)aKey;

///DES解密
+ (NSString *)DESDecryptWithText:(NSString *)encryptText theKey:(NSString *)aKey;

///3DES加密
+ (NSString *)tripleDESEncryptWithText:(NSString *)plainText theKey:(NSString *)aKey;

///3DES解密
+ (NSString *)tripleDESDecryptWithText:(NSString *)encryptText theKey:(NSString *)aKey;

//urlEncode
+ (NSString *)encodeString:(NSString *)unencodedString;

//urlDecode
+ (NSString *)decodeString:(NSString *)encodedString;

@end
