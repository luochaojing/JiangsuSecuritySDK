//
//  SignOperation.m
//  MsspSDK
//
//  Created by huwenjun on 15-12-27.
//  Copyright (c) 2015年 aspire. All rights reserved.
//

#import "SignOperation.h"
#import "LocalDataLogic.h"
#import "LocalDataModel.h"
#import "HashTool.h"
#import "TTMBase64.h"
#import "OpensslUtil.h"
#import "InitLogic.h"
@implementation SignOperation

/**
 *设置完成回调block
 *@author huwenjun
 *@param success 加解密的成功block回调
 *@param failure 加解密的失败block回调
 *@return
 */
- (void)setCompletionBlockWithsuccess:(void (^)(SignOperation *operation))success
                              failure:(void (^)(SignOperation *operation, ResultCode code))failure
{
    [self.lock lock];
    __weak __typeof(self) weakSelf = self;
    self.customcompletionBlock = ^
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.resultCode!=RC_SUCCESS)
            {
                if (failure)
                {
                    failure(weakSelf, weakSelf.resultCode);
                }
            }
            else
            {
                if (success)
                {
                    success(weakSelf);
                }
            }
            [weakSelf finishOperation];
        });
        
    };
    [self.lock unlock];
}

/**
 *NSOperation的具体执行方法
 *@author huwenjun
 *@return
 */
- (void)operationDidStart
{
    [self.lock lock];
    if (![self isCancelled])
    {
        //self.resultCode=[InitLogic checkCertificateIsExist];
        self.resultCode=RC_SUCCESS;
        if (self.resultCode!=RC_SUCCESS)
        {
            self.customcompletionBlock();
        }
        else
        {
            [self.outputStream open];
            NSString *result=[self sign:@"md5"];
            NSData *resultData=[result dataUsingEncoding:NSUTF8StringEncoding];
            unsigned int writeLen = (unsigned int)[resultData length];
            uint8_t writeBuf[writeLen];
            [resultData getBytes:writeBuf range:NSMakeRange(0,writeLen)];
            NSInteger bytesWritten = [self.outputStream write:writeBuf maxLength:sizeof(writeBuf)];
            if (bytesWritten>0)
            {
                self.resultCode=RC_SUCCESS;
            }
            else
            {
                self.resultCode=RC_SYS_UNKOWN;
            }
            [self.outputStream close];
            self.customcompletionBlock();
        }
    }
    [self.lock unlock];
}

/**
 *签名
 *@author huwenjun
 *@param hashAlg hash算法标识
 *@return 返回签名数据
 */
- (NSString *)sign:(NSString *)hashAlg
{
    //拼接签名content
    NSMutableString *content=[[NSMutableString alloc] init];
    LocalDataLogic *localDataLogic=[LocalDataLogic sharedLocalData];
    [localDataLogic getLocalData];
    if (localDataLogic.dataModel.appID)
    {
        [content appendString:localDataLogic.dataModel.appID];
        [content appendString:@"#"];
    }
    if (localDataLogic.dataModel.userName)
    {
        [content appendString:localDataLogic.dataModel.userName];
        [content appendString:@"#"];
    }
    if (localDataLogic.dataModel.deviceIdentity)
    {
        [content appendString:localDataLogic.dataModel.deviceIdentity];
        [content appendString:@"#"];
    }
    if (localDataLogic.dataModel.simIdentity)
    {
        [content appendString:localDataLogic.dataModel.simIdentity];
        [content appendString:@"#"];
    }
    NSString *hashValue=nil;
    SEL hashMenthod=@selector(md5WithInputStream:);//默认使用md5算法
    NSString *signAlgType=nil;
    if ([hashAlg isEqualToString:@"md5"])
    {
        signAlgType=@"00";
        hashMenthod=@selector(md5WithInputStream:);
    }
    else if ([hashAlg isEqualToString:@"sha1"])
    {
        signAlgType=@"01";
        hashMenthod=@selector(sha1WithInputStream:);
    }
    else
    {
        signAlgType=@"02";
        hashMenthod=@selector(sha256WithInputStream:);
    }
    hashValue=(NSString *)[[HashTool class] performSelector:hashMenthod withObject:self.inputStream];
    [content appendString:hashValue];
    
    //拼接签名数据
    NSMutableString *signData=[[NSMutableString alloc] init];
    if (localDataLogic.dataModel.cerID)
    {
        [signData appendString:localDataLogic.dataModel.cerID];
        [signData appendString:@"#"];
    }
    NSInputStream *contentInputStream=[NSInputStream inputStreamWithData:[content dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *hashContent=(NSString *)[[HashTool class] performSelector:hashMenthod withObject:contentInputStream];
    [signData appendString:hashContent];
    
    //拼接结果
    NSMutableString *resultData=[[NSMutableString alloc] init];
    if (localDataLogic.dataModel.cerID)
    {
        [resultData appendString:localDataLogic.dataModel.cerID];
        [resultData appendString:@"#"];
    }
    [resultData appendString:signAlgType];
    [resultData appendString:@"#"];
    OpensslUtil *openssl=[OpensslUtil sharedOpensslUtil];
    NSString *signAlgData= [openssl sign:localDataLogic.dataModel.userPrivateKeyStr data:signData hashAlg:hashAlg];
    //[openssl verify:localDataLogic.dataModel.userPublicKeyStr data:signData signData:signAlgData];
    [resultData appendString:signAlgData];
    return resultData;
}


@end
