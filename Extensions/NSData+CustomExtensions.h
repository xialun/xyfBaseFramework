//
//  NSData+Encrypt.h
//  MIP
//
//  Created by Sea on 13-9-12.
//  Copyright (c) 2013年 Sea. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CommonCrypto/CommonCryptor.h>

#define kEncryptKeyHeader   @"www.myNJ.cn"

@interface NSData (CustomExtensions)

/*!
 @function
 @abstract      AES256加密
 
 @param         key                     AES加密的密钥
 @param         encoding                key的编码方式
 
 @result        加密后的NSData
 */
- (NSData *)AES256EncryptWithKey:(NSString *)key keyEncoding:(NSStringEncoding)encoding;



/*!
 @function
 @abstract      AES256解密
 
 @param         key                     AES解密的密钥
 @param         encoding                key的编码方式
 
 @result        解密后的NSData
 */
- (NSData *)AES256DecryptWithKey:(NSString *)key keyEncoding:(NSStringEncoding)encoding;



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
              operation:(CCOperation)operation;

//NSData转换16进制字符
- (NSString*)stringWithHexBytes;

//AES256加密的key长度不能超过16位，超过则截取至16位，不足则补齐16位
+ (NSString*)fitAES256EncryptKey:(NSString*)originKey;

//解压gzip压缩过的data数据
- (NSData *)gzipUnpack;

//压缩字符串zip
-(NSData *)gzipDeflate;

@end
