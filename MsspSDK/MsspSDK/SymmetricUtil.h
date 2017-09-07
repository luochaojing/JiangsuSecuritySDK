//
//  AESUtil.h
//  MsspSDK
//  对称密钥生成工具
//  Created by huwenjun on 15-12-25.
//  Copyright (c) 2015年 aspire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

enum {
    CSSM_ALGID_NONE =					0x00000000L,
    CSSM_ALGID_VENDOR_DEFINED =			CSSM_ALGID_NONE + 0x80000000L,
    CSSM_ALGID_AES
};
#define kChosenCipherKeySize	kCCKeySizeAES128

@interface SymmetricUtil : NSObject

@property (nonatomic, strong) NSData * symmetricKeyRef;

@property (nonatomic, strong) NSData * symmetricTag;

/**
 *对称加密的工具类单例
 *@author huwenjun
 *@return 对象单例
 */
+ (SymmetricUtil *)sharedSymmetricUtil;

/**
 *获取用于加密私钥的对称密钥 满足iv值16个字节 key值16个字节
 *@author huwenjun
 *@return 用于加密私钥的对称密钥
 */
- (NSString *)genSignAESKey;

/**
 *获取用于本地加密接口的对称密钥 iv和key长度随机生成 若iv值为8个字节则key为24 调用3des加密
 *否则iv值16个字节 key值随机为16个字节 24个字节 32个字节 分别对应128位 192位 256位密钥
 *@author huwenjun
 *@return 用于本地加密接口的对称密钥
 */
- (NSString *)genLocalEncryptKey;

/**
 *获取用于本地文件（包括证书，密钥等）加密的对称密钥 iv值为16个字节 key为唯一标识截取16个字节固定密钥
 *@author huwenjun
 *@return 用于本地文件加密的对称密钥
 */
- (NSString *)genLocalFileEncryptKey;

/**
 *计算生成对称密钥
 *@author huwenjun
 *@param iv_length iv长度
 *@param key_length key长度
 *@return 对称密钥
 */
- (NSString *)getSymmetricKeyStr:(int)iv_length key_length:(int)key_length;

#pragma ios security
- (void)generateSymmetricKey;

- (NSData *)getSymmetricKeyBytes;
@end
