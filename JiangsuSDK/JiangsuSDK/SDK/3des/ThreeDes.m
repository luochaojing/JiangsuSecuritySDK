//
//  ThreeDes.m
//  JiangsuSDK
//
//  Created by Luo on 16/11/29.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import "ThreeDes.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <Security/Security.h>
#import "GTMBase64.h"

#define gIV   @"luo"

@implementation ThreeDes


+ (NSString *)threeDesEncrypttWithKey:(NSString *)key clearText:(NSString *)clearText
{
    NSData *clearData = [clearText dataUsingEncoding:NSUTF8StringEncoding];
    
    size_t plainTextBufferSize = [clearData length];
    
    const void *vplainText = (const void *)[clearData bytes];
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t moveBytes = 0;
    
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc(bufferPtrSize * sizeof(uint8_t));
    
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    const void *vkey = (const void *)[key UTF8String];
    
    const void *vintVec = (const void *)[gIV UTF8String];
    
    ccStatus = CCCrypt(kCCEncrypt,
                       kCCAlgorithm3DES,
                       kCCOptionECBMode|kCCOptionPKCS7Padding,
                       vkey,
                       kCCKeySize3DES,
                       vintVec,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &moveBytes
                       );
    
    NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSInteger)moveBytes];
    NSString *result = [GTMBase64 stringByEncodingData:myData];
    
    return result;
    
}


+ (NSString *)threeDesDencryotWithKey:(NSString *)key cipherText:(NSString *)cipherText
{
    NSData *encryptData = [GTMBase64 decodeData:[cipherText dataUsingEncoding:NSUTF8StringEncoding]];
    
    size_t plainTextBufferSize = [encryptData length];
    const void *vplainText = [encryptData bytes];
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    const void *vkey = (const void *) [key UTF8String];
    
    const void *vinitVec = (const void *) [gIV UTF8String];
    
    ccStatus = CCCrypt(kCCDecrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding|kCCOptionECBMode,
                       vkey,
                       kCCKeySize3DES,
                       vinitVec,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    
    NSString *result = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr
                                                                     length:(NSUInteger)movedBytes] encoding:NSUTF8StringEncoding];
    
    
    return result;
}


+ (NSString *)getTripleDesKeyWithUserPin:(NSString *)pin
                
{
    const char *cStr = [pin UTF8String];
    unsigned char result[16];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result );
    
    //其实是返回32位，16位不过是去掉前后8位，取中间的16位
    NSString *midString = [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X",
            
            //result[0], result[1], result[2], result[3],
            
            result[4], result[5], result[6], result[7],
            
            result[8], result[9], result[10], result[11]
        
            //result[12], result[13], result[14], result[15]
            ];
    
    //取前8位补足后八位--组成24位
    NSString *appendStr = [midString substringFromIndex:8];

    NSString *pin3DESKey = [NSString stringWithFormat:@"%@%@",midString,appendStr];
    
    return pin3DESKey;
}

@end
