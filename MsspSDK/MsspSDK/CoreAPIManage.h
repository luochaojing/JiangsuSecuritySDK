//
//  CoreAPIManage.h
//  MsspSDK
//  sdk的api调度管理对象 所有api以多线程队列的方式实现 以block方式异步返回结果
//  Created by huwenjun on 15-12-22.
//  Copyright (c) 2015年 aspire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import "ResultHeader.h"

@class RSAOperation,SymmetricOperation,InitOperation,SignOperation,EncodeSignOperation;

@interface CoreAPIManage : NSObject

/**初始化异步返回的结果 */
@property (nonatomic,assign) ResultCode initResult;

/**初始化验签的结果 */
@property (nonatomic,assign) ResultCode checkResult;


/**
 *对外api的核心调度管理类
 *@author huwenjun
 *@return 对象单例
 */
+ (CoreAPIManage *)sharedCoreAPIManage;

#pragma 对外api实现区

/**
 *SDK开放api初始化方法的实现方法
 *@author huwenjun
 *@param accessToken 用户传入的token
 *@param appID 用户传入的appID
 *@param userName 用户传入的userName
 *@param msspEndPoint 用户传入的url
 *@param debug 是否是调试模式
 *@param block 异步检查返回的状态
 *@return 同步返回验签结果
 */
- (ResultCode)initSDK:(NSString *)accessToken
             userName:(NSString *)userName
                appID:(NSString *)appID
         msspEndPoint:(NSString *)msspEndPoint
          debugEnable:(BOOL)debug
                block:(void(^)(ResultCode code))block;


/**
 *数据保护 使用平台公钥加密数据
 *@author huwenjun
 *@param userName 用户名
 *@param inputStream 加密输入流
 *@param outputStream 加密输出流
 *@param block 数据保护异步回调block 返回加密结果
 *@return
 */
- (void)protectData:(NSString *)userName
        inputStream:(NSInputStream *)inputStream
       outputStream:(NSOutputStream *)outputStream
              block:(void(^)(ResultCode code))block;

/**
 *加密数据 随机生成iv值和key值 根据iv和key值选择3des或者aes加密
 *@author huwenjun
 *@param userName 用户名
 *@param inputStream 加密输入流
 *@param outputStream 加密输出流
 *@param block 加密数据异步回调block 返回加密结果
 *@return
 */
- (void)encryptData:(NSString *)userName
        inputStream:(NSInputStream *)inputStream
       outputStream:(NSOutputStream *)outputStream
              block:(void(^)(ResultCode code))block;

/**
 *解密数据 根据随机生成iv值和key值进行3des或者aes解密
 *@author huwenjun
 *@param userName 用户名
 *@param inputStream 解密输入流
 *@param outputStream 解密输出流
 *@param block 解密数据异步回调block 返回解密结果
 *@return
 */
- (void)decryptData:(NSString *)userName
        inputStream:(NSInputStream *)inputStream
       outputStream:(NSOutputStream *)outputStream
              block:(void(^)(ResultCode code))block;

/**
 *数据签名 根据固定格式对输入的数据用用户私钥签名
 *@author huwenjun
 *@param userName 用户名
 *@param inputStream 签名输入流
 *@param outputStream 签名输出流
 *@param block 签名异步回调block 返回签名结果
 *@return
 */
- (void)dataSign:(NSString *)userName
     inputStream:(NSInputStream *)inputStream
    outputStream:(NSOutputStream *)outputStream
           block:(void(^)(ResultCode code))block;

/**
 *加密签名 根据固定格式对输入的数据用用户私钥签名 对称加密
 *@author huwenjun
 *@param userName 用户名
 *@param inputStream 加密签名输入流
 *@param outputStream 加密签名输出流
 *@param block 加密签名异步回调block 返回加密签名结果
 *@return
 */
- (void)encryptDataSign:(NSString *)userName
            inputStream:(NSInputStream *)inputStream
           outputStream:(NSOutputStream *)outputStream
                  block:(void(^)(ResultCode code))block;

#pragma - 操作NSOperation生成区
/**
 *生成初始化的NSOperation对象
 *@author huwenjun
 *@param appID 用户传入的appid参数
 *@param userName 用户传入的userName参数 是电话号码
 *@param accessToken 用户传入的token
 *@param msspEndPoint 用户传入的url
 *@param finish 初始化完成的回调block
 *@return 初始化的NSOperation对象
 */
