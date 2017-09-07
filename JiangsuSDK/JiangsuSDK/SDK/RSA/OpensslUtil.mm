//
//  OpensslUtil.m
//  JiangsuSDK
//
//  Created by Luo on 16/11/29.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import "OpensslUtil.h"
#import "GTMBase64.h"

#include <openssl/x509.h>


@implementation OpensslUtil


/**
 *  获取单例
 *
 *  @return 单例
 */
+ (OpensslUtil *)sharedOpensslUtil
{
    static OpensslUtil *__sinton;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
       
        __sinton = [[OpensslUtil alloc] init];
        
        
    });
    
    return __sinton;
}


//! 生成字典
- (NSDictionary *)generateKeyDicRSAWithKeyLength:(int)keyLength
{
    std::string std_publicKey;
    std::string std_privateKey;
    opensslwapper->generateRSAKey(keyLength, std_publicKey, std_privateKey);
    std::string std_publicKeyBase64=base->encode(std_publicKey);
    std::string std_privateKeyBase64=base->encode(std_privateKey);
    
    NSString *publicKeys= [NSString stringWithCString:std_publicKeyBase64.c_str() encoding:[NSString defaultCStringEncoding]];
    NSString *privateKeys= [NSString stringWithCString:std_privateKeyBase64.c_str() encoding:[NSString defaultCStringEncoding]];
    

    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    if (publicKeys) {
        
        [dic setObject:publicKeys forKey:@"publicKey"];
    }
    
    if (privateKeys) {
        [dic setObject:privateKeys forKey:@"privateKey"];
    }
    
    return dic;
}



- (void)generateKeyPairRSA:(int)keyLength
                     block:(void (^)(NSString *publicKey, NSString *privateKey))block
{
    std::string std_publicKey;
    std::string std_privateKey;
    opensslwapper->generateRSAKey(keyLength, std_publicKey, std_privateKey);
    
    //对密钥对进行base64编码
    std::string std_publicKeyBase64=base->encode(std_publicKey);
    std::string std_privateKeyBase64=base->encode(std_privateKey);
    
    //转换成iOS的string
    NSString *publicKeys= [NSString stringWithCString:std_publicKeyBase64.c_str() encoding:[NSString defaultCStringEncoding]];
    NSString *privateKeys= [NSString stringWithCString:std_privateKeyBase64.c_str() encoding:[NSString defaultCStringEncoding]];
    
    block(publicKeys,privateKeys);

}


#pragma mark - 使用公钥RSA加密

- (NSData *)encryptionByRSA:(NSString *)publicKey data:(unsigned char *)data length:(size_t)length
{
    //将字符数组转成c++的string
    std::string std_dataStr( reinterpret_cast<char const*>(data),length);
    
    //假如私钥是英文和数字的，得到结果不变，但是由NSString->c++
    std::string std_publicKeyBase64=[publicKey UTF8String];
    
    //base64解密
    std::string std_publicKey=base->decode(std_publicKeyBase64);
    
    //调用加密函数
    std::string std_resultDataStr=opensslwapper->encode_RSA_publicKey(std_publicKey, std_dataStr);
    
    //
    NSData *resultData=[[NSData alloc] initWithBytes:std_resultDataStr.data() length:std_resultDataStr.length()];
    
    return resultData;
    
}


#pragma mark - 使用私钥解密

//! 使用私钥解密
- (NSData *)decryptionByRSA:(NSString *)privateKey data:(unsigned char *)data length:(size_t)length
{
    std::string std_dataStr( reinterpret_cast<char const*>(data),length) ;
    std::string std_privateKeyBase64=[privateKey UTF8String];
    std::string std_privateKey=base->decode(std_privateKeyBase64);
    
    //调用c++方法
    std::string std_resultDataStr=opensslwapper->decode_RSA_privateKey(std_privateKey, std_dataStr);
    
    NSData *resultData=[[NSData alloc] initWithBytes:std_resultDataStr.data() length:std_resultDataStr.length()];
    return resultData;
}


