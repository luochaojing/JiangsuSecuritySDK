//
//  HashTool.m
//  MsspSDK
//
//  Created by ASPire on 15/12/30.
//  Copyright © 2015年 aspire. All rights reserved.
//

#import "HashTool.h"
#import "TTMBase64.h"
#define FileHashDefaultChunkSizeForReadingData (1024)

@implementation HashTool

//创建单例类
+ (HashTool *)sharedHashTool
{
    static HashTool *__singletion;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __singletion=[[self alloc] init];
    });
    return __singletion;
}

- (instancetype)init
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    
    
    return self;
}

- (void)md5Init
{
    //初始化md5上下文
    CC_MD5_Init(&hashObject);
}

- (void)md5UpdateWithBuffer:(const void *)buffer Length:(unsigned long)readLen
{
    CC_MD5_Update(&hashObject,buffer,(CC_LONG)readLen);
}

- (NSString *)md5Final
{
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    
    NSData *retData = [[NSData alloc] initWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
    retData = [TTMBase64 encodeData:retData];
    NSString *ret = [[NSString alloc] initWithData:retData encoding:NSUTF8StringEncoding];
    //hashObject = NULL;
    return ret;
}


#pragma mark 对输入流进行sha1加密
/**
 *	@brief	对输入流进行sha1加密
 *
 *	@param 	inputStream 	输入流
 *
 *	@return	 sha1加密结果
 */
+(NSString *)sha1WithInputStream:(NSInputStream *)inputStream
{
    //打开输入流
    [inputStream open];
    
    // 初始化hash对象
    CC_SHA1_CTX hashObject;
    CC_SHA1_Init(&hashObject);
    
    bool hasMoreData = true;
    unsigned long readLen = 0;
    uint8_t buffer[FileHashDefaultChunkSizeForReadingData];
    
    //循环加密
    while (hasMoreData) {
        readLen = [inputStream read:buffer maxLength:FileHashDefaultChunkSizeForReadingData];
        
        if (readLen == 0) {
            hasMoreData = false;
            continue;
        }
        
        if (readLen > 0) {
            CC_SHA1_Update(&hashObject,(const void *)buffer,(CC_LONG)readLen);
        }
    }
    
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1_Final(digest, &hashObject);
    
    /*
     //计算hex值
     char hash[2 * sizeof(digest) + 1];
     for (size_t i = 0; i < sizeof(digest); ++i) {
     snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
     }
     NSData *HMAC = [[NSData alloc] initWithBytes:hash length:strlen(hash)];
     NSString *ret = [[NSString alloc] initWithData:HMAC encoding:NSUTF8StringEncoding];
     */
    
    NSData *retData = [[NSData alloc] initWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
    retData = [TTMBase64 encodeData:retData];
    NSString *ret = [[NSString alloc] initWithData:retData encoding:NSUTF8StringEncoding];
    
    [inputStream close];
    return ret;
}


#pragma mark 对输入流进行md5加密
/**
 *	@brief	对输入流进行md5加密
 *
 *	@param 	inputStream 	输入流
 *
 *	@return	 md5加密结果
 */
+(NSString *)md5WithInputStream:(NSInputStream *)inputStream
{
    //打开输入流
    [inputStream open];
    
    // 初始化hash对象
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    
    bool hasMoreData = true;
    unsigned long readLen = 0;
    uint8_t buffer[FileHashDefaultChunkSizeForReadingData];
    
    //循环加密
    while (hasMoreData) {
        readLen = [inputStream read:buffer maxLength:FileHashDefaultChunkSizeForReadingData];
        
        if (readLen == 0) {
            hasMoreData = false;
            continue;
        }
        
        if (readLen > 0) {
            CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readLen);
        }
    }
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    
    /*
     //计算hex值
     char hash[2 * sizeof(digest) + 1];
     for (size_t i = 0; i < sizeof(digest); ++i) {
     snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
     }
     
     NSData *HMAC = [[NSData alloc] initWithBytes:hash length:strlen(hash)];
     NSString *ret = [[NSString alloc] initWithData:HMAC encoding:NSUTF8StringEncoding];
     */
    
    NSData *retData = [[NSData alloc] initWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
    retData = [TTMBase64 encodeData:retData];
    NSString *ret = [[NSString alloc] initWithData:retData encoding:NSUTF8StringEncoding];
    
    [inputStream close];
    return ret;
}



#pragma mark md5 32位小写加密
/**
 *	@brief	md5 32位小写加密
 *
 *	@param 	str 	要加密的字符串
 *	@param 	fromIndex 	起始位置
 *	@param 	toIndex 	终止位置
 *
 *	@return	返回md5值中起始位置到终止位置之间的值
 */
+(NSString *)md532BitLower:(NSString *)str FromIndex:(NSUInteger)fromIndex ToIndex:(NSUInteger)toIndex

{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    NSNumber *num = [NSNumber numberWithUnsignedLong:strlen(cStr)];
    CC_MD5( cStr,[num intValue], result );
    
    NSString *ret = [[NSString stringWithFormat:
                      @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                      result[0], result[1], result[2], result[3],
                      result[4], result[5], result[6], result[7],
                      result[8], result[9], result[10], result[11],
                      result[12], result[13], result[14], result[15]
                      ] lowercaseString];
    
    return [[ret substringFromIndex:fromIndex] substringToIndex:toIndex];
}



#pragma mark 对输入流进行sha256加密
/**
 *	@brief	对输入流进行sha256加密
 *
 *	@param 	inputStream 	输入流
 *
 *	@return	 sha256加密结果
 */
+(NSString *)sha256WithInputStream:(NSInputStream *)inputStream
{
    //打开输入流
    [inputStream open];
    
    // 初始化hash对象
    CC_SHA256_CTX hashObject;
    CC_SHA256_Init(&hashObject);
    
    bool hasMoreData = true;
    unsigned long readLen = 0;
    uint8_t buffer[FileHashDefaultChunkSizeForReadingData];
    
    //循环加密
    while (hasMoreData) {
        readLen = [inputStream read:buffer maxLength:FileHashDefaultChunkSizeForReadingData];
        
        if (readLen == 0) {
            hasMoreData = false;
            continue;
        }
        
        if (readLen > 0) {
            CC_SHA256_Update(&hashObject,(const void *)buffer,(CC_LONG)readLen);
        }
    }
    
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256_Final(digest, &hashObject);
    
    /*
     //计算hex值
     char hash[2 * sizeof(digest) + 1];
     for (size_t i = 0; i < sizeof(digest); ++i) {
     snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
     }
     
     NSData *HMAC = [[NSData alloc] initWithBytes:hash length:strlen(hash)];
     NSString *ret = [[NSString alloc] initWithData:HMAC encoding:NSUTF8StringEncoding];
     */
    
    NSData *retData = [[NSData alloc] initWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    retData = [TTMBase64 encodeData:retData];
    NSString *ret = [[NSString alloc] initWithData:retData encoding:NSUTF8StringEncoding];
    
    [inputStream close];
    return ret;
}


#pragma mark 对输入流进行hmacSha256加密
/**
 *	@brief	对输入流进行hmacSha256加密
 *
 *	@param 	inputStream 	输入流
 *	@param 	keyStr 	密钥
 *
 *	@return	加密后的结果
 */
+(NSString *)hmacSha256WithInputStream:(NSInputStream *)inputStream WiehKey:(NSString *)keyStr
{
    
    //打开inputStream
    [inputStream open];
    
    const char *cKey  = [keyStr cStringUsingEncoding:NSUTF8StringEncoding];
    const unsigned int blockSize = 64;
    char ipad[blockSize];
    char opad[blockSize];
    char keypad[blockSize];
    
    unsigned int keyLen = (unsigned int)strlen(cKey);
    CC_SHA256_CTX hashObject;
    if (keyLen > blockSize) {
        CC_SHA256_Init(&hashObject);
        CC_SHA256_Update(&hashObject, cKey, keyLen);
        CC_SHA256_Final((unsigned char *)keypad, &hashObject);
        keyLen = CC_SHA256_DIGEST_LENGTH;
    }
    else {
        memcpy(keypad, cKey, keyLen);
    }
    
    memset(ipad, 0x36, blockSize);
    memset(opad, 0x5c, blockSize);
    
    int i;
    for (i = 0; i < keyLen; i++) {
        ipad[i] ^= keypad[i];
        opad[i] ^= keypad[i];
    }
    
    // 初始化hash对象
    CC_SHA256_Init(&hashObject);
    CC_SHA256_Update(&hashObject, ipad, blockSize);
    
    bool hasMoreData = true;
    unsigned long readLen = 0;
    uint8_t buffer[FileHashDefaultChunkSizeForReadingData];
    
    //循环加密
    while (hasMoreData) {
        readLen = [inputStream read:buffer maxLength:FileHashDefaultChunkSizeForReadingData];
        
        if (readLen == 0) {
            hasMoreData = false;
            continue;
        }
        
        if (readLen > 0) {
            CC_SHA256_Update(&hashObject,(const void *)buffer,(CC_LONG)readLen);
        }
    }
    
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256_Final(digest, &hashObject);
    
    CC_SHA256_Init(&hashObject);
    CC_SHA256_Update(&hashObject, opad, blockSize);
    CC_SHA256_Update(&hashObject, digest, CC_SHA256_DIGEST_LENGTH);
    CC_SHA256_Final(digest, &hashObject);
    
    //计算hex值
    const unsigned int hex_len = CC_SHA256_DIGEST_LENGTH*2+2;
    char hex[hex_len];
    for(i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        snprintf(&hex[i*2], hex_len-i*2, "%02x", digest[i]);
    }
    
    NSData *HMAC = [[NSData alloc] initWithBytes:hex length:strlen(hex)];
    NSString *hash = [[NSString alloc] initWithData:HMAC encoding:NSUTF8StringEncoding];
    
    [inputStream close];
    return hash;
}


#pragma mark 对输入流进行hmacmd5加密
/**
 *	@brief	对输入流进行hmacMd5加密
 *
 *	@param 	inputStream 	输入流
 *	@param 	keyStr 	密钥
 *
 *	@return	加密后的结果
 */
+(NSString *)hmacMd5WithInputStream:(NSInputStream *)inputStream WiehKey:(NSString *)keyStr
{
    //打开inputStream
    [inputStream open];
    
    const char *cKey  = [keyStr cStringUsingEncoding:NSUTF8StringEncoding];
    const unsigned int blockSize = 64;
    char ipad[blockSize];
    char opad[blockSize];
    char keypad[blockSize];
    
    unsigned int keyLen = (unsigned int)strlen(cKey);
    CC_MD5_CTX hashObject;
    if (keyLen > blockSize) {
        CC_MD5_Init(&hashObject);
        CC_MD5_Update(&hashObject, cKey, keyLen);
        CC_MD5_Final((unsigned char *)keypad, &hashObject);
        keyLen = CC_MD5_DIGEST_LENGTH;
    }
    else {
        memcpy(keypad, cKey, keyLen);
    }
    
    memset(ipad, 0x36, blockSize);
    memset(opad, 0x5c, blockSize);
    
    int i;
    for (i = 0; i < keyLen; i++) {
        ipad[i] ^= keypad[i];
        opad[i] ^= keypad[i];
    }
    
    // 初始化hash对象
    CC_MD5_Init(&hashObject);
    CC_MD5_Update(&hashObject, ipad, blockSize);
    
    bool hasMoreData = true;
    unsigned long readLen = 0;
    uint8_t buffer[FileHashDefaultChunkSizeForReadingData];
    
    //循环加密
    while (hasMoreData) {
        readLen = [inputStream read:buffer maxLength:FileHashDefaultChunkSizeForReadingData];
        
        if (readLen == 0) {
            hasMoreData = false;
            continue;
        }
        
        if (readLen > 0) {
            CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readLen);
        }
    }
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    
    CC_MD5_Init(&hashObject);
    CC_MD5_Update(&hashObject, opad, blockSize);
    CC_MD5_Update(&hashObject, digest, CC_MD5_DIGEST_LENGTH);
    CC_MD5_Final(digest, &hashObject);
    
    //计算hex值
    const unsigned int hex_len = CC_MD5_DIGEST_LENGTH*2+2;
    char hex[hex_len];
    for(i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        snprintf(&hex[i*2], hex_len-i*2, "%02x", digest[i]);
    }
    
    NSData *HMAC = [[NSData alloc] initWithBytes:hex length:strlen(hex)];
    NSString *hash = [[NSString alloc] initWithData:HMAC encoding:NSUTF8StringEncoding];
    
    [inputStream close];
    
    return hash;
    
}


#pragma mark 对输入流进行hmacSha1加密
/**
 *	@brief	对输入流进行hmacSha1加密
 *
 *	@param 	inputStream 	输入流
 *	@param 	keyStr 	密钥
 *
 *	@return	加密后的结果
 */
+(NSString *)hmacSha1WithInputStream:(NSInputStream *)inputStream WiehKey:(NSString *)keyStr
{
    
    //打开inputStream
    [inputStream open];
    
    const char *cKey  = [keyStr cStringUsingEncoding:NSUTF8StringEncoding];
    const unsigned int blockSize = 64;
    char ipad[blockSize];
    char opad[blockSize];
    char keypad[blockSize];
    
    unsigned int keyLen = (unsigned int)strlen(cKey);
    CC_SHA1_CTX hashObject;
    if (keyLen > blockSize) {
        CC_SHA1_Init(&hashObject);
        CC_SHA1_Update(&hashObject, cKey, keyLen);
        CC_SHA1_Final((unsigned char *)keypad, &hashObject);
        keyLen = CC_SHA1_DIGEST_LENGTH;
    }
    else {
        memcpy(keypad, cKey, keyLen);
    }
    
    memset(ipad, 0x36, blockSize);
    memset(opad, 0x5c, blockSize);
    
    int i;
    for (i = 0; i < keyLen; i++) {
        ipad[i] ^= keypad[i];
        opad[i] ^= keypad[i];
    }
    
    // 初始化hash对象
    CC_SHA1_Init(&hashObject);
    CC_SHA1_Update(&hashObject, ipad, blockSize);
    
    bool hasMoreData = true;
    unsigned long readLen = 0;
    uint8_t buffer[FileHashDefaultChunkSizeForReadingData];
    
    //循环加密
    while (hasMoreData) {
        readLen = [inputStream read:buffer maxLength:FileHashDefaultChunkSizeForReadingData];
        
        if (readLen == 0) {
            hasMoreData = false;
            continue;
        }
        
        if (readLen > 0) {
            CC_SHA1_Update(&hashObject,(const void *)buffer,(CC_LONG)readLen);
        }
    }
    
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1_Final(digest, &hashObject);
    
    CC_SHA1_Init(&hashObject);
    CC_SHA1_Update(&hashObject, opad, blockSize);
    CC_SHA1_Update(&hashObject, digest, CC_SHA1_DIGEST_LENGTH);
    CC_SHA1_Final(digest, &hashObject);
    
    //计算hex值
    const unsigned int hex_len = CC_SHA1_DIGEST_LENGTH*2+2;
    char hex[hex_len];
    for(i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        snprintf(&hex[i*2], hex_len-i*2, "%02x", digest[i]);
    }
    
    NSData *HMAC = [[NSData alloc] initWithBytes:hex length:strlen(hex)];
    NSString *hash = [[NSString alloc] initWithData:HMAC encoding:NSUTF8StringEncoding];
    
    [inputStream close];
    
    return hash;
}


@end
