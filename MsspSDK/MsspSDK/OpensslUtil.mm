//
//  OpensslUtil.m
//  MsspSDK
//  openssl oc端的工具 用于调用openssl c++的代码
//  Created by huwenjun on 15-12-25.
//
//

#import "OpensslUtil.h"
#include "Base64.h"
@implementation OpensslUtil

/**
 *openssl调用c++的openssl工具
 *@author huwenjun
 *@return 对象单例
 */
+ (OpensslUtil *)sharedOpensslUtil
{
    static OpensslUtil *__singletion;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __singletion=[[self alloc] init];
    });
    return __singletion;
}

/**
 *生成用户公私密钥对
 *@author huwenjun
 *@param keyLength 密钥长度
 *@return 通过block返回密钥对
 */
- (void)generateKeyPairRSA:(int)keyLength block:(void(^)(NSString *publicKey,NSString *privateKey))block
{
    std::string std_publicKey;
    std::string std_privateKey;
    opensslwapper->generateRSAKey(keyLength, std_publicKey, std_privateKey);
    std::string std_publicKeyBase64=base->encode(std_publicKey);
    std::string std_privateKeyBase64=base->encode(std_privateKey);
    NSString *publicKeys= [NSString stringWithCString:std_publicKeyBase64.c_str() encoding:[NSString defaultCStringEncoding]];
    NSString *privateKeys= [NSString stringWithCString:std_privateKeyBase64.c_str() encoding:[NSString defaultCStringEncoding]];

    //NSLog(@"%@ ========= %@",publicKeys,privateKeys);
    block(publicKeys,privateKeys);
}

/**
 *使用公钥对数据进行加密
 *@author huwenjun
 *@param publicKey RSA加密的公钥
 *@param data RSA加密的数据
 *@param length 待加解密的数据长度
 *@return 加密后的数据
 */
- (NSData *)encryptionByRSA:(NSString *)publicKey data:(unsigned char *)data length:(size_t)length
{
    std::string std_dataStr( reinterpret_cast<char const*>(data),length);
    std::string std_publicKeyBase64=[publicKey UTF8String];
    std::string std_publicKey=base->decode(std_publicKeyBase64);
    std::string std_resultDataStr=opensslwapper->encode_RSA_publicKey(std_publicKey, std_dataStr);
    NSData *resultData=[[NSData alloc] initWithBytes:std_resultDataStr.data() length:std_resultDataStr.length()];
    return resultData;
}

/**
 *使用私钥对数据进行解密
 *@author huwenjun
 *@param privateKey RSA解密的私钥
 *@param data RSA解密的数据
 *@param length 待加解密的数据长度
 *@return 解密后的数据
 */
- (NSData *)decryptionByRSA:(NSString *)privateKey data:(unsigned char *)data length:(size_t)length
{
    std::string std_dataStr( reinterpret_cast<char const*>(data),length) ;
    std::string std_privateKeyBase64=[privateKey UTF8String];
    std::string std_privateKey=base->decode(std_privateKeyBase64);
    std::string std_resultDataStr=opensslwapper->decode_RSA_privateKey(std_privateKey, std_dataStr);
    NSData *resultData=[[NSData alloc] initWithBytes:std_resultDataStr.data() length:std_resultDataStr.length()];
    return resultData;
}

/**
 *aes对称加解密
 *@author huwenjun
 *@param key 对称密钥
 *@param encryptFlag 是否加密 yes为加密 no 为解密
 *@param data 待加解密的数据
 *@param length 待加解密的数据长度
 *@return 解密后的数据
 */
- (NSData *)AESOperation:(NSString *)key encryptFlag:(BOOL)encryptFlag data:(unsigned char *)data length:(size_t)length
{
    bool flag=encryptFlag?true:false;
    std::string std_dataStr( reinterpret_cast<char const*>(data),length) ;
    std::string std_key=[key UTF8String];
    std::string std_resultDataStr=opensslwapper->aes(std_key, flag, std_dataStr);
    NSData *resultData=[[NSData alloc] initWithBytes:std_resultDataStr.data() length:std_resultDataStr.length()];
    return resultData;
}

