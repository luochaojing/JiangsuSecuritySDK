//
//  RSAUtil.m
//  MsspSDK
//
//  Created by huwenjun on 15-12-11.
//  Copyright (c) 2015年 aspire. All rights reserved.
//

#import "RSAUtil.h"
#import "TTMBase64.h"

//#import "Base64Util.h"
#import <Security/Security.h>
static const UInt8 publicKeyIdentifier[] = "com.aspire.ca.mssp.publickey\0";
static const UInt8 privateKeyIdentifier[] = "com.aspire.ca.mssp.privatekey\0";


@implementation RSAUtil

/**
 *生成用户公钥
 *@author huwenjun
 *@return 用户公钥
 */
+ (SecKeyRef)getPublicKeyRef
{
    OSStatus sanityCheck = noErr;
    SecKeyRef publicKeyReference = NULL;
    
    NSMutableDictionary * queryPublicKey = [NSMutableDictionary dictionaryWithCapacity:0];
    
    // Set the public key query dictionary.
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    
    NSData *publicTag = [[NSData alloc] initWithBytes:publicKeyIdentifier length:sizeof(publicKeyIdentifier)];
    
    [queryPublicKey setObject:publicTag forKey: (__bridge id)kSecAttrApplicationTag];
    
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    // Get the key.
    sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef)queryPublicKey, (CFTypeRef *)&publicKeyReference);
    //NSLog(@"getPublicKey: result code: %ld", resultCode);
    
    if(sanityCheck != noErr)
    {
        publicKeyReference = NULL;
    }
    queryPublicKey =nil;
    return publicKeyReference;
}

/**
 *通过给定的base64字符串生成平台公钥
 *@author huwenjun
 *@param appID
 *@return 平台公钥
 */
+ (SecKeyRef)getMsspPublicKeyRef:(NSString *)base64key
{
    SecKeyRef publicKeyReference = NULL;
    
    //tsh 2016.3.11
    //NSData *certificateData1 =[[NSData alloc] initWithBase64EncodedString:base64key options:0];
    NSData *certificateData1 = [[NSData alloc] init];
    certificateData1 = [TTMBase64 decodeString:base64key];
    
    //NSString *str=[[NSString alloc] initWithCString:[certificateData1 bytes] encoding:NSUTF8StringEncoding];
    // NSString *result = [[NSString alloc] initWithData:certificateData1  encoding:NSUTF8StringEncoding];
    //    NSString *decodedString = [[NSString alloc] initWithData:certificateData1 encoding:NSUTF8StringEncoding];
    //
    //    NSData *certificateData=[decodedString dataUsingEncoding:NSUTF8StringEncoding];
    
    // 从公钥证书文件中获取到公钥的SecKeyRef指针;
    SecCertificateRef myCertificate =  SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)certificateData1);
    SecPolicyRef myPolicy = SecPolicyCreateBasicX509();
    SecTrustRef myTrust;
    OSStatus status = SecTrustCreateWithCertificates(myCertificate,myPolicy,&myTrust);
    SecTrustResultType trustResult;
    if (status == noErr)
    {
        status = SecTrustEvaluate(myTrust, &trustResult);
    }
    publicKeyReference = SecTrustCopyPublicKey(myTrust);
    CFRelease(myCertificate);
    CFRelease(myPolicy);
    CFRelease(myTrust);
    return publicKeyReference;
}

/**
 *生成用户公钥的NSData类型用于存储
 *@author huwenjun
 *@return 用户公钥的NSData类型
 */
+ (NSData *)publicKeyBits
{
    OSStatus sanityCheck = noErr;
    CFTypeRef  _publicKeyBitsReference = NULL;
    
    NSMutableDictionary * queryPublicKey = [NSMutableDictionary dictionaryWithCapacity:0];
    
    NSData *publicTag = [[NSData alloc] initWithBytes:publicKeyIdentifier length:sizeof(publicKeyIdentifier)];
    // Set the public key query dictionary.
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnData];
    
    // Get the key bits.
    sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef)queryPublicKey, (CFTypeRef *)&_publicKeyBitsReference);
    
    if (sanityCheck != noErr) {
        _publicKeyBitsReference = NULL;
    }
    return (__bridge NSData*)_publicKeyBitsReference;
}

/**
 *生成用户私钥
 *@author huwenjun
 *@return 用户私钥
 */
