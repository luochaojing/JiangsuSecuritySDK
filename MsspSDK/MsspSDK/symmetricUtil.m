//
//  AESUtil.m
//  MsspSDK
//  对称密钥生成工具
//  Created by huwenjun on 15-12-25.
//  Copyright (c) 2015年 aspire. All rights reserved.
//

#import "SymmetricUtil.h"
#import "LocalDataLogic.h"
static const uint8_t symmetricKeyIdentifier[]	= "com.aspire.ca.mssp.symmetrickey\0";
static NSString *base64_Table=@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

@implementation SymmetricUtil

/**
 *对称加密的工具类单例
 *@author huwenjun
 *@return 对象单例
 */
+ (SymmetricUtil *)sharedSymmetricUtil
{
    static SymmetricUtil *__singletion;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __singletion=[[self alloc] init];
    });
    return __singletion;
}

- (id)init
{
    self=[super init];
    if (!self)
    {
        return nil;
    }
    self.symmetricTag = [[NSData alloc] initWithBytes:symmetricKeyIdentifier length:sizeof(symmetricKeyIdentifier)];
    return self;
}

/**
 *获取用于加密私钥的对称密钥 满足iv值16个字节 key值16个字节
 *@author huwenjun
 *@return 用于加密私钥的对称密钥
 */
- (NSString *)genSignAESKey
{
    NSString *aesKey=[self getSymmetricKeyStr:16 key_length:16];
    return aesKey;
}

/**
 *获取用于本地加密接口的对称密钥 iv和key长度随机生成 若iv值为8个字节则key为24 调用3des加密 
 *否则iv值16个字节 key值随机为16个字节 24个字节 32个字节 分别对应128位 192位 256位密钥
 *@author huwenjun
 *@return 用于本地加密接口的对称密钥
 */
- (NSString *)genLocalEncryptKey
{
    int iv_length=0;
    int key_length=0;
    int iv_flag=abs(arc4random())%2;
    if(iv_flag==0)
    {
        iv_length=8;
        key_length=24;
    }
    else
    {
        iv_length=16;
        int key_flag=abs(arc4random())%32;
        if (key_flag<16)
        {
            key_length=16;
        }
        else if (key_flag<24&&key_flag>=16)
        {
            key_length=24;
        }
        else
        {
            key_length=32;
        }
    }
    NSString *symmetricKey=[self getSymmetricKeyStr:iv_length key_length:key_length];
    return symmetricKey;
}

/**
 *获取用于本地文件（包括证书，密钥等）加密的对称密钥 iv值为16个字节 key为唯一标识截取16个字节固定密钥
 *@author huwenjun
 *@return 用于本地文件加密的对称密钥
 */
- (NSString *)genLocalFileEncryptKey
{
    NSMutableString *symmetricKey=[[NSMutableString alloc] init];
    for(int i=0;i<16;i++)
    {
        NSString *ivChar=[base64_Table substringWithRange:NSMakeRange(5, 1)];
        [symmetricKey appendString:ivChar];
    }
    [symmetricKey appendString:@"$"];
    /************获取唯一标识取16位***********/
    NSString *deviceIdentity=[[LocalDataLogic sharedLocalData] getDeviceIdentity];
    
    /************************************/
    
    return symmetricKey;
}

/**
 *计算生成对称密钥
 *@author huwenjun
 *@param iv_length iv长度
 *@param key_length key长度
 *@return 对称密钥
 */
- (NSString *)getSymmetricKeyStr:(int)iv_length key_length:(int)key_length
{
    int index=0;
    int tableLen=(int)base64_Table.length;
    NSMutableString *symmetricKey=[[NSMutableString alloc] init];
    for(int i=0;i<iv_length;i++)
    {
        index=abs(arc4random())%tableLen;//绝对值？
        NSString *ivChar=[base64_Table substringWithRange:NSMakeRange(index, 1)];//相当于随机抽一个字母
        [symmetricKey appendString:ivChar];//--生成一个iv长度随机串
    }
    [symmetricKey appendString:@"$"];//"$"分割符号？
    for(int i=0;i<key_length;i++)
    {
        index=abs(arc4random())%tableLen;
        NSString *ivChar=[base64_Table substringWithRange:NSMakeRange(index, 1)];
        [symmetricKey appendString:ivChar];
    }
    return symmetricKey;
}


