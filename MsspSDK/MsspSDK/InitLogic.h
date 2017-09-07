//
//  InitLogic.h
//  MsspSDK
//  初始化的逻辑检查
//  Created by huwenjun on 15-12-11.
//  Copyright (c) 2015年 aspire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResultHeader.h"

#define SIGNFILENAME @"signFileName"

@interface InitLogic : NSObject

/**
 *检查app是否合法 是否被授权
 *@author huwenjun
 *@return 状态码
 */
+ (ResultCode)checkAppTrust;

/**
 *本地加密数据管理对象单例方法
 *@author huwenjun
 *@return 对象单例
 */
+ (BOOL)checkKeyIsExist;

/**
 *本地加密数据管理对象单例方法
 *@author huwenjun
 *@return 对象单例
 */
+ (ResultCode)checkCertificateIsExist;

@end