+ (SecKeyRef)getPrivateKeyRef
{
    OSStatus sanityCheck = noErr;
    SecKeyRef privateKeyReference = NULL;
    
    NSMutableDictionary * queryPrivateKey = [NSMutableDictionary dictionaryWithCapacity:0];
    
    // Set the public key query dictionary.
    [queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    
    NSData *privateTag = [[NSData alloc] initWithBytes:privateKeyIdentifier length:sizeof(privateKeyIdentifier)];
    
    [queryPrivateKey setObject:privateTag forKey: (__bridge id)kSecAttrApplicationTag];
    
    [queryPrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    [queryPrivateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    // Get the key.
    sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef)queryPrivateKey, (CFTypeRef *)&privateKeyReference);
    //NSLog(@"getPublicKey: result code: %ld", sanityCheck);
    
    if(sanityCheck != noErr)
    {
        privateKeyReference = NULL;
    }
    queryPrivateKey =nil;
    return privateKeyReference;
}

/**
 *生成用户私钥的NSData类型用于存储
 *@author huwenjun
 *@return 用户私钥的NSData类型
 */
+ (NSData *)privateKeyBits
{
    OSStatus sanityCheck = noErr;
    CFTypeRef  _privateKeyBitsReference = NULL;
    
    NSMutableDictionary * queryPrivateKey = [NSMutableDictionary dictionaryWithCapacity:0];
    
    NSData *privateTag = [[NSData alloc] initWithBytes:privateKeyIdentifier length:sizeof(privateKeyIdentifier)];
    // Set the public key query dictionary.
    [queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPrivateKey setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPrivateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnData];
    
    // Get the key bits.
    sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef)queryPrivateKey, (CFTypeRef *)&_privateKeyBitsReference);
    
    if (sanityCheck != noErr) {
        _privateKeyBitsReference = NULL;
    }
    
    return (__bridge NSData*)_privateKeyBitsReference;
}

/**
 *生成用户公私密钥对
 *@author huwenjun
 *@return 通过block返回密钥对
 */