- (void)generateSymmetricKey
{
    OSStatus sanityCheck = noErr;
    uint8_t * symmetricKey = NULL;
    
    // First delete current symmetric key.
    [self deleteSymmetricKey];
    
    // Container dictionary
    
    
    NSMutableDictionary *symmetricKeyAttr = [[NSMutableDictionary alloc] init];
    [symmetricKeyAttr setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [symmetricKeyAttr setObject:self.symmetricTag forKey:(__bridge id)kSecAttrApplicationTag];
    [symmetricKeyAttr setObject:[NSNumber numberWithUnsignedInt:CSSM_ALGID_AES] forKey:(__bridge id)kSecAttrKeyType];
    [symmetricKeyAttr setObject:[NSNumber numberWithUnsignedInt:(unsigned int)(kChosenCipherKeySize << 3)] forKey:(__bridge id)kSecAttrKeySizeInBits];
    [symmetricKeyAttr setObject:[NSNumber numberWithUnsignedInt:(unsigned int)(kChosenCipherKeySize << 3)]	forKey:(__bridge id)kSecAttrEffectiveKeySize];
    [symmetricKeyAttr setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecAttrCanEncrypt];
    [symmetricKeyAttr setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecAttrCanDecrypt];
    [symmetricKeyAttr setObject:(id)kCFBooleanFalse forKey:(__bridge id)kSecAttrCanDerive];
    [symmetricKeyAttr setObject:(id)kCFBooleanFalse forKey:(__bridge id)kSecAttrCanSign];
    [symmetricKeyAttr setObject:(id)kCFBooleanFalse forKey:(__bridge id)kSecAttrCanVerify];
    [symmetricKeyAttr setObject:(id)kCFBooleanFalse forKey:(__bridge id)kSecAttrCanWrap];
    [symmetricKeyAttr setObject:(id)kCFBooleanFalse forKey:(__bridge id)kSecAttrCanUnwrap];
    
    // Allocate some buffer space. I don't trust calloc.
    symmetricKey = (uint8_t *)malloc( kChosenCipherKeySize * sizeof(uint8_t) );
    
    //LOGGING_FACILITY( symmetricKey != NULL, @"Problem allocating buffer space for symmetric key generation." );
    
    memset((void *)symmetricKey, 0x0, kChosenCipherKeySize);
    
    sanityCheck = SecRandomCopyBytes(kSecRandomDefault, kChosenCipherKeySize, symmetricKey);
    //LOGGING_FACILITY1( sanityCheck == noErr, @"Problem generating the symmetric key, OSStatus == %d.", sanityCheck );
    
    self.symmetricKeyRef = [[NSData alloc] initWithBytes:(const void *)symmetricKey length:kChosenCipherKeySize];
    
    // Add the wrapped key data to the container dictionary.
    [symmetricKeyAttr setObject:self.symmetricKeyRef
                         forKey:(__bridge id)kSecValueData];
    
    // Add the symmetric key to the keychain.
    sanityCheck = SecItemAdd((__bridge CFDictionaryRef) symmetricKeyAttr, NULL);
    //LOGGING_FACILITY1( sanityCheck == noErr || sanityCheck == errSecDuplicateItem, @"Problem storing the symmetric key in the keychain, OSStatus == %d.", sanityCheck );
    
    if (symmetricKey) free(symmetricKey);
    symmetricKeyAttr=nil;
}

- (void)deleteSymmetricKey
{
    OSStatus sanityCheck = noErr;
    
    NSMutableDictionary * querySymmetricKey = [[NSMutableDictionary alloc] init];
    
    // Set the symmetric key query dictionary.
    [querySymmetricKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [querySymmetricKey setObject:self.symmetricTag forKey:(__bridge id)kSecAttrApplicationTag];
    [querySymmetricKey setObject:[NSNumber numberWithUnsignedInt:CSSM_ALGID_AES] forKey:(__bridge id)kSecAttrKeyType];
    
    // Delete the symmetric key.
    sanityCheck = SecItemDelete((__bridge CFDictionaryRef)querySymmetricKey);
    //LOGGING_FACILITY1( sanityCheck == noErr || sanityCheck == errSecItemNotFound, @"Error removing symmetric key, OSStatus == %d.", sanityCheck );
    
    querySymmetricKey=nil;
    
}

- (NSData *)getSymmetricKeyBytes {
    OSStatus sanityCheck = noErr;
    CFTypeRef  symmetricKeyReturn = nil;
    
    if (self.symmetricKeyRef == nil) {
        NSMutableDictionary * querySymmetricKey = [[NSMutableDictionary alloc] init];
        
        // Set the private key query dictionary.
        [querySymmetricKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
        [querySymmetricKey setObject:self.symmetricTag forKey:(__bridge id)kSecAttrApplicationTag];
        [querySymmetricKey setObject:[NSNumber numberWithUnsignedInt:CSSM_ALGID_AES] forKey:(__bridge id)kSecAttrKeyType];
        [querySymmetricKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnData];
        
        // Get the key bits.
        sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef)querySymmetricKey, (CFTypeRef *)&symmetricKeyReturn);
        
        if (sanityCheck == noErr && symmetricKeyReturn != nil) {
            self.symmetricKeyRef =  (__bridge NSData*)symmetricKeyReturn;
        } else {
            self.symmetricKeyRef = nil;
        }
        
        querySymmetricKey=nil;
    } else {
        symmetricKeyReturn =  (__bridge CFTypeRef)self.symmetricKeyRef;
    }
    
    return (__bridge NSData*)symmetricKeyReturn;
}

- (NSData *)AES256EncryptWithKey:(NSString *)key data:(NSData *)data
{
    //加密
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          0x0000|kCCModeCBC,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}
@end
