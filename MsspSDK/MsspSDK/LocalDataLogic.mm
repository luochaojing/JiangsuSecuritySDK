//
//  LocalEncryptionDataLogic.m
//  MsspSDK
//  本地加密存储的数据相关方法封装
//  Created by huwenjun on 15-12-14.
//  Copyright (c) 2015年 aspire. All rights reserved.
//

#import "LocalDataLogic.h"
#import "LocalDataModel.h"
#import "KeychainItemWrapper.h"
#import "SymmetricUtil.h"
#import "OpensslUtil.h"
#import "HashTool.h"
#import "ResultHeader.h"
#import "CoreAPIManage.h"

#define LOCALDATAIDENTITY @"com.aspire.ca.mssp.localdata"
#define UUIDIDENTITY @"com.aspire.ca.mssp.uuid"
#define IMSIIDENTITY @"com.aspire.ca.mssp.imsi"

static NSString *number_Table=@"0123456789";

@interface LocalDataLogic ()


@end

@implementation LocalDataLogic

/**
 *本地加密数据管理对象单例方法
 *@author huwenjun
 *@return 对象单例
 */
+ (LocalDataLogic *)sharedLocalData
{
    static LocalDataLogic *__singletion;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __singletion=[[self alloc] init];
    });
    return __singletion;
}

- (id)init
{
    self=[super init];
    if (!self) {
        return nil;
    }
    return self;
}

/**
 *得到加密序列化文件的对称密钥
 *@author huwenjun
 *@return 对称密钥
 */
- (NSString *)getEncryptionKey
{
    SymmetricUtil *util=[SymmetricUtil sharedSymmetricUtil];
    NSString *keyLocal=[util genLocalFileEncryptKey];
    /************请求获取验证码***********/
    
    /************************************/
    keyLocal=@"AAAAAAAAAAAAAAAA$0000000000000000";
    return keyLocal;
}

/**
 *从keychain得到本地保存的序列化对象 然后反序列化
 *@author huwenjun
 *@return 本地数据异常则返回NO 否则返回YES
 */
- (BOOL)getLocalData
{
    //根据请求得出文件加密密钥，发生改变则会重新加密存储//罗：根据什么请求？
    NSFileHandle *handle=[NSFileHandle fileHandleForReadingAtPath:[self getCertificationDataPath]];
    [handle seekToFileOffset:0];
    NSData *encryptionData= [handle readDataToEndOfFile];
    [handle closeFile];
    
    BOOL result=NO;
    if ([encryptionData length]>0)
    {
        NSString *key=[self getEncryptionKey];
        OpensslUtil *openssl=[OpensslUtil sharedOpensslUtil];
        NSData *decryptionData=[openssl AESOperation:key encryptFlag:NO data:(unsigned char *)[encryptionData bytes] length:[encryptionData length]];
        LocalDataModel *localData = (LocalDataModel *)[NSKeyedUnarchiver unarchiveObjectWithData:decryptionData];//反序列化得到对象
        [self setDataModel:localData];
        result=YES;
    }
    else
    {
        CoreAPIManage *api=[CoreAPIManage sharedCoreAPIManage];
        if (api.initResult==RC_SUCCESS)
        {
            api.initResult=RC_SYS_CALLINVALID;
            
            return NO;
        }
        NSLog(@"没有本地文件存储");
        LocalDataModel *localData=[[LocalDataModel alloc] init];
        if (!localData.deviceIdentity)
        {
            [localData setDeviceIdentity:[self getDeviceIdentity]];
        }
        if (!localData.simIdentity)
        {
            [localData setSimIdentity:[self getSIMIdentity]];
        }
        [self setDataModel:localData];
        [self saveLocalData];
        result=YES;
    }
    return result;
}

/**
 *将用户信息对象序列化后保存到本地keychain
 *@author huwenjun
 *@return
 */
- (void)saveLocalData
{
    NSData *archiveLocalData = [NSKeyedArchiver archivedDataWithRootObject:self.dataModel];//序列化对象
    
    NSString *key=[self getEncryptionKey];
    OpensslUtil *openssl=[OpensslUtil sharedOpensslUtil];
    //利用密钥加密
    NSData *encryptionData=[openssl AESOperation:key encryptFlag:YES data:(unsigned char *)[archiveLocalData bytes] length:[archiveLocalData length]];
    
    [encryptionData writeToFile:[self getCertificationDataPath] atomically:YES];
}

/**
 *生成唯一标识存储在keychian当中
 *@author huwenjun
 *@return 设备唯一标识
 */
- (NSString *)getDeviceIdentity
{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:UUIDIDENTITY accessGroup:nil];
    NSString *imeiStr = [keychainItem objectForKey:(__bridge id)kSecAttrAccount];
    if ([imeiStr isEqualToString:@""])
    {
        int index=0;
        int numberLen=(int)number_Table.length;
        NSMutableString *imei=[NSMutableString string];
        for(int i=0;i<15;i++)//罗：获取前16位数字 -- 生成唯一标识，随机数
        {
            index=abs(arc4random())%numberLen; 
            NSString *imeiChar=[number_Table substringWithRange:NSMakeRange(index, 1)];
            [imei appendString:imeiChar];
        }
        [keychainItem setObject:imei forKey:(__bridge id)kSecAttrAccount];
        imeiStr=(NSString *)imei;
    }
    keychainItem=nil;
    return imeiStr;
}

/**
 *生成sim唯一标识存储在keychian当中
 *@author huwenjun
 *@return sim卡唯一标识
 */
- (NSString *)getSIMIdentity
{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:UUIDIDENTITY accessGroup:nil];
    NSString *imsiStr = [keychainItem objectForKey:(__bridge id)kSecAttrService];
    if ([imsiStr isEqualToString:@""])
    {
        int index=0;
        int numberLen=(int)number_Table.length;
        NSMutableString *imsi=[NSMutableString stringWithString:@"460"];//罗：460开头
        for(int i=0;i<10;i++)
        {
            index=abs(arc4random())%numberLen;
            NSString *imsiChar=[number_Table substringWithRange:NSMakeRange(index, 1)];
            [imsi appendString:imsiChar];
        }
        [keychainItem setObject:imsi forKey:(__bridge id)kSecAttrService];
        imsiStr=(NSString *)imsi;
    }
    keychainItem=nil;
    return imsiStr;
}

/**
 *证书、公私秘钥对、对称密钥等数据序列化后加密保存的文件路径
 *@author huwenjun
 *@return 文件路径
 */
- (NSString *)getCertificationDataPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *certificationDirPath = paths.firstObject;
    NSString *certificationDirPath = [paths objectAtIndex:0];
    //NSString *certificationDirPath=[basePath stringByAppendingPathComponent:@"certification"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //    BOOL isDir = FALSE;
    //    BOOL isDirExist = [fileManager fileExistsAtPath:certificationDirPath isDirectory:&isDir];
    //    if(!(isDirExist && isDir))
    //    {
    //        BOOL createDir = [fileManager createDirectoryAtPath:certificationDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    //        if(!createDir)
    //        {
    //            NSLog(@"Create certification Directory Failed.");
    //        }
    //    }
    NSString *certificationDataPath=[certificationDirPath stringByAppendingPathComponent:[HashTool md532BitLower:[self getDeviceIdentity] FromIndex:0 ToIndex:31]];
    if (![fileManager fileExistsAtPath:certificationDataPath])
    {
        [fileManager createFileAtPath:certificationDataPath contents:nil attributes:nil];
    }
    NSLog(@"certificationDataPath %@",certificationDataPath);
    return certificationDataPath;
}
@end
