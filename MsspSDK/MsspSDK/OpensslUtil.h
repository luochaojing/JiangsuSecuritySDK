//
//  OpensslUtil.h
//  MsspSDK
//  openssl oc端的工具 用于调用openssl c++的代码
//
//  Created by huwenjun on 15-12-25.
//
//

#import <Foundation/Foundation.h>
#include "OpensslWapper.h"
#include "Base64.h"

@interface OpensslUtil : NSObject
{
    /**Openssl的c++封装工具*/
    OpensslWapper *opensslwapper;
    
    /**处理c++ 对象base64编码的工具*/
    Base64 *base;
}

/**
 *openssl调用c++的openssl工具
 *@author huwenjun
 *@return 对象单例
 */
+ (OpensslUtil *)sharedOpensslUtil;

/**
 *生成用户公私密钥对
 *@author huwenjun
 *@param keyLength 密钥长度
 *@return 通过block返回密钥对
 */
- (void)generateKeyPairRSA:(int)keyLength block:(void(^)(NSString *publicKey,NSString *privateKey))block;

/**
 *使用公钥对数据进行加密
 *@author huwenjun
 *@param publicKey RSA加密的公钥
 *@param data RSA加密的数据对象
 *@return 加密后的数据
 */
- (NSData *)encryptionByRSA:(NSString *)publicKey data:(unsigned char *)data length:(size_t)length;
/**
 *使用私钥对数据进行解密
 *@author huwenjun
 *@param privateKey RSA解密的私钥
 *@param data RSA加密的数据对象
 *@return 解密后的数据
 */
- (NSData *)decryptionByRSA:(NSString *)privateKey data:(unsigned char *)data length:(size_t)length;

/**
 *aes对称加解密
 *@author huwenjun
 *@param key 对称密钥
 *@param encryptFlag 是否加密 yes为加密 no 为解密
 *@param data 待加解密的数据
 *@param length 待加解密的数据长度
 *@return 解密后的数据
 */
- (NSData *)AESOperation:(NSString *)key encryptFlag:(BOOL)encryptFlag data:(unsigned char *)data length:(size_t)length;

/**
 *aes对称加解密
 *@author huwenjun
 *@param key 对称密钥
 *@param encryptFlag 是否加密 yes为加密 no 为解密
 *@param data 待加解密的数据 char类型
 *@param length 待加解密的数据长度
 *@return 解密后的数据
 */
- (NSData *)AESOperationByCharData:(NSString *)key encryptFlag:(BOOL)encryptFlag data:(const char *)data length:(size_t)length;

/**
 *	@brief  hmac算法
 *
 *	@param 	algo            采用的算法（md5/sha1/sha512/sha256/sha224/sha384）
 *	@param 	key             密钥
 *	@param 	key_length      密钥长度
 *	@param 	input           要加密的内容
 *	@param 	input_length 	内容长度
 *
 *	@return	hmac运算结果
 */
- (NSString *)hmacEncode:(NSString *)algo
                    key:(NSString *)key
             key_length:(int)key_length
                  input:(NSString *)input
           input_length:(int)input_length;

/**
 对称加解密上下文初始化操作
 *@author huwenjun
 *@param key 对称密钥
 *@param encryptFlag 是否加密 yes为加密 no 为解密
 *@return 解密后的数据
 */
- (void)symmetricOperationInit:(NSString *)key encryptFlag:(BOOL)encryptFlag;

/**
 分段对称加解密
 *@author huwenjun
 *@param data 待加解密的分段数据
 *@param length 待加解密的分段数据长度
 *@param encryptFlag 是否加密 yes为加密 no 为解密
 *@return 加解密后的分段数据
 */
- (NSData *)symmetricOperationUpdate:(unsigned char *)data length:(size_t)length encryptFlag:(BOOL)encryptFlag;

/**
 分段对称加解密完成操作
 *@author huwenjun
 *@param encryptFlag 是否加密 yes为加密 no 为解密
 *@return 完成操作的偏移数据
 */
- (NSData *)symmetricOperationFinishe:(BOOL)encryptFlag;

/**
 分段对称加解密完成操作
 *@author huwenjun
 *@param privateKey 签名私钥
 *@param data 待签名数据
 *@param hashAlg hasg算法标识
 *@return 签名数据
 */
- (NSString *)sign:(NSString *)privateKey data:(NSString *)data hashAlg:(NSString *)hashAlg;

/**
 分段对称加解密完成操作
 *@author huwenjun
 *@param privateKey 签名私钥
 *@param data 待签名数据char
 *@param length 待签名数据长度
 *@param hashAlg hasg算法标识
 *@return 签名数据
 */
- (NSData *)signData:(NSString *)privateKey data:(unsigned char *)data length:(int)length hashAlg:(NSString *)hashAlg;

/**
 获取证书过期时间
 *@author huwenjun
 *@param certData 证书数据
 *@return 证书过期时间
 */
- (NSDate *)checkCertExpire:(NSData *)certData;

- (BOOL)verify:(NSString *)publicKey data:(unsigned char *)data length:(int)length signData:(unsigned char *)signData length:(int)signlength;
@end
