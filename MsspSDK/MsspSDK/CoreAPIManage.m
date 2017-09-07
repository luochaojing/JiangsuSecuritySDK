//
//  CoreAPIManage.m
//  MsspSDK
//  sdk的api调度管理对象 所有api以多线程队列的方式实现 以block方式异步返回结果
//  Created by huwenjun on 15-12-22.
//  Copyright (c) 2015年 aspire. All rights reserved.
//

#import "CoreAPIManage.h"
#import "RSAOperation.h"
#import "SymmetricOperation.h"
#import "InitLogic.h"
#import "InitOperation.h"
#import "MsspPublicKey.h"
#import "SymmetricUtil.h"
#import "LocalDataLogic.h"
#import "LocalDataModel.h"
#import "SignOperation.h"
#import "EncodeSignOperation.h"

@interface CoreAPIManage()

/**调度操作队列 */
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation CoreAPIManage

/**
 *对外api的核心调度管理类
 *@author huwenjun
 *@return 对象单例
 */
+ (CoreAPIManage *)sharedCoreAPIManage
{
    static CoreAPIManage *__singletion;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __singletion=[[self alloc] init];
    });
    return __singletion;
}

- (instancetype)init
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.operationQueue.maxConcurrentOperationCount=5;
    self.initResult=RC_SYS_CALLINVALID;
    self.checkResult=RC_APP_UNTRUST;
    return self;
}

