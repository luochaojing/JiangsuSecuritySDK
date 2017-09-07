//
//  InitLogic.m
//  MsspSDK
//  初始化的逻辑检查
//  Created by huwenjun on 15-12-11.
//  Copyright (c) 2015年 aspire. All rights reserved.
//

#import "InitLogic.h"
#import "LocalDataLogic.h"
#import "LocalDataModel.h"
#import "RSAUtil.h"
#import "OpensslUtil.h"
#import <objc/runtime.h>
@implementation InitLogic

/**
 *检查app是否合法 是否被授权
 *@author huwenjun
 *@return 状态码
 */
+ (ResultCode)checkAppTrust
{
//    //读取并解密验签文件
//    NSString *signFilePath = [[NSBundle mainBundle] pathForResource:SIGNFILENAME ofType:nil];
//    
//    NSData *signData=[NSData dataWithContentsOfFile:signFilePath];
//    /************获取验签解密密钥***********/
//    NSString *key=nil;
//    /************************************/
//    OpensslUtil *openssl=[OpensslUtil sharedOpensslUtil];
//    NSData *decodeSignData=[openssl AESOperation:key encryptFlag:NO data:(unsigned char *)[signData bytes] length:[signData length]];
//    /************获取签名文件的bundleID值***********/
//    NSString *registerIdentifier=nil;
//    /************************************/
//    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    ResultCode code=RC_SUCCESS;
//    if([identifier isEqualToString:registerIdentifier])
//    {
//        code=RC_SUCCESS;
//    }
//    else
//    {
//        code=RC_APP_UNTRUST;
//    }
    return code;
}

/**
 *本地加密数据管理对象单例方法
 *@author huwenjun
 *@return 对象单例
 */
+ (BOOL)checkKeyIsExist
{
    //读取公私密钥对是否存在
    BOOL exist=NO;
    LocalDataLogic *dataLogic=[LocalDataLogic sharedLocalData];
    if (dataLogic.dataModel&&dataLogic.dataModel.userPublicKeyStr&&dataLogic.dataModel.userPrivateKeyStr)
    {
        //公私密钥对存在
        exist=YES;
    }
    return exist;
}

/**
 *本地加密数据管理对象单例方法
 *@author huwenjun
 *@return 对象单例
 */
+ (ResultCode)checkCertificateIsExist
{
    //读取x509证书是否存在
    ResultCode code=RC_CERT_NOEXSIST;
    LocalDataLogic *dataLogic=[LocalDataLogic sharedLocalData];
    OpensslUtil *openssl=[OpensslUtil sharedOpensslUtil];
    if (dataLogic.dataModel&&dataLogic.dataModel.x509CerData&&[dataLogic.dataModel.x509CerData length]!=0)
    {
        //x509证书存在 验证可信度
        NSDate *expireData=[openssl checkCertExpire:dataLogic.dataModel.x509CerData];
        NSDate *nowData=[NSDate date];
        NSTimeInterval timeInterval= [expireData timeIntervalSinceDate:nowData];
        if (timeInterval>0)
        {
            code=RC_SUCCESS;
        }
        else
        {
            code=RC_CERT_EXPIRE;
        }
    }
    return code;
}
@end
