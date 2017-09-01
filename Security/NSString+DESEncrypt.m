//
//  NSString+DESEncrypt.m
//  SmartCity
//
//  Created by Raykle on 15-1-8.
//  Copyright (c) 2015年 sea. All rights reserved.
//

#import "NSString+DESEncrypt.h"

#import <CommonCrypto/CommonCryptor.h>
#import "GTMBase64.h"
#import "NSData+CustomExtensions.h"
#import "NSString+Additional.h"

@implementation NSString (DESEncrypt)

#pragma mark - DES加密、解密

+ (NSString *)DESEncryptWithText:(NSString *)plainText theKey:(NSString *)aKey
{
    return [self DESEncrypt:plainText encryptOrDecrypt:kCCEncrypt key:aKey];
}

+ (NSString *)DESDecryptWithText:(NSString *)encryptText theKey:(NSString *)aKey
{
    return [self DESEncrypt:encryptText encryptOrDecrypt:kCCDecrypt key:aKey];
}

+ (NSString *)DESEncrypt:(NSString *)plainText encryptOrDecrypt:(CCOperation)encryptOperation key:(NSString *)key{
    
    NSData *data;
    
    if (encryptOperation == kCCEncrypt){
        data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    }
    else{
        data = [GTMBase64 decodeData:[plainText dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t movedBytes = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(encryptOperation, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &movedBytes);
    
    NSString *result = nil;
    
    if (cryptStatus == kCCSuccess) {
        
        if (encryptOperation == kCCEncrypt){
            
            NSData *DESData = [NSData dataWithBytesNoCopy:buffer length:movedBytes];
            
            NSString *Base64DESStr = [GTMBase64 stringByEncodingData:DESData];
            
            result = [Base64DESStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            result = [self encodeString:result];
        }
        else{
            NSData *DESData = [NSData dataWithBytesNoCopy:buffer length:movedBytes];
            
            result = [[NSString alloc] initWithData:DESData encoding:NSUTF8StringEncoding];
        }
        
        return result;
    }
    
    free(buffer);
    
    return nil;
}





#pragma mark - 3DES加密、解密

+ (NSString *)tripleDESEncryptWithText:(NSString *)plainText theKey:(NSString *)aKey{
    return [self TripleDES:plainText encryptOrDecrypt:kCCEncrypt encryptOrDecryptKey:aKey];
}

+ (NSString *)tripleDESDecryptWithText:(NSString *)encryptText theKey:(NSString *)aKey{
    return [self TripleDES:encryptText encryptOrDecrypt:kCCDecrypt encryptOrDecryptKey:aKey];
}

+ (NSString *)TripleDES:(NSString *)plainText encryptOrDecrypt:(CCOperation)encryptOrDecrypt encryptOrDecryptKey:(NSString *)encryptOrDecryptKey
{
    
    const void *vplainText;
    size_t plainTextBufferSize;
    
    if (encryptOrDecrypt == kCCDecrypt)//解密
    {
        NSData *EncryptData;
        //Base64
        //EncryptData = [GTMBase64 decodeData:[plainText dataUsingEncoding:NSUTF8StringEncoding]];
        
        //16进制
        EncryptData = [plainText hexStringToNSData];
        
        plainTextBufferSize = [EncryptData length];
        vplainText = [EncryptData bytes];
    }
    else //加密
    {
        NSData* data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
        plainTextBufferSize = [data length];
        vplainText = (const void *)[data bytes];
    }
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    const void *vkey = (const void *)[encryptOrDecryptKey UTF8String];
    ccStatus = CCCrypt(encryptOrDecrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding | kCCOptionECBMode,
                       vkey,
                       kCCKeySize3DES,
                       NULL,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    if (ccStatus == kCCSuccess) NSLog(@"SUCCESS");
    
    NSString *result;
    
    if (ccStatus == kCCSuccess){
        
        if (encryptOrDecrypt == kCCDecrypt)//解密
        {
            result = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr
                                                                   length:(NSUInteger)movedBytes]
                                           encoding:NSUTF8StringEncoding];
        }
        else//加密
        {
            NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
            
            //Base64
            //result = [GTMBase64 stringByEncodingData:myData];
            
            //16进制
            result = [myData stringWithHexBytes];
        }
    }
    
    free(bufferPtr);
    
    return result;
}

+ (NSString *)encodeString:(NSString *)unencodedString{
    
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)unencodedString,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    
    return encodedString;
}

+ (NSString *)decodeString:(NSString *)encodedString{
    
    NSString *decodedString  = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                                     (__bridge CFStringRef)encodedString,
                                                                                                                     CFSTR(""),
                                                                                                                     CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}
@end
