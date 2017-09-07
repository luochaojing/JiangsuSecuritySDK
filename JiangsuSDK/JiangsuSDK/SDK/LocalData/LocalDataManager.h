//
//  LocalDataManager.h
//  JiangsuSDK
//  本地数据管理
//  Created by Luo on 16/11/28.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LocalDataModel.h"

@interface LocalDataManager : NSObject

//！获取单例模式,获取之后是一个空值，需要使用userName对其进行初始化
+ (LocalDataManager *)sharedLocalDataManager;


//! 初始化之后才会去读取数据
+ (void)initSharedLocalDataManagerWithUserName:(NSString *)userName;


//! 请事先初始化,提供的是个副本防止被修改。为了防止手里持有的和原本一样，请每次使用都调用一次
+ (LocalDataModel *)getLocalModel;


/**
 *  更新证书：用于新申请的证书，写入硬盘
 *
 *  @param localDataModel 证书模型
 *
 *  @return 更新成功
 */
+ (BOOL)updateLocalDataModel:(LocalDataModel *)localDataModel;



/**
 *  返回签名串
 *
 *  @param dataString 原文
 *  @param userName   用户名
 *  @param pin        pin
 *
 *  @return 签名之后的数据
 */
+ (NSString *)signDataString:(NSString *)dataString withUserName:(NSString *)userName pin:(NSString *)pin;

+ (NSString *)signHashString:(NSString *)hashDataString userName:(NSString *)userName pin:(NSString *)pin;

//验证
+ (BOOL)verifySignWithCipherText:(NSString *)cipherText clearText:(NSString *)clearText;



/**
 *  获取证书的ID，请先初始化
 *
 *  @return 证书ID
 */
+ (NSString *)getCertNO;


/**
 *  检查pin是否正确：使用pin解密私钥，能解密就是正确。本地无证书也返回NO
 *
 *  @param pin pin
 *
 *  @return pin是否正确
 */
+ (BOOL)verifyPIN:(NSString *)pin;






@end
