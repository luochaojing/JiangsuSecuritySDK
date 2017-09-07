//
//  OpensslUtil.h
//  JiangsuSDK
//
//  Created by Luo on 16/11/29.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "OpensslWapper.h"
#include "Base64.h"

@interface OpensslUtil : NSObject
{

    //Openssl的c++ 封装类
    OpensslWapper *opensslwapper;
    
    //! 处理
    Base64 *base;
}


/**
 *  单例模式
 *
 *  @return OpensslUtil单例模式
 */
+ (OpensslUtil *)sharedOpensslUtil;



/**
 *  生成RSA密钥字典
 *
 *  @param keyLength 密钥长度，推荐为1024
 *
 *  @return 密钥字典：@{@“publicKey”:@"xxxx",@"privateKey":@"yyy"}
 */
- (NSDictionary *)generateKeyDicRSAWithKeyLength:(int)keyLength;



/**
 *  生成RSA密钥对
 *
 *  @param keyLength 密钥长度
 *  @param block     公钥私钥的回调
 */
- (void)generateKeyPairRSA:(int)keyLength
                     block:(void(^)(NSString *publicKey, NSString *privateKey))block;



/**
 *  RSA使用公钥加密
 *
 *  @param publicKey 公钥
 *  @param data      数据
 *  @param length    数据长度
 *
 *  @return 加密之后的数据
 */
- (NSData *)encryptionByRSA:(NSString *)publicKey data:(unsigned char *)data length:(size_t)length;



/**
 *  RSA解密
 *
 *  @param privateKey 私钥
 *  @param data       数据
 *  @param length     数据长度，因为string有时候会出错，建议传入128
 *
 *  @return 解密后的数据
 */
- (NSData *)decryptionByRSA:(NSString *)privateKey data:(unsigned char *)data length:(size_t)length;

- (NSString *)x509SerialNumWithDataString:(NSString *)certDataStr;


//! 用私钥+算法签名:hashAlg=@"sha1",@"md5";传入的已经编码的字符串，内部都解码：用户加密哈希值
- (NSString *)signWithPrivateKey:(NSString *)privateKey data:(NSString *)data hashAlg:(NSString *)hashAlg;
//! 用于非base64编码string：可传入中文
- (NSString *)signNobase64StrWithPrivateKey:(NSString *)privateKey data:(NSString *)data hashAlg:(NSString *)hashAlg;


/**
 *  通过后方返回的证书串读取签名方式
 *
 *  @param certDataString 证书串
 *
 *  @return @“sha1” 或者 @“md5”
 */
- (NSString *)getHashAlgWithCertDataString:(NSString *)certDataString;


//! 签名认证--md5
- (BOOL)verifymd5:(NSString *)publicKey data:(unsigned char *)data length:(int)length signData:(unsigned char *)signData length:(int)signlength;
//! 签名认证--sha1
- (BOOL)verifySha1:(NSString *)publicKey data:(unsigned char *)data length:(int)length signData:(unsigned char *)signData length:(int)signlength;

@end
