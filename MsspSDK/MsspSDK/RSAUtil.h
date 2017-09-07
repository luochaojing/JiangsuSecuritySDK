//
//  RSAUtil.h
//  MsspSDK
//  rsa加密工具 主要是苹果原生方式 暂未使用
//  Created by huwenjun on 15-12-11.
//  Copyright (c) 2015年 aspire. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSAUtil : NSObject

/**
 *生成用户公钥
 *@author huwenjun
 *@return 用户公钥
 */
+ (SecKeyRef)getPublicKeyRef;

/**
 *通过给定的base64字符串生成平台公钥
 *@author huwenjun
 *@param base64key base64编码的平台公钥
 *@return 平台公钥
 */
+ (SecKeyRef)getMsspPublicKeyRef:(NSString *)base64key;

/**
 *生成用户公钥的NSData类型用于存储
 *@author huwenjun
 *@return 用户公钥的NSData类型
 */
+ (NSData *)publicKeyBits;

/**
 *生成用户私钥
 *@author huwenjun
 *@return 用户私钥
 */
+ (SecKeyRef)getPrivateKeyRef;

/**
 *生成用户私钥的NSData类型用于存储
 *@author huwenjun
 *@return 用户私钥的NSData类型
 */
+ (NSData *)privateKeyBits;

/**
 *生成用户公私密钥对
 *@author huwenjun
 *@return 通过block返回密钥对
 */
+ (void)generateKeyPairRSAWithBlock:(void(^)(SecKeyRef publicKeyRef,SecKeyRef privateKeyRef))block;

/**
 *删除钥匙链现存的公私密钥对
 *@author huwenjun
 *@return
 */
+ (void)deleteAsymmetricKeys;

/**
 *验证证书的可信度
 *@param cerData 证书的二进制
 *@author huwenjun
 *@return 是否可信
 */
+ (BOOL)validateCertificate:(NSData *)cerData;
@end