/**
 *SDK开放api初始化方法的实现方法
 *@author huwenjun
 *@param accessToken 用户传入的token
 *@param userName 用户传入的userName
 *@param appID 用户传入的appID
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
{
    ResultCode syncCode=RC_SUCCESS;
    if (!debug)
    {
        //不是调试环境则验签
        syncCode=[InitLogic checkAppTrust];
    }
    __weak __block __typeof(self) weakSelf = self;
    [self InitOperationWith:appID userName:userName msspEndPoint:msspEndPoint accessToken:accessToken block:^(InitOperation *operation, ResultCode result) {
        NSLog(@"core api block code %x",result);
        weakSelf.initResult=result;
        block(RC_SUCCESS);
    }];
    self.checkResult=syncCode;
    return syncCode;
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
- (void)protectData:(NSString *)userName
        inputStream:(NSInputStream *)inputStream
       outputStream:(NSOutputStream *)outputStream
              block:(void(^)(ResultCode code))block
{
    if (self.checkResult==RC_SUCCESS)
    {
//        LocalDataLogic *localData=[LocalDataLogic sharedLocalData];
//        [localData getLocalData];
        [self RSAEncryptOperation:inputStream outputStream:outputStream publicKey:MSSP_PUBLICKEY success:^(RSAOperation *operation) {
            block(RC_SUCCESS);
        } failure:^(RSAOperation *operation, ResultCode code) {
            block(code);
        }];
    }
    else
    {
        block(RC_APP_UNTRUST);
    }
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
- (void)encryptData:(NSString *)userName
        inputStream:(NSInputStream *)inputStream
       outputStream:(NSOutputStream *)outputStream
              block:(void(^)(ResultCode code))block
{
    if (self.checkResult==RC_SUCCESS)
    {
        SymmetricUtil *symmetric=[SymmetricUtil sharedSymmetricUtil];
        NSString *key=[symmetric genLocalEncryptKey];
        NSLog(@"本地加密对称密钥:%@", key);//罗：如何保存对称密钥？写在代码还是？
        LocalDataLogic *localDataLogic=[LocalDataLogic sharedLocalData];
        if (![localDataLogic getLocalData]) {
            block(RC_SYS_CALLINVALID);
        } else {
            [localDataLogic.dataModel setLocalSymmetricKeyStr:key];
            [localDataLogic saveLocalData];
            [self symmetricEncryptOperation:inputStream outputStream:outputStream symmetricKey:localDataLogic.dataModel.localSymmetricKeyStr success:^(SymmetricOperation *operation) {
                block(RC_SUCCESS);
            } failure:^(SymmetricOperation *operation, ResultCode resultCode) {
                block(resultCode);
            }];
        }
    }
    else
    {
        block(RC_APP_UNTRUST);
    }
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
- (void)decryptData:(NSString *)userName
        inputStream:(NSInputStream *)inputStream
       outputStream:(NSOutputStream *)outputStream
              block:(void(^)(ResultCode code))block
{
    if (self.checkResult==RC_SUCCESS)
    {
        LocalDataLogic *localDataLogic=[LocalDataLogic sharedLocalData];
        if (![localDataLogic getLocalData]) {
            block(RC_SYS_CALLINVALID);
        } else {
            [self symmetricDecryptOperation:inputStream outputStream:outputStream symmetricKey:localDataLogic.dataModel.localSymmetricKeyStr success:^(SymmetricOperation *operation) {
                block(RC_SUCCESS);
            } failure:^(SymmetricOperation *operation, ResultCode resultCode) {
                block(resultCode);
            }];
        }
    }
    else
    {
        block(RC_APP_UNTRUST);
    }
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
- (void)dataSign:(NSString *)userName
     inputStream:(NSInputStream *)inputStream
    outputStream:(NSOutputStream *)outputStream
           block:(void(^)(ResultCode code))block
{
    if (self.initResult==RC_SUCCESS)
    {
        LocalDataLogic *localData=[LocalDataLogic sharedLocalData];
        if (![localData getLocalData]) {
            block(RC_SYS_CALLINVALID);
        } else {
            [self signOperation:inputStream outputStream:outputStream success:^(SignOperation *operation) {
                block(RC_SUCCESS);
            } failure:^(SignOperation *operation, ResultCode code) {
                block(code);
            }];
        }
    }
    else
    {
        block(RC_SYS_CALLINVALID);
    }
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
- (void)encryptDataSign:(NSString *)userName
            inputStream:(NSInputStream *)inputStream
           outputStream:(NSOutputStream *)outputStream
                  block:(void(^)(ResultCode code))block
{
    if (self.initResult==RC_SUCCESS)
    {
        LocalDataLogic *localDataLogic=[LocalDataLogic sharedLocalData];
        if (![localDataLogic getLocalData]) {
            block(RC_SYS_CALLINVALID);
        } else {
            SymmetricUtil *symmetric=[SymmetricUtil sharedSymmetricUtil];
            NSString *key=[symmetric genSignAESKey];
            [localDataLogic.dataModel setSignSymmetricKeyStr:key];
            [localDataLogic saveLocalData];
            NSLog(@"加密签名的对称密钥:%@", key);
            [self encodeSignOperation:inputStream outputStream:outputStream symmetricKey:key success:^(EncodeSignOperation *operation) {
                block(RC_SUCCESS);
            } failure:^(EncodeSignOperation *operation, ResultCode code) {
                block(code);
            }];
        }
    }
    else
    {
        block(RC_SYS_CALLINVALID);
    }
}




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
                               block:(void (^)(InitOperation *operation,ResultCode result))finish
{
    InitOperation *operation = [[InitOperation alloc] init];
    [operation setAppID:appID];
    [operation setUserName:userName];
    [operation setMsspEndPoint:msspEndPoint];
    [operation setAccessToken:accessToken];
    [operation setCompletionWithBlock:finish];
    [operation setRequestBlock];
    [self.operationQueue addOperation:operation];
    return operation;
}


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
                              failure:(void (^)(RSAOperation *operation, ResultCode code))failure
{
    RSAOperation *operation = [[RSAOperation alloc] init];
    [operation setInputStream:inputStream];
    [operation setOutputStream:outputStream];
    [operation setModel:RSAEncryption];
    [operation setUserPublicKeyRef:publicKeyRef];
    [operation setCompletionBlockWithsuccess:success failure:failure];
    [self.operationQueue addOperation:operation];
    return operation;
}

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
                              failure:(void (^)(RSAOperation *operation, ResultCode code))failure
{
    RSAOperation *operation = [[RSAOperation alloc] init];
    [operation setInputStream:inputStream];
    [operation setOutputStream:outputStream];
    [operation setModel:RSADecryption];
    [operation setUserPrivateKeyRef:privateKeyRef];
    [operation setCompletionBlockWithsuccess:success failure:failure];
    [self.operationQueue addOperation:operation];
    return operation;
}

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
{
    SymmetricOperation *operation = [[SymmetricOperation alloc] init];
    [operation setInputStream:inputStream];
    [operation setOutputStream:outputStream];
    [operation setModel:Encryption];
    [operation setSymmetricKey:symmetricKey];
    [operation setCompletionBlockWithsuccess:success failure:failure];
    [self.operationQueue addOperation:operation];
    return operation;
}

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
                                          failure:(void (^)(SymmetricOperation *operation, ResultCode resultCode))failure
{
    SymmetricOperation *operation = [[SymmetricOperation alloc] init];
    [operation setInputStream:inputStream];
    [operation setOutputStream:outputStream];
    [operation setModel:Decryption];
    [operation setSymmetricKey:symmetricKey];
    [operation setCompletionBlockWithsuccess:success failure:failure];
    [self.operationQueue addOperation:operation];
    return operation;
}

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
                         failure:(void (^)(SignOperation *operation, ResultCode code))failure
{
    SignOperation *operation = [[SignOperation alloc] init];
    [operation setInputStream:inputStream];
    [operation setOutputStream:outputStream];
    [operation setCompletionBlockWithsuccess:success failure:failure];
    [self.operationQueue addOperation:operation];
    return operation;
}

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
                                     failure:(void (^)(EncodeSignOperation *operation, ResultCode code))failure
{
    EncodeSignOperation *operation = [[EncodeSignOperation alloc] init];
    [operation setInputStream:inputStream];
    [operation setOutputStream:outputStream];
    [operation setSymmetricKey:symmetricKey];
    [operation setCompletionBlockWithsuccess:success failure:failure];
    [self.operationQueue addOperation:operation];
    return operation;
}
@end
