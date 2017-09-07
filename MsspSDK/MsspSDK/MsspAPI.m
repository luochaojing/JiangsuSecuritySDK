//
//  MsspAPI.m
//  MsspSDK
//  移动安全服务平台安全凭证sdk的接口定义
//  Created by huwenjun on 15-12-10.
//  Copyright (c) 2015年 aspire. All rights reserved.
//

#import "MsspAPI.h"
#import "CoreAPIManage.h"
@implementation MsspAPI

/**
 *初始化sdk
 *@author huwenjun
 *@param accessToken 应用程序通过业务系统代理向移动安全服务平台获取到访问令牌
 *@param appID
 *@param msspEndPoint 移动安全服务平台部署后提供到应用程序访问的服务地址
 *@param debug 当取值为true时是测试环境，不做应用合法性检查
 *@param block 初始化异步回调block 返回初始化结果
 *@return ResultCode  同步返回验签结果状态码
 */
+ (ResultCode)initSDK:(NSString *)accessToken
             userName:(NSString *)userName
                appID:(NSString *)appID
         msspEndPoint:(NSString *)msspEndPoint
          debugEnable:(BOOL)debug
                block:(void(^)(ResultCode code))block
{
    CoreAPIManage *coreAPI=[CoreAPIManage sharedCoreAPIManage];
    ResultCode asyncCode =[coreAPI initSDK:accessToken userName:userName appID:appID msspEndPoint:msspEndPoint debugEnable:debug block:^(ResultCode code) {
        NSLog(@" api block %x",code);
        block(code);
        
    }];
    return asyncCode;
}

/**
 *数据保护 使用平台公钥加密数据
 *@author huwenjun
 *@param userName 用户名
 *@param inputStream 加密输入流
 *@param outputStream 加密输出流
 *@param block 数据保护异步回调block 返回加密结果
 *@return
 */
+ (void)protectData:(NSString *)userName
        inputStream:(NSInputStream *)inputStream
       outputStream:(NSOutputStream *)outputStream
              block:(void(^)(ResultCode code))block
{
    CoreAPIManage *coreAPI=[CoreAPIManage sharedCoreAPIManage];
    [coreAPI protectData:userName inputStream:inputStream outputStream:outputStream block:^(ResultCode code) {
        block(code);
    }];
}

/**
 *加密数据 随机生成iv值和key值 根据iv和key值选择3des或者aes加密
 *@author huwenjun
 *@param userName 用户名
 *@param inputStream 加密输入流
 *@param outputStream 加密输出流
 *@param block 加密数据异步回调block 返回加密结果
 *@return
 */
+ (void)encryptData:(NSString *)userName
        inputStream:(NSInputStream *)inputStream
       outputStream:(NSOutputStream *)outputStream
              block:(void(^)(ResultCode code))block
{
    CoreAPIManage *coreAPI=[CoreAPIManage sharedCoreAPIManage];
    [coreAPI encryptData:userName inputStream:inputStream outputStream:outputStream block:^(ResultCode code) {
        block(code);
    }];
}

/**
 *解密数据 根据随机生成iv值和key值进行3des或者aes解密
 *@author huwenjun
 *@param userName 用户名
 *@param inputStream 解密输入流
 *@param outputStream 解密输出流
 *@param block 解密数据异步回调block 返回解密结果
 *@return
 */
+ (void)decryptData:(NSString *)userName
        inputStream:(NSInputStream *)inputStream
       outputStream:(NSOutputStream *)outputStream
              block:(void(^)(ResultCode code))block
{
    CoreAPIManage *coreAPI=[CoreAPIManage sharedCoreAPIManage];
    [coreAPI decryptData:userName inputStream:inputStream outputStream:outputStream block:^(ResultCode code) {
        block(code);
    }];
}

/**
 *数据签名 根据固定格式对输入的数据用用户私钥签名
 *@author huwenjun
 *@param userName 用户名
 *@param inputStream 签名输入流
 *@param outputStream 签名输出流
 *@param block 签名异步回调block 返回签名结果
 *@return
 */
+ (void)dataSign:(NSString *)userName
     inputStream:(NSInputStream *)inputStream
    outputStream:(NSOutputStream *)outputStream
           block:(void(^)(ResultCode code))block
{
    CoreAPIManage *coreAPI=[CoreAPIManage sharedCoreAPIManage];
    [coreAPI dataSign:userName inputStream:inputStream outputStream:outputStream block:^(ResultCode code) {
        block(code);
    }];
}

/**
 *加密签名 根据固定格式对输入的数据用用户私钥签名 对称加密
 *@author huwenjun
 *@param userName 用户名
 *@param inputStream 加密签名输入流
 *@param outputStream 加密签名输出流
 *@param block 加密签名异步回调block 返回加密签名结果
 *@return
 */
+ (void)encryptDataSign:(NSString *)userName
            inputStream:(NSInputStream *)inputStream
           outputStream:(NSOutputStream *)outputStream
                  block:(void(^)(ResultCode code))block
{
    CoreAPIManage *coreAPI=[CoreAPIManage sharedCoreAPIManage];
    [coreAPI encryptDataSign:userName inputStream:inputStream outputStream:outputStream block:^(ResultCode code) {
        block(code);
    }];
}
@end