//! 私钥解密
- (NSString *)decrytionByRSA:(NSString *)privateKey clearText:(NSString *)clearText
{
    
    if (!clearText) {
        return @"";
    }
    
    NSData *data = [clearText dataUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char *keyDataStr = (unsigned char *)[data bytes];
    size_t len0 = strlen((char *)keyDataStr);
    
    //密钥对生成有误？
    //确实是同一个公钥：每次加密的结果都不一样。明文的长度不可以超过公钥的长度----加密没问题！！！
    OpensslUtil *opensslUtil = [OpensslUtil sharedOpensslUtil];
    
    //这里面是将数据base64了，所以得出来的也是
    NSData *dataA = [opensslUtil encryptionByRSA:privateKey data:keyDataStr length:len0];
    
    NSData *datax = [GTMBase64 encodeData:dataA];///???? 不用加这一步
    
    //utf8的char数组进去，出来也是utf8（c++），转成NSDATA后需要先base64,再utf8变string
    
    NSString *readStr = [[NSString alloc] initWithData:datax encoding:NSUTF8StringEncoding];
    
    
    return readStr;
}


#pragma mark - 通过证书串获取序列号

- (NSString *)x509SerialNumWithDataString:(NSString *)certDataStr
{
    
    NSMutableString *serialNumber = [[NSMutableString alloc] init];
    std::string certUTF8Str = [certDataStr UTF8String];
    std::string certBase64Str = base->decode(certUTF8Str);
    
    X509 *x509 = opensslwapper->getX509ByString(certBase64Str);
    if (x509) {
        
        std::string stds = opensslwapper->checkCertExpire(certBase64Str);
        
        //获取序列号
        ASN1_INTEGER *Serial = X509_get_serialNumber(x509);
        for(int i = 0; i < Serial->length; i++)
        {
            [serialNumber appendString:[NSString stringWithFormat:@"%02x",Serial->data[i]]];
        }
        
        //获取签名算法：sha1,md5等
        ASN1_OBJECT *alg = x509->sig_alg->algorithm;
        NSMutableString *algStr = [[NSMutableString alloc] init];
        for (int i = 0; i < alg->length; i++) {
            
            [algStr appendString:[NSString stringWithFormat:@"%02x",alg->data[i]]];
        }
    }

    return serialNumber;
}



/**
 *  签名算法
 *
 *  @param privateKey 私钥
 *  @param data       签名原文
 *  @param hashAlg    哈希算法：sha1,md5(后台的是sha1)
 *
 *  @return 密文
 */
- (NSString *)signWithPrivateKey:(NSString *)privateKey data:(NSString *)data hashAlg:(NSString *)hashAlg
{
    std::string std_keyBase64=[privateKey UTF8String];
    std::string std_privateKey=base->decode(std_keyBase64);
    
    //原文解密
    std::string std_dataStr=[data UTF8String];
    //!!!!!!!!这个base64解密一定要有
    std_dataStr = base->decode(std_dataStr);
    
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



//传入的是非编码的文字
- (NSString *)signNobase64StrWithPrivateKey:(NSString *)privateKey data:(NSString *)data hashAlg:(NSString *)hashAlg
{
    
    std::string std_keyBase64=[privateKey UTF8String];
    std::string std_privateKey=base->decode(std_keyBase64);
    
    //原文解密
    std::string std_dataStr=[data UTF8String];
    //!!!!!!!!这个base64解密一定要有
    //std_dataStr = base->decode(std_dataStr);
    
    std::string std_signData;
    int result = opensslwapper->sign(std_privateKey, std_dataStr, std_signData, [hashAlg UTF8String]);
    
    NSString *signDataStr=nil;
    if(result == 1)
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
 *  通过后台返回的证书串：提取签名的hash算法
 *
 *  @param certDataString 后台返回的串
 *
 *  @return sha1 或者 md5
 */
- (NSString *)getHashAlgWithCertDataString:(NSString *)certDataString
{
    std::string certUTF8Str = [certDataString UTF8String];
    std::string certBase64Str = base->decode(certUTF8Str);
    
    X509 *x509 = opensslwapper->getX509ByString(certBase64Str);
    
    //---------获取日期------
    //可以根据ASN1_Time 转成可见的时间
    ASN1_TIME *noAfter = X509_get_notAfter(x509);
    NSMutableString *noAfterDateStr = [[NSMutableString alloc] init];
    
    for (int i = 0; i < noAfter->length; i++) {
        [noAfterDateStr appendString:[NSString stringWithFormat:@"%02x",noAfter->data[i]]];
    }
    
    //NSLog(@"获取证书的日期 = %@",noAfterDateStr);
    
    //-----------
    
    NSMutableString *hashAlg = [[NSMutableString alloc] init];
    if (x509) {
        ASN1_OBJECT *alg = x509->sig_alg->algorithm;
        for (int i = 0; i < alg->length; i++) {
            [hashAlg appendString:[NSString stringWithFormat:@"%02x",alg->data[i]]];
        }
        if ([hashAlg isEqualToString:@"2a864886f70d010105"]) {
            return @"sha1";
        }
        else
        {
            return @"md5";
        }
        
    }
    return NULL;
}


#pragma mark - MD5签名算法得验证

- (BOOL)verifymd5:(NSString *)publicKey data:(unsigned char *)data length:(int)length signData:(unsigned char *)signData length:(int)signlength
{
    std::string std_keyBase64=[publicKey UTF8String];
    std::string std_publicKey=base->decode(std_keyBase64);
    std::string std_dataStr( reinterpret_cast<char const*>(data),length) ;
    std::string std_signData( reinterpret_cast<char const*>(signData),signlength) ;
    std::string std_signDataBase64=base->decode(std_signData);
    bool result =opensslwapper->verify(std_publicKey, std_dataStr, std_signDataBase64);
    return result?YES:NO;
}


#pragma mark - SHA1签名算法的验证

- (BOOL)verifySha1:(NSString *)publicKey data:(unsigned char *)data length:(int)length signData:(unsigned char *)signData length:(int)signlength
{
    std::string std_keyBase64=[publicKey UTF8String];
    std::string std_publicKey=base->decode(std_keyBase64);
    std::string std_dataStr( reinterpret_cast<char const*>(data),length) ;
    std::string std_signData( reinterpret_cast<char const*>(signData),signlength) ;
    std::string std_signDataBase64=base->decode(std_signData);
    bool result =opensslwapper->verifySha1(std_publicKey, std_dataStr, std_signDataBase64);
    return result?YES:NO;
    
}

@end
