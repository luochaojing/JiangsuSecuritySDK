//
//  HashTool.h
//  MsspSDK
//
//  Created by ASPire on 15/12/30.
//  Copyright © 2015年 aspire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@interface HashTool : NSObject
{
    //md5上下文
    CC_MD5_CTX hashObject;
}

- (void)md5Init;
- (void)md5UpdateWithBuffer:(const void *)buffer Length:(unsigned long)readLen;
- (NSString *)md5Final;

/**
 *	@brief	创建单例类HashTool
 *
 *	@return	 HashTool单例对象
 */
+(HashTool *)sharedHashTool;

/**
 *	@brief	对输入流进行sha1加密
 *
 *	@param 	inputStream 	输入流
 *
 *	@return	 sha1加密结果
 */
+(NSString *)sha1WithInputStream:(NSInputStream *)inputStream;


/**
 *	@brief	对输入流进行MD5加密
 *
 *	@param 	inputStream 	输入流
 *
 *	@return	 md5加密结果
 */
+(NSString *)md5WithInputStream:(NSInputStream *)inputStream;


/**
 *	@brief	md5 32位小写加密
 *
 *	@param 	str 	要加密的字符串
 *	@param 	fromIndex 	起始位置
 *	@param 	toIndex 	终止位置
 *
 *	@return	返回md5值中起始位置到终止位置之间的值
 */
+(NSString *)md532BitLower:(NSString *)str FromIndex:(NSUInteger)fromIndex ToIndex:(NSUInteger)toIndex;


/**
 *	@brief	对输入流进行sha256加密
 *
 *	@param 	inputStream 	输入流
 *
 *	@return	 sha256加密结果
 */
+(NSString *)sha256WithInputStream:(NSInputStream *)inputStream;


/**
 *	@brief	对输入流进行hmacSha256加密
 *
 *	@param 	inputStream 	输入流
 *	@param 	keyStr 	密钥
 *
 *	@return	加密后的结果
 */
+(NSString *)hmacSha256WithInputStream:(NSInputStream *)inputStream WiehKey:(NSString *)keyStr;


/**
 *	@brief	对输入流进行hmacMd5加密
 *
 *	@param 	inputStream 	输入流
 *	@param 	keyStr 	密钥
 *
 *	@return	加密后的结果
 */
+(NSString *)hmacMd5WithInputStream:(NSInputStream *)inputStream WiehKey:(NSString *)keyStr;


/**
 *	@brief	对输入流进行hmacSha1加密
 *
 *	@param 	inputStream 	输入流
 *	@param 	keyStr 	密钥
 *
 *	@return	加密后的结果
 */
+(NSString *)hmacSha1WithInputStream:(NSInputStream *)inputStream WiehKey:(NSString *)keyStr;

@end