- (InitOperation *)InitOperationWith:(NSString *)appID
                            userName:(NSString *)userName
                        msspEndPoint:(NSString *)msspEndPoint
                         accessToken:(NSString *)accessToken
                               block:(void (^)(InitOperation *operation,ResultCode result))finish;

/**
 *生成RSA加密的NSOperation对象
 *@author huwenjun
 *@param inputStream RSA加密输入流
 *@param outputStream RSA加密输出流
 *@param publicKeyRef RSA加密公钥
 *@param success RSA加密成功完成的回调block
 *@param failure RSA加密失败完成的回调block
 *@return RSA加密的NSOperation对象
 */
- (RSAOperation *)RSAEncryptOperation:(NSInputStream *)inputStream
                         outputStream:(NSOutputStream *)outputStream
                            publicKey:(NSString *)publicKeyRef
                              success:(void (^)(RSAOperation *operation))success
                              failure:(void (^)(RSAOperation *operation, ResultCode code))failure;

/**
 *生成RSA解密的NSOperation对象
 *@author huwenjun
 *@param inputStream RSA解密输入流
 *@param outputStream RSA解密输出流
 *@param publicKeyRef RSA解密私钥
 *@param success RSA解密成功完成的回调block
 *@param failure RSA解密失败完成的回调block
 *@return RSA加密的NSOperation对象
 */
- (RSAOperation *)RSADecryptOperation:(NSInputStream *)inputStream
                         outputStream:(NSOutputStream *)outputStream
                           privateKey:(NSString *)privateKeyRef
                              success:(void (^)(RSAOperation *operation))success
                              failure:(void (^)(RSAOperation *operation, ResultCode code))failure;

/*生成对称加密的NSOperation对象
 *@author huwenjun
 *@param inputStream 对称加密输入流
 *@param outputStream 对称加密输出流
 *@param symmetricKey 对称加密密钥
 *@param success 对称加密成功完成的回调block
 *@param failure 对称加密失败完成的回调block
 *@return 对称加密的NSOperation对象
 */
- (SymmetricOperation *)symmetricEncryptOperation:(NSInputStream *)inputStream
                                     outputStream:(NSOutputStream *)outputStream
                                     symmetricKey:(NSString *)symmetricKey
                                          success:(void (^)(SymmetricOperation *operation))success
                                          failure:(void (^)(SymmetricOperation *operation, ResultCode resultCode))failure;

/**
 *生成对称解密的NSOperation对象
 *@author huwenjun
 *@param inputStream 对称解密输入流
 *@param outputStream 对称解密输出流
 *@param symmetricKey 对称解密密钥
 *@param success 对称解密成功完成的回调block
 *@param failure 对称解密失败完成的回调block
 *@return 对称解密的NSOperation对象
 */
- (SymmetricOperation *)symmetricDecryptOperation:(NSInputStream *)inputStream
                                     outputStream:(NSOutputStream *)outputStream
                                     symmetricKey:(NSString *)symmetricKey
                                          success:(void (^)(SymmetricOperation *operation))success
                                          failure:(void (^)(SymmetricOperation *operation, ResultCode resultCode))failure;

/**
 *生成签名的NSOperation对象
 *@author huwenjun
 *@param inputStream 签名输入流
 *@param outputStream 签名输出流
 *@param success 签名成功完成的回调block
 *@param failure 签名失败完成的回调block
 *@return 签名的NSOperation对象
 */
- (SignOperation *)signOperation:(NSInputStream *)inputStream
                    outputStream:(NSOutputStream *)outputStream
                         success:(void (^)(SignOperation *operation))success
                         failure:(void (^)(SignOperation *operation, ResultCode code))failure;

/**
 *生成加密签名的NSOperation对象
 *@author huwenjun
 *@param inputStream 加密签名输入流
 *@param outputStream 加密签名输出流
 *@param symmetricKey 对称加密密钥
 *@param success 加密签名成功完成的回调block
 *@param failure 加密签名失败完成的回调block
 *@return 加密签名的NSOperation对象
 */
- (EncodeSignOperation *)encodeSignOperation:(NSInputStream *)inputStream
                                outputStream:(NSOutputStream *)outputStream
                                symmetricKey:(NSString *)symmetricKey
                                     success:(void (^)(EncodeSignOperation *operation))success
                                     failure:(void (^)(EncodeSignOperation *operation, ResultCode code))failure;
@end