+ (void)generateKeyPairRSAWithBlock:(void(^)(SecKeyRef publicKeyRef,SecKeyRef privateKeyRef))block
{
    OSStatus sanityCheck = noErr;
    SecKeyRef publicKeyRef = NULL;
    SecKeyRef privateKeyRef = NULL;
    // First delete current keys.
    [RSAUtil deleteAsymmetricKeys];
    
    // Container dictionaries.
    NSMutableDictionary * privateKeyAttr = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary * publicKeyAttr = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary * keyPairAttr = [NSMutableDictionary dictionaryWithCapacity:0];
    
    // Set top level dictionary for the keypair.
    [keyPairAttr setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [keyPairAttr setObject:[NSNumber numberWithUnsignedInteger:1024] forKey:(__bridge id)kSecAttrKeySizeInBits];
    
    // Set the private key dictionary.
    NSData *privateTag = [[NSData alloc] initWithBytes:privateKeyIdentifier length:sizeof(privateKeyIdentifier)];
    [privateKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    [privateKeyAttr setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    // See SecKey.h to set other flag values.
    
    // Set the public key dictionary.
    NSData *publicTag = [[NSData alloc] initWithBytes:publicKeyIdentifier length:sizeof(publicKeyIdentifier)];
    [publicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    [publicKeyAttr setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    // See SecKey.h to set other flag values.
    
    // Set attributes to top level dictionary.
    [keyPairAttr setObject:privateKeyAttr forKey:(__bridge id)kSecPrivateKeyAttrs];
    [keyPairAttr setObject:publicKeyAttr forKey:(__bridge id)kSecPublicKeyAttrs];
    
    // SecKeyGeneratePair returns the SecKeyRefs just for educational purposes.
    sanityCheck = SecKeyGeneratePair((__bridge CFDictionaryRef)keyPairAttr, &publicKeyRef, &privateKeyRef);
    
    if (sanityCheck != noErr)
    {
        publicKeyRef = NULL;
        privateKeyRef = NULL;
        block(NULL,NULL);
    }
    else
    {
        block(publicKeyRef,privateKeyRef);
    }
}

/**
 *删除钥匙链现存的公私密钥对
 *@author huwenjun
 *@return
 */
+ (void)deleteAsymmetricKeys
{
    OSStatus sanityCheck = noErr;
    NSMutableDictionary * queryPublicKey = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary * queryPrivateKey = [NSMutableDictionary dictionaryWithCapacity:0];
    
    // Set the public key query dictionary.
    NSData *publicTag = [[NSData alloc] initWithBytes:publicKeyIdentifier length:sizeof(publicKeyIdentifier)];
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    // Set the private key query dictionary.
    NSData *privateTag = [[NSData alloc] initWithBytes:privateKeyIdentifier length:sizeof(privateKeyIdentifier)];
    [queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPrivateKey setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    // Delete the private key.
    sanityCheck = SecItemDelete((__bridge CFDictionaryRef)queryPrivateKey);
    //LOGGING_FACILITY1( sanityCheck == noErr || sanityCheck == errSecItemNotFound, @"Error removing private key, OSStatus == %ld.", sanityCheck );
    
    // Delete the public key.
    sanityCheck = SecItemDelete((__bridge CFDictionaryRef)queryPublicKey);
    //LOGGING_FACILITY1( sanityCheck == noErr || sanityCheck == errSecItemNotFound, @"Error removing public key, OSStatus == %ld.", sanityCheck );
}

/**
 *使用公钥对小数据进行加密
 *@author huwenjun
 *@return
 */
+ (NSMutableData *)encryptByRSA:(SecKeyRef)publicKey data:(NSData *)data
{
    // 分配内存块，用于存放加密后的数据段
    size_t cipherBufferSize = SecKeyGetBlockSize(publicKey);
    uint8_t *cipherBuffer = (uint8_t *)malloc(cipherBufferSize * sizeof(uint8_t));
    double totalLength = [data length];
    size_t blockSize = cipherBufferSize - 12;
    size_t blockCount = (size_t)ceil(totalLength / blockSize);
    NSMutableData *encryptedData = [NSMutableData data];
    // 分段加密
    for (int i = 0; i < blockCount; i++)
    {
        NSUInteger loc = i * blockSize;
        // 数据段的实际大小。最后一段可能比blockSize小。
        //int dataSegmentRealSize = MIN(blockSize, [plainData length] - loc);
        int dataSegmentRealSize=blockSize>([data length] - loc)?([data length] - loc):blockSize;
        // 截取需要加密的数据段
        NSData *dataSegment = [data subdataWithRange:NSMakeRange(loc, dataSegmentRealSize)];
        OSStatus status = SecKeyEncrypt(publicKey, kSecPaddingPKCS1, (const uint8_t *)[dataSegment bytes], dataSegmentRealSize, cipherBuffer, &cipherBufferSize);
        if (status == errSecSuccess)
        {
            NSData *encryptedDataSegment = [[NSData alloc] initWithBytes:(const void *)cipherBuffer length:cipherBufferSize];
            // 追加加密后的数据段
            [encryptedData appendData:encryptedDataSegment];
            encryptedDataSegment=nil;
        } else
        {
            if (cipherBuffer)
            {
                free(cipherBuffer);
            }
            return nil;
        }
    }
    if (cipherBuffer)
    {
        free(cipherBuffer);
    }
    return encryptedData;
}

/**
 *验证证书的可信度
 *@param cerData 证书的二进制
 *@author huwenjun
 *@return 是否可信
 */
+ (BOOL)validateCertificate:(NSData *)cerData
{
    BOOL result=NO;
    OSStatus status = -1;
    SecTrustRef trust;
    SecTrustResultType trustResult;
    SecCertificateRef cert = SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)cerData);
    SecPolicyRef policy = SecPolicyCreateBasicX509();
    status = SecTrustCreateWithCertificates(cert, policy, &trust);
    if (status == errSecSuccess && trust) {
        NSArray *certs = [NSArray arrayWithObject:(__bridge id)cert];
        status = SecTrustSetAnchorCertificates(trust, (__bridge CFArrayRef)certs);
        if (status == errSecSuccess) {
            status = SecTrustEvaluate(trust, &trustResult);
            // 证书可信
            if (status == errSecSuccess && (trustResult == kSecTrustResultUnspecified || trustResult == kSecTrustResultProceed)){
                result=YES;
            }
        }
    }
    return result;
}



#pragma mark - 我自己加的

//- (void)decryptWithPrivateKey:(uint8_t *)cipherBuffer plainBuffer:(uint8_t *)plainBuffer
//{
//    OSStatus status = noErr;
//    
//    size_t cipherBufferSize = strlen((char *)cipherBuffer);
//    
//    NSLog(@"decryptWithPrivateKey: length of buffer: %lu", BUFFER_SIZE);
//    NSLog(@"decryptWithPrivateKey: length of input: %lu", cipherBufferSize);
//    
//    // DECRYPTION
//    size_t plainBufferSize = BUFFER_SIZE;
//    
//    //  Error handling
//    status = SecKeyDecrypt([self getPrivateKeyRef],
//                           PADDING,
//                           &cipherBuffer[0],
//                           cipherBufferSize,
//                           &plainBuffer[0],
//                           &plainBufferSize
//                           );
//    NSLog(@"decryption result code: %ld (size: %lu)", status, plainBufferSize);
//    NSLog(@"FINAL decrypted text: %s", plainBuffer);
//    
//}

@end
