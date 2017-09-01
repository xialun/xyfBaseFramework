//
//  NSData+Encrypt.m
//  MIP
//
//  Created by Sea on 13-9-12.
//  Copyright (c) 2013年 Sea. All rights reserved.
//

#import "NSData+CustomExtensions.h"

#import <zlib.h>

@implementation NSData (CustomExtensions)

/*!
 @function
 @abstract      AES256加密
 
 @param         key                     AES加密的密钥
 @param         encoding                key的编码方式
 
 @result        加密后的NSData
 */
- (NSData *)AES256EncryptWithKey:(NSString *)key keyEncoding:(NSStringEncoding)encoding  //加密
{
    
    char keyPtr[kCCKeySizeAES256+1];
    
    bzero(keyPtr, sizeof(keyPtr));
    
    if (![key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:encoding]) {//如果key转换为char失败,则返回nil
        
        return nil;
    }
    
    NSUInteger dataLength = [self length];//计算需要加密数据的长度
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          [self bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess) {
        
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        
    }
    
    free(buffer);
    
    return nil;
}



/*!
 @function
 @abstract      AES256解密
 
 @param         key                     AES解密的密钥
 @param         encoding                key的编码方式
 
 @result        解密后的NSData
 */
- (NSData *)AES256DecryptWithKey:(NSString *)key keyEncoding:(NSStringEncoding)encoding  //解密
{
    
    char keyPtr[kCCKeySizeAES256+1];
    
    bzero(keyPtr, sizeof(keyPtr));
    
    if (![key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:encoding]) {
        
        return nil;
    }
    
    NSUInteger dataLength = [self length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          NULL,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    
    return nil;
}



/*!
 @function
 @abstract      AES128使用PKCS7Padding填充模式的加密/解密
 
 @param         iv                      AES填充模式采用kCCOptionPKCS7Padding,iv为填充字符串
 @param         ivEncoding              iv的编码方式
 @param         symmetricKey            对称密钥字符串
 @param         keyEncoding             symmetricKey的编码方式
 @param         operation               操作方式,加密还是解密
 
 @result        加密/解密后的NSData
 */
- (NSData *)cipherByAES:(NSString *)iv
             ivEncoding:(NSStringEncoding)ivEncoding
                    key:(NSString *)symmetricKey
            keyEncoding:(NSStringEncoding)keyEncoding
              operation:(CCOperation)operation
{
    CCCryptorStatus ccStatus   = kCCSuccess;
    size_t          cryptBytes = 0;    // Number of bytes moved to buffer.
    
    
    char keyPtr[kCCKeySizeAES128];
    
    bzero(keyPtr, sizeof(keyPtr));
    
    if (![symmetricKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:keyEncoding]) {
        
        return nil;
    }
    
    
    char ivPtr[kCCBlockSizeAES128+1];
    
    bzero(ivPtr, sizeof(ivPtr));
    
    if (![iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:ivEncoding]) {
        
        return nil;
    }
    
    
    NSUInteger dataLength = [self length];//计算需要加密数据的长度
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    
    void *buffer = malloc(bufferSize);
    
    ccStatus = CCCrypt(operation,
                       kCCAlgorithmAES128,
                       kCCOptionPKCS7Padding,
                       keyPtr,
                       kCCKeySizeAES128,
                       ivPtr,
                       self.bytes,
                       self.length,
                       buffer,
                       bufferSize,
                       &cryptBytes);
    
    if (ccStatus == kCCSuccess) {

        return [NSData dataWithBytesNoCopy:buffer length:cryptBytes];
    }
    
    free(buffer);
    
    return nil;
}

//AES256加密的key长度不能超过16位，超过则截取至16位，不足则补齐16位
+ (NSString*)fitAES256EncryptKey:(NSString*)originKey
{
    if ([originKey length] >= 16) {
        return [originKey substringToIndex:16];
    }
    else {
        NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:16];
        [stringBuffer appendString:originKey];
        for (int i = ([originKey length] - 1); i < 15; i++) {
            [stringBuffer appendString:@"\000"];
        }
        return stringBuffer;
    }
}

//NSData转换16进制字符
- (NSString*)stringWithHexBytes
{
    NSMutableString *stringBuffer = [NSMutableString
                                     stringWithCapacity:([self length] * 2)];
    const unsigned char *dataBuffer = [self bytes];
    int i;
    
    for (i = 0; i < [self length]; ++i) {
        [stringBuffer appendFormat:@"%02lX", (unsigned long)dataBuffer[i]];
    }
    return stringBuffer;
}

//解压gzip压缩过的data数据
- (NSData *)gzipUnpack
{
    if ([self length] == 0) return self;
    
    unsigned full_length = [self length];
    unsigned half_length = [self length] / 2;
    
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
    BOOL done = NO;
    int status;
    
    z_stream strm;
    strm.next_in = (Bytef *)[self bytes];
    strm.avail_in = [self length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    
    
    
    if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
    
    while (!done)
    {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length])
            [decompressed increaseLengthBy: half_length];
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = [decompressed length] - strm.total_out;
        
        // Inflate another chunk.
        
        status = inflate (&strm, Z_SYNC_FLUSH);
        
        if (status == Z_STREAM_END) done = YES;
        
        else if (status != Z_OK) break;
        
    }
    
    if (inflateEnd (&strm) != Z_OK) return nil;
    
    // Set real length.
    if (done)
    {
        [decompressed setLength: strm.total_out];
        
        return [NSData dataWithData: decompressed];
    }
    else return nil;
}

//压缩文件
-(NSData *)gzipDeflate
{
    if ([self length] == 0) return self;
    
    z_stream strm;
    
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.total_out = 0;
    strm.next_in=(Bytef *)[self bytes];
    strm.avail_in = [self length];
    
    // Compresssion Levels:
    //   Z_NO_COMPRESSION
    //   Z_BEST_SPEED
    //   Z_BEST_COMPRESSION
    //   Z_DEFAULT_COMPRESSION
    
    if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK) return nil;
    
    NSMutableData *compressed = [NSMutableData dataWithLength:16384];  // 16K chunks for expansion
    
    do {
        
        if (strm.total_out >= [compressed length])
            [compressed increaseLengthBy: 16384];
        
        strm.next_out = [compressed mutableBytes] + strm.total_out;
        strm.avail_out = (uInt)[compressed length] - (uint)strm.total_out;
        
        deflate(&strm, Z_FINISH);
        
    } while (strm.avail_out == 0);
    
    deflateEnd(&strm);
    
    [compressed setLength: strm.total_out];
    
    return [NSData dataWithData:compressed];
}
@end