/**
 *aes对称加解密
 *@author huwenjun
 *@param key 对称密钥
 *@param encryptFlag 是否加密 yes为加密 no 为解密
 *@param data 待加解密的数据 char类型
 *@param length 待加解密的数据长度
 *@return 解密后的数据
 */
- (NSData *)AESOperationByCharData:(NSString *)key encryptFlag:(BOOL)encryptFlag data:(const char *)data length:(size_t)length
{
    bool flag=encryptFlag?true:false;
    std::string std_dataStr=data;
    std::string std_key=[key UTF8String];
    std::string std_resultDataStr=opensslwapper->aes(std_key, flag, std_dataStr);
    NSData *resultData=[[NSData alloc] initWithBytes:std_resultDataStr.data() length:std_resultDataStr.length()];
    return resultData;
}

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
           input_length:(int)input_length
{
    int ret;
    unsigned char *output;
    unsigned int output_length = 0;
    
    //调用c++方法
    ret = opensslwapper->OpensslWapper::HmacEncode([algo UTF8String],
                                                   [key UTF8String],
                                                   key_length,
                                                   [input UTF8String],
                                                   input_length,
                                                   output,
                                                   output_length);
    
    std::string std_output;
    std_output.assign(output, output + output_length);
    
    //进行base64编码
    std::string std_outputBase64 = base->encode(std_output);
    
    //转为16进制（hex）
    std::string std_hex = opensslwapper->OpensslWapper::hex(std_outputBase64);
    
    NSString *hexStr = [NSString stringWithCString:  (const char*)std_hex.c_str() encoding: NSASCIIStringEncoding];
    NSMutableString *returnStr = [[NSMutableString alloc] init];
    
    //在hex值中加入空格
    for (int i = 2; i <= hexStr.length; i += 2) {
        NSString *temp1 = [hexStr substringToIndex:i];
        NSString *temp2 = [temp1 substringFromIndex:i - 2];
        if (2 == i) {
            [returnStr appendString:temp2];
        } else {
            [returnStr appendFormat:@" %@", temp2];
        }
    }
    
    return returnStr;
}

/**
 对称加解密上下文初始化操作
 *@author huwenjun
 *@param key 对称密钥
 *@param encryptFlag 是否加密 yes为加密 no 为解密
 *@return 解密后的数据
 */
- (void)symmetricOperationInit:(NSString *)key encryptFlag:(BOOL)encryptFlag
{
    bool flag=encryptFlag?true:false;
    std::string std_key=[key UTF8String];
    opensslwapper->symmetricEncodeInit(std_key,flag);
}

/**
 分段对称加解密
 *@author huwenjun
 *@param data 待加解密的分段数据
 *@param length 待加解密的分段数据长度
 *@param encryptFlag 是否加密 yes为加密 no 为解密
 *@return 加解密后的分段数据
 */
- (NSData *)symmetricOperationUpdate:(unsigned char *)data length:(size_t)length encryptFlag:(BOOL)encryptFlag
{
    bool flag=encryptFlag?true:false;
    std::string std_dataStr( reinterpret_cast<char const*>(data),length) ;
    std::string std_resultDataStr=opensslwapper->symmetricEncodeUpdate(std_dataStr,flag);
    NSData *resultData=[[NSData alloc] initWithBytes:std_resultDataStr.data() length:std_resultDataStr.length()];
    return resultData;
}

/**
 分段对称加解密完成操作
 *@author huwenjun
 *@param encryptFlag 是否加密 yes为加密 no 为解密
 *@return 完成操作的偏移数据
 */
- (NSData *)symmetricOperationFinishe:(BOOL)encryptFlag
{
    bool flag=encryptFlag?true:false;
    std::string std_resultDataStr=opensslwapper->symmetricEncodeFinish(flag);
    NSData *resultData=[[NSData alloc] initWithBytes:std_resultDataStr.data() length:std_resultDataStr.length()];
    return resultData;
}

/**
 分段对称加解密完成操作
 *@author huwenjun
 *@param privateKey 签名私钥
 *@param data 待签名数据
 *@param hashAlg hasg算法标识
 *@return 签名数据
 */
