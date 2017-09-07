//
//  JSSCommon.m
//  JiangsuSDK
//
//  Created by Luo on 16/11/25.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import "JSSCommon.h"

//MD5
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
//base64
#import "GTMBase64.h"

//IP
#import <ifaddrs.h>
#import <arpa/inet.h>

#import "KeychainItemWrapper.h"

//! 存在本地自动imei
#define IMEIIDENTITY @"com.aspire.jss.sdk.imei"

//! hmac-MD5加解密密钥
static NSString *SECRETKEY = @"nkiwekwo";

//! 数字数组
static NSString *number_Table = @"0123456789";





@implementation JSSCommon

+ (NSString *)getTransactionID
{
    
    //日期
    NSDate *date = [NSDate date];
    NSDateFormatter *forMatter = [[NSDateFormatter alloc] init];
    [forMatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateString = [forMatter stringFromDate:date];
    
    //随机数
    NSString *randomString = @"";
    for (int i = 0; i < 6; i++) {
        int x = arc4random()%10;
        randomString = [NSString stringWithFormat:@"%@%d",randomString,x];
    }
    
    return [NSString stringWithFormat:@"%@%@",dateString,randomString];
}


#pragma mark - 生成移动国际标识，使用大随机数的方式产生，以保证重复的几率很小，
+ (NSString *)getIMEI
{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:IMEIIDENTITY accessGroup:nil];
    NSString *imeiStr = [keychainItem objectForKey:(__bridge id)kSecAttrService];
    if (!imeiStr ||[imeiStr isEqualToString:@""])
    {
        int index = 0;
        int numberLen = (int)number_Table.length;
        NSMutableString *imei = [NSMutableString stringWithString:@"460"];//???为啥要以460开头呢
        for (int i = 0; i < 10; i++)
        {
            index = (arc4random())%numberLen;
            NSString *imeiChar = [number_Table substringWithRange:NSMakeRange(index, 1)];
            [imei appendString:imeiChar];
        }
        [keychainItem setObject:imei forKey:(__bridge id)kSecAttrService];
        
        imeiStr = (NSString *)imei;
        
    }
    
    keychainItem = nil;
    return imeiStr;
}



#pragma mark - 获取ip地址

+ (NSString *)getIPAdress
{
        NSString *address = @"error";
        struct ifaddrs *interfaces = NULL;
        struct ifaddrs *temp_addr = NULL;
        int success = 0;
        // retrieve the current interfaces - returns 0 on success
        success = getifaddrs(&interfaces);
        if (success == 0) {
            // Loop through linked list of interfaces
            temp_addr = interfaces;
            while(temp_addr != NULL) {
                if(temp_addr->ifa_addr->sa_family == AF_INET) {
                    // Check if interface is en0 which is the wifi connection on the iPhone
                    if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                        // Get NSString from C String
                        address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    }
                }
                temp_addr = temp_addr->ifa_next;
            }
        }
        // Free memory
        freeifaddrs(interfaces);
        return address;
}


#pragma mark - HMAC-MD5摘要

+ (NSString *)HMACMD5WithClearText:(NSString *)clearText
{
    
    NSString *keyStr = SECRETKEY;
    const char *cKey  = [keyStr cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [clearText cStringUsingEncoding:NSUTF8StringEncoding];
    const unsigned int blockSize = 64;
    char ipad[blockSize];
    char opad[blockSize];
    char keypad[blockSize];
    
    unsigned int keyLen = (unsigned int)strlen(cKey);
    CC_MD5_CTX ctxt;
    if (keyLen > blockSize) {
        CC_MD5_Init(&ctxt);
        CC_MD5_Update(&ctxt, cKey, keyLen);
        CC_MD5_Final((unsigned char *)keypad, &ctxt);
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
    
    CC_MD5_Init(&ctxt);
    CC_MD5_Update(&ctxt, ipad, blockSize);
    CC_MD5_Update(&ctxt, cData, strlen(cData));
    unsigned char md5[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(md5, &ctxt);
    
    CC_MD5_Init(&ctxt);
    CC_MD5_Update(&ctxt, opad, blockSize);
    CC_MD5_Update(&ctxt, md5, CC_MD5_DIGEST_LENGTH);
    CC_MD5_Final(md5, &ctxt);
    
    //不转16进制，与后台统一
    NSString *noHexString = [GTMBase64 stringByEncodingBytes:md5 length:CC_MD5_DIGEST_LENGTH];
    
    //一般都是转化成16进制编码，但是Java后台并不适用（Hex.encode），直接base。以下为先转16进制
    const unsigned int hex_len = CC_MD5_DIGEST_LENGTH*2+2;//\0用于结尾
    char hex[hex_len];
    for(i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        snprintf(&hex[i*2], hex_len-i*2, "%02x", md5[i]);//转换成16进制
    }
    NSData *HMAC = [[NSData alloc] initWithBytes:hex length:strlen(hex)];
    NSString *hash = [[NSString alloc] initWithData:HMAC encoding:NSUTF8StringEncoding];
    hash = @"";
    
    return noHexString;
}

+ (BOOL)HMACMD5VerifyWithClearText:(NSString *)clearText cipherText:(NSString *)cipherText
{
    if (!clearText || !cipherText) {
        NSLog(@"明文或者密文为空，请重新输入！");
    }
    
    NSString *newCipherText = [JSSCommon HMACMD5WithClearText:clearText];
    if ([newCipherText isEqualToString:cipherText]) {
        return YES;
    }
    else
    {
        return NO;
    }
    
}


#pragma mark - 3DES加解密

+ (NSString *)getTripleDesKeyWithUserPin:(NSString *)pin
{
    return [ThreeDes getTripleDesKeyWithUserPin:pin];
}

+ (NSString *)threeDesEncrypttWithKey:(NSString *)key clearText:(NSString *)clearText
{
    return [ThreeDes threeDesEncrypttWithKey:key clearText:clearText];
}

+ (NSString *)threeDesDencryotWithKey:(NSString *)key cipherText:(NSString *)cipherText
{
    return [ThreeDes threeDesDencryotWithKey:key cipherText:cipherText];
}


#pragma mark - base64编码

//base64编码
+ (NSString *)base64EncodingWithClearText:(NSString *)clearText
{
    NSData *utf8Data = [clearText dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Str = [utf8Data base64EncodedStringWithOptions:0];
    return base64Str;
}

//base64解码
+ (NSString *)base64DecodingWithBasedString:(NSString *)basedString
{
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:basedString options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    return decodedString;
}


@end
