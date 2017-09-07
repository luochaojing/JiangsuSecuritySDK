//
//  LocalEncryptionDataLogic.h
//  MsspSDK
//  本地加密存储的数据相关方法封装
//  Created by huwenjun on 15-12-14.
//  Copyright (c) 2015年 aspire. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LocalDataModel;
@interface LocalDataLogic : NSObject

/** 本地加密数据对象*/
@property (nonatomic,strong) LocalDataModel *dataModel;

/**
 *本地加密数据管理对象单例方法
 *@author huwenjun
 *@return 对象单例
 */
+ (LocalDataLogic *)sharedLocalData;

/**
 *得到加密序列化文件的对称密钥
 *@author huwenjun
 *@return 对称密钥
 */
- (NSString *)getEncryptionKey;

/**
 *从keychain得到本地保存的序列化对象 然后反序列化
 *@author huwenjun
 *@return 本地数据异常则返回NO 否则返回YES
 */
- (BOOL)getLocalData;

/**
 *将用户信息对象序列化后保存到本地keychain
 *@author huwenjun
 *@return
 */
- (void)saveLocalData;

/**
 *生成唯一标识存储在keychian当中
 *@author huwenjun
 *@return 设备唯一标识
 */
- (NSString *)getDeviceIdentity;

/**
 *生成sim唯一标识存储在keychian当中
 *@author huwenjun
 *@return sim卡唯一标识
 */
- (NSString *)getSIMIdentity;

/**
 *证书、公私秘钥对、对称密钥等数据序列化后加密保存的文件路径
 *@author huwenjun
 *@return 文件路径
 */
- (NSString *)getCertificationDataPath;
@end
