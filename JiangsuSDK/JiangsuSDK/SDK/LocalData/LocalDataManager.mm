//
//  LocalDataManager.m
//  JiangsuSDK
//  本地数据管理对象
//  Created by Luo on 16/11/28.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import "LocalDataManager.h"
#import "LocalDataModel.h"
#import "OpensslUtil.h"
#import "ThreeDes.h"




//! 证书路径的前缀，比如：沙盒/jssCerFolder/cert_Admin:cert_Admin为文件名字
static NSString *kCertPathAppend = @"/jssCertFolder/cert_";

@interface LocalDataManager()

//! 数据模型
@property (nonatomic, strong) LocalDataModel *localDataModel;

//! 用户名
@property (nonatomic, copy) NSString *userName;

@end


@implementation LocalDataManager


#pragma mark - 获取单例模式

+ (LocalDataManager *)sharedLocalDataManager
{
    static LocalDataManager *__singleton;
    static dispatch_once_t once;//记住这个也是static，不然后果很严重
    
    dispatch_once(&once, ^{
       
        __singleton = [[LocalDataManager alloc] init];
        

    });
    
    return __singleton;
}



#pragma mark -  初始化

+ (void)initSharedLocalDataManagerWithUserName:(NSString *)userName
{
    LocalDataManager *localDataManager = [LocalDataManager sharedLocalDataManager];    
    localDataManager.userName = userName;
    
    
    NSString *filePath = [localDataManager filePathWithUserName:userName];
    //如果目录存在
    NSFileHandle *handel = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if (handel) {
        
        [handel seekToFileOffset:0];
        //读取出来的数据,反序列化得到模型
        NSData *data = [handel readDataToEndOfFile];
        LocalDataModel *localModel = (LocalDataModel *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        localDataManager.localDataModel = localModel;
    }
}


#pragma mark - 获取模型

+ (LocalDataModel *)getLocalModel
{
    LocalDataManager *localManager = [LocalDataManager sharedLocalDataManager];
    return localManager.localDataModel;
}


//
+ (BOOL)updateLocalDataModel:(LocalDataModel *)localDataModel
{
    LocalDataManager *localManager = [LocalDataManager sharedLocalDataManager];

    //新陈代谢
    localManager.localDataModel = nil;
    localManager.localDataModel = localDataModel;
    
    //使用序列化写入文件
    NSData *modelData = [NSKeyedArchiver archivedDataWithRootObject:localDataModel];
    
    NSString *filePath = [localManager filePathWithUserName:localManager.userName];
    [modelData writeToFile:filePath atomically:YES];
    
    return YES;
}


#pragma mark - 通过文档

- (NSString *)filePathWithUserName:(NSString *)userName
{
    //获取本地沙盒路径
    NSArray *documentsPathArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *document = [documentsPathArr objectAtIndex:0];
    
    //文件的名字，以cert_用户名作为文件名
    NSString *certName = [NSString stringWithFormat:@"%@%@",kCertPathAppend,userName];
    NSString *filePath = [document stringByAppendingPathComponent:certName];
    
    return filePath;
}

+ (NSString *)signDataString:(NSString *)dataString withUserName:(NSString *)userName pin:(NSString *)pin;
{


    LocalDataModel *localDataModel = [LocalDataManager getLocalModel];
    if (localDataModel) {
        
        //通过pin获取证书私钥
        NSString *privateKeyCip = localDataModel.privateKey;
        NSString *thripleKey = [ThreeDes getTripleDesKeyWithUserPin:pin];
        NSString *privateClear = [ThreeDes threeDesDencryotWithKey:thripleKey cipherText:privateKeyCip];
        
        //解密失败-pin错误
        if (!privateClear || [privateClear isEqualToString:@""]) {
            return NULL;
        }
        
        //获取签名算法
        NSString *hashAlg = localDataModel.certHashAlg;
        
        
        OpensslUtil *opensslUtil = [OpensslUtil sharedOpensslUtil];
        //签名过后的数据
        //NSString *signedDataString = [opensslUtil signWithPrivateKey:privateClear data:dataString hashAlg:hashAlg];
        NSString *signedDataString = [opensslUtil signNobase64StrWithPrivateKey:privateClear data:dataString hashAlg:hashAlg];
        
        return signedDataString;
        
    }
    
    return NULL;
}



//! 对哈希值签名
+ (NSString *)signHashString:(NSString *)hashDataString userName:(NSString *)userName pin:(NSString *)pin
{
    LocalDataModel *localDataModel = [LocalDataManager getLocalModel];
    if (localDataModel) {
        
        //通过pin获取证书私钥
        NSString *privateKeyCip = localDataModel.privateKey;
        NSString *thripleKey = [ThreeDes getTripleDesKeyWithUserPin:pin];
        NSString *privateClear = [ThreeDes threeDesDencryotWithKey:thripleKey cipherText:privateKeyCip];
        
        //解密失败-pin错误
        if (!privateClear || [privateClear isEqualToString:@""]) {
            return NULL;
        }
        
        //获取签名算法
        NSString *hashAlg = localDataModel.certHashAlg;
        
        
        OpensslUtil *opensslUtil = [OpensslUtil sharedOpensslUtil];
        //签名过后的数据
        NSString *signedDataString = [opensslUtil signWithPrivateKey:privateClear data:hashDataString hashAlg:hashAlg];
        
        return signedDataString;
        
    }
    
    return NULL;
}




+ (NSString *)getCertNO
{
    LocalDataModel *localDataModel = [LocalDataManager getLocalModel];
    if (!localDataModel) {
        return NULL;
    }
    NSString *certNO = localDataModel.certNO;
    return certNO;
}


//! 检验PIN是否正确
+ (BOOL)verifyPIN:(NSString *)pin
{
    NSString *tripleKey = [ThreeDes getTripleDesKeyWithUserPin:pin];
    LocalDataModel *localDataModel = [LocalDataManager getLocalModel];
    if (!localDataModel) {
        return NO;//本地无证书
    }
    //私钥钥匙
    NSString *clearPrivateKey = [ThreeDes threeDesDencryotWithKey:tripleKey cipherText:localDataModel.privateKey];
    if (!clearPrivateKey) {
        return NO;
    }
    
    //pin正确
    return YES;
    
}





+ (BOOL)verifySignWithCipherText:(NSString *)cipherText clearText:(NSString *)clearText
{

    
    if (!cipherText || [cipherText isEqualToString:@""] || !clearText || [clearText isEqualToString:@""]) {
        return NO;
    }
    LocalDataModel *localDataModel = [LocalDataManager getLocalModel];
    if (!localDataModel) {
        return NO;
    }
    
    //密文
    //UTF8转码成数据
    NSData *cipherUTF8Data = [cipherText dataUsingEncoding:NSUTF8StringEncoding];
    //转成不有bytes数组
    unsigned char *cipherBytes = (unsigned char *)[cipherUTF8Data bytes];
    //求得长度~~~可能位数不对，取定长
    //size_t cipherBytesLen = strlen((char *)cipherBytes);
    int cipherStrLen = (int)cipherText.length;

    
    //原文
    NSData *clearUTF8Data = [clearText dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char *clearBytes = (unsigned char *)[clearUTF8Data bytes];
    //size_t clearBytesLen = strlen((char *)clearBytes);//长度有可能会不确定
    int clearStrLen = (int)clearText.length;//直接以这个为准，固定
    
    //公钥--未解密~~~
    NSString *mPublicKey = localDataModel.publicKey;
    
    //签名算法
    NSString *mSignAlg = localDataModel.certHashAlg;
    
    OpensslUtil *mOpensslUtil = [OpensslUtil sharedOpensslUtil];
    
    BOOL verifyResult = NO;
    if ([mSignAlg isEqualToString:@"sha1"]) {
        verifyResult = [mOpensslUtil verifySha1:mPublicKey data:clearBytes length:clearStrLen signData:cipherBytes length:cipherStrLen];
    }
    else if ([mSignAlg isEqualToString:@"md5"])
    {
        verifyResult = [mOpensslUtil verifymd5:mPublicKey data:clearBytes length:clearStrLen signData:cipherBytes length:clearStrLen];
    }
    else
    {
        verifyResult = NO;
    }
    
    return verifyResult;
    

}




@end
