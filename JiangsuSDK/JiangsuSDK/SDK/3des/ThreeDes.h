//
//  ThreeDes.h
//  JiangsuSDK
//  3DES加解密：由于主要是解密私钥，较短，所以不用输入输出流
//  Created by Luo on 16/11/29.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThreeDes : NSObject



/**
 *  3des加密
 *
 *  @param key       对称密钥
 *  @param clearText 明文
 *
 *  @return 密文
 */
+ (NSString *)threeDesEncrypttWithKey:(NSString *)key clearText:(NSString *)clearText;


/**
 *  3des解密
 *
 *  @param key        对称密钥
 *  @param cipherText 密文
 *
 *  @return 明文
 */
+ (NSString *)threeDesDencryotWithKey:(NSString *)key cipherText:(NSString *)cipherText;


/**
 *  MD5哈希，传入用户的PIN值，算出24位字符作为3DES对称加密的密钥，再对证书私钥对称加密
 *
 *  @param pin PIN值
 *
 *  @return 32位哈希值，需取中间16位，再用前八位补齐后八位够24位
 */
+ (NSString *)getTripleDesKeyWithUserPin:(NSString *)pin;
@end
