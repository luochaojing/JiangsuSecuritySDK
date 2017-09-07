//
//  JSSCommon.h
//  JiangsuSDK
//  常用工具类，hash函数，日期格式等
//  Created by Luo on 16/11/25.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResultCodeHeader.h"
#import "ThreeDes.h"

//! 常用工具类
@interface JSSCommon : NSObject


#pragma mark - 获取交互ID
/**
 *  获取交互ID
 *
 *  @return 返回20位数字（14位当前时间+6位随机数）
 */
+ (NSString *)getTransactionID;


#pragma mark - HMAC摘要函数
/**
 *  HMAC摘要
 *
 *  @param clearText 明文
 *
 *  @return 密文
 */
+ (NSString *)HMACMD5WithClearText:(NSString *)clearText;
+ (BOOL)HMACMD5VerifyWithClearText:(NSString *)clearText cipherText:(NSString *)cipherText;





/**
 *  获取移动设备唯一标示
 *  iOS不允许获取IMEI，所以自己生成一套
 *  @return keychain里存的唯一标识
 */
+ (NSString *)getIMEI;


+ (NSString *)getIPAdress;




#pragma mark - 3ES加解密

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



//base64编码
+ (NSString *)base64EncodingWithClearText:(NSString *)clearText;
//base64解码
+ (NSString *)base64DecodingWithBasedString:(NSString *)basedString;



@end