- (NSString *)sign:(NSString *)privateKey data:(NSString *)data hashAlg:(NSString *)hashAlg
{
    std::string std_keyBase64=[privateKey UTF8String];
    std::string std_privateKey=base->decode(std_keyBase64);
    std::string std_dataStr=[data UTF8String];
    std::string std_signData;
    int result= opensslwapper->sign(std_privateKey, std_dataStr, std_signData, [hashAlg UTF8String]);
    NSString *signDataStr=nil;
    if(result==1)
    {
        std::string std_signDataBase64=base->encode(std_signData);
        signDataStr= [NSString stringWithCString:std_signDataBase64.c_str() encoding:[NSString defaultCStringEncoding]];
    }
    else
    {
        return nil;
    }
    return signDataStr;
}

/**
 分段对称加解密完成操作
 *@author huwenjun
 *@param privateKey 签名私钥
 *@param data 待签名数据char
 *@param length 待签名数据长度
 *@param hashAlg hasg算法标识
 *@return 签名数据
 */
- (NSData *)signData:(NSString *)privateKey data:(unsigned char *)data length:(int)length hashAlg:(NSString *)hashAlg
{
    std::string std_keyBase64=[privateKey UTF8String];
    std::string std_privateKey=base->decode(std_keyBase64);
    std::string std_dataStr( reinterpret_cast<char const*>(data),length) ;
    std::string std_signData;
    int result= opensslwapper->sign(std_privateKey, std_dataStr, std_signData, [hashAlg UTF8String]);
    NSData *signData=nil;
    if(result==1)
    {
        std::string std_signDataBase64=base->encode(std_signData);
        NSLog(@"签名base64值:%s",std_signDataBase64.c_str());
        signData=[[NSData alloc] initWithBytes:std_signDataBase64.data() length:std_signDataBase64.length()];
        
    }
    else
    {
        return nil;
    }
    return signData;
}

- (BOOL)verify:(NSString *)publicKey data:(unsigned char *)data length:(int)length signData:(unsigned char *)signData length:(int)signlength
{
    std::string std_keyBase64=[publicKey UTF8String];
    std::string std_publicKey=base->decode(std_keyBase64);
    std::string std_dataStr( reinterpret_cast<char const*>(data),length) ;
    std::string std_signData( reinterpret_cast<char const*>(signData),signlength) ;
    std::string std_signDataBase64=base->decode(std_signData);
    bool result =opensslwapper->verify(std_publicKey, std_dataStr, std_signDataBase64);
    return result?YES:NO;
}

/**
 获取证书过期时间
 *@author huwenjun
 *@param certData 证书数据
 *@return 证书过期时间
 */
- (NSDate *)checkCertExpire:(NSData *)certData
{
    unsigned char *certDataChar=(unsigned char *)[certData bytes];
    std::string std_dataStr( reinterpret_cast<char const*>(certDataChar),[certData length]);
    std::string std_resultDataStr=opensslwapper->checkCertExpire(std_dataStr);
    
    NSString *expiryTimeStr= [NSString stringWithCString:std_resultDataStr.c_str() encoding:[NSString defaultCStringEncoding]];
    
    NSDateComponents *expiryDateComponents = [[NSDateComponents alloc] init];
    
    expiryDateComponents.year   = [[expiryTimeStr substringWithRange:NSMakeRange(0, 4)] intValue];
    expiryDateComponents.month  = [[expiryTimeStr substringWithRange:NSMakeRange(4, 2)] intValue];
    expiryDateComponents.day    = [[expiryTimeStr substringWithRange:NSMakeRange(6, 2)] intValue];
    expiryDateComponents.hour   = [[expiryTimeStr substringWithRange:NSMakeRange(8, 2)] intValue];
    expiryDateComponents.minute = [[expiryTimeStr substringWithRange:NSMakeRange(10, 2)] intValue];
    expiryDateComponents.second = [[expiryTimeStr substringWithRange:NSMakeRange(12, 2)] intValue];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *expiryDate = [calendar dateFromComponents:expiryDateComponents];
    
    expiryDateComponents=nil;
    return expiryDate;
}
@end
