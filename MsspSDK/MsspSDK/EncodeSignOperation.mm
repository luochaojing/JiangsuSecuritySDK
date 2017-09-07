//
//  EncodeSignOperation.m
//  MsspSDK
//
//  Created by huwenjun on 16-1-2.
//  Copyright (c) 2016年 aspire. All rights reserved.
//

#import "EncodeSignOperation.h"
#import "InitLogic.h"
#import "OpensslUtil.h"
#import "MsspPublicKey.h"
#import "TTMBase64.h"
#import "LocalDataLogic.h"
#import "LocalDataModel.h"
#import "HashTool.h"

@implementation EncodeSignOperation
static unsigned int symmetricBlockSize=1024;

/**
 *设置完成回调block
 *@author huwenjun
 *@param success 加解密的成功block回调
 *@param failure 加解密的失败block回调
 *@return
 */
- (void)setCompletionBlockWithsuccess:(void (^)(EncodeSignOperation *operation))success
                              failure:(void (^)(EncodeSignOperation *operation, ResultCode code))failure
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

///**
// *NSOperation的具体执行方法
// *@author huwenjun
// *@return
// */
//- (void)operationDidStart
//{
//    [self.lock lock];
//    if (![self isCancelled])
//    {
//        self.resultCode=[InitLogic checkCertificateIsExist];
//        if (self.resultCode!=RC_SUCCESS)
//        {
//            self.completionBlock();
//        }
//        else
//        {
//            [self.inputStream open];
//            [self.outputStream open];
//            LocalDataLogic *localDataLogic=[LocalDataLogic sharedLocalData];
//            OpensslUtil *opensslUtil=[OpensslUtil sharedOpensslUtil];
//            [opensslUtil symmetricOperationInit:self.symmetricKey encryptFlag:YES];
//            unsigned int readcount=0;
//            NSMutableData *signInputData=[NSMutableData data];
//            BOOL largeData=NO;
//            while (YES)
//            {
//                uint8_t readBuf[symmetricBlockSize];
//                unsigned int readLen = 0;
//                readLen = (unsigned int)[self.inputStream read:readBuf maxLength:symmetricBlockSize];
//                readcount+=readLen;
//                if (readcount>MAXENCODESIGN)
//                {
//                    largeData=YES;
//                    break;
//                }
//                if (readLen>0)
//                {
//                    NSData *data=[[NSData alloc] initWithBytes:readBuf length:readLen];
//                    [signInputData appendData:data];
//                }
//                else
//                {
//                    break;
//                }
//             }
//             if(largeData)
//             {
//                 self.resultCode= RC_SYS_MAXLARGE;
//                 self.completionBlock();
//             }
//             else
//             {
//                 unsigned char *signInputChar = (unsigned char *)[signInputData bytes];
//                 NSData *encodeData=[opensslUtil AESOperation:self.symmetricKey encryptFlag:YES data:signInputChar length:[signInputData length]];
//                 NSData *encodeData_base64=[GTMBase64 encodeData:encodeData];
//
//                 NSData *signData=[opensslUtil signData:localDataLogic.dataModel.userPrivateKeyStr data:signInputChar length:(int)[signInputData length] hashAlg:@"md5"];
//
//                 unsigned char *signOutputChar = (unsigned char *)[signData bytes];
//                 [opensslUtil verify:localDataLogic.dataModel.userPublicKeyStr data:signInputChar length:(int)[signInputData length] signData:signOutputChar length:(int)[signData length]];
//                 //NSData *signData_base64=[GTMBase64 encodeData:signData];
//
//                 NSData *keyData=[self.symmetricKey dataUsingEncoding:NSUTF8StringEncoding];
//                 unsigned char *keyDataChar = (unsigned char *)[keyData bytes];
//                 NSData *encodeKeydata =[opensslUtil encryptionByRSA:MSSP_PUBLICKEY data:keyDataChar length:[keyData length]];
//                 NSData *encodeKeyData_base64=[GTMBase64 encodeData:encodeKeydata];
//
//                 NSMutableData *resultData=[[NSMutableData alloc] init];
//                 [resultData appendData:encodeKeyData_base64];
//                 [resultData appendData:DATA(@"$")];
//                 [resultData appendData:encodeData_base64];
//                 [resultData appendData:DATA(@"$")];
//                 [resultData appendData:signData];
//
//                 unsigned int writeLen = (unsigned int)[resultData length];
//                 unsigned int totalWrite=0;
//                 int writeCount=0;
//                 while (YES)
//                 {
//                     if (writeLen-totalWrite>0)
//                     {
//                         unsigned int writeBlock=MIN(symmetricBlockSize, writeLen-totalWrite);
//                         uint8_t writeBuf[writeBlock];
//                         [resultData getBytes:writeBuf range:NSMakeRange(totalWrite,writeBlock)];
//                         writeCount++;
//                         NSLog(@"读取第%d次，每次1024个字节 总共%d",writeCount,totalWrite);
//                         NSInteger bytesWritten = [self.outputStream write:writeBuf maxLength:sizeof(writeBuf)];
//                         if (bytesWritten<0)
//                         {
//                             self.resultCode=RC_SYS_UNKOWN;
//                             break;
//                         }
//                         else
//                         {
//                             totalWrite+=bytesWritten;
//                         }
//                     }
//                     else
//                     {
//                         self.resultCode=RC_SUCCESS;
//                         break;
//                     }
//                 }
//                 self.completionBlock();
//             }
//
//        }
//    }
//    [self.lock unlock];
//}


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
            [self.inputStream open];
            [self.outputStream open];
            
            //rsa加密密钥 并写入流
            OpensslUtil *opensslUtil=[OpensslUtil sharedOpensslUtil];
            NSData *keyData=[self.symmetricKey dataUsingEncoding:NSUTF8StringEncoding];
            unsigned char *keyDataChar = (unsigned char *)[keyData bytes];
            NSData *encodeKeydata =[opensslUtil encryptionByRSA:MSSP_PUBLICKEY data:keyDataChar length:[keyData length]];
            NSData *encodeKeyData_base64=[TTMBase64 encodeData:encodeKeydata];
            NSString *str=[[NSString alloc] initWithData:encodeKeyData_base64 encoding:NSUTF8StringEncoding];
            NSLog(@"TestMsspSDK rsa加密密钥结果:%@",str);
            if (![self writeToSteam:encodeKeyData_base64])
            {
                self.resultCode= RC_SYS_UNKOWN;
                self.customcompletionBlock();
                return;
            }
            
            //$分隔符写入流
            if (![self writeToSteam:DATA(@"$")])
            {
                self.resultCode= RC_SYS_UNKOWN;
                self.customcompletionBlock();
                return;
            }
            
            
            //分段对称加密初始化上下文
            [opensslUtil symmetricOperationInit:self.symmetricKey encryptFlag:YES];
            /*******分段计算md5值初始化上下文********/
            HashTool *hashTool = [HashTool sharedHashTool];
            [hashTool md5Init];
            NSString *hashValue=nil;
            /*************************/
            
            unsigned int readcount=0;
            BOOL largeData=NO;
            NSMutableData *encodeInputData=[NSMutableData data];
            
            while (YES)
            {
                uint8_t readBuf[symmetricBlockSize];
                unsigned int readLen = 0;
                readLen = (unsigned int)[self.inputStream read:readBuf maxLength:symmetricBlockSize];
                readcount+=readLen;
                if (readcount>MAXENCODESIGN)
                {
                    largeData=YES;
                    break;
                }
                if(readLen>0)
                {
                    
                    //分段对称加密
                    NSData *reData=[opensslUtil symmetricOperationUpdate:readBuf length:readLen encryptFlag:YES];
                    [encodeInputData appendData:reData];
                    //NSData *reData_base64=[GTMBase64 encodeData:reData];
                    //                    if (![self writeToSteam:reData_base64])
                    //                    {
                    //                        self.resultCode= RC_SYS_UNKOWN;
                    //                        self.completionBlock();
                    //                        return;
                    //                    }
                    /*******分段计算md5值********/
                    [hashTool md5UpdateWithBuffer:readBuf Length:readLen];
                    /*************************/
                }
                else
                {
                    if (self.inputStream.streamError)
                    {
                        self.error=self.inputStream.streamError;
                    }
                    else
                    {
                        //NSLog(@"调用分段加密finishe");
                        NSData  *paddingData=[opensslUtil symmetricOperationFinishe:YES];
                        [encodeInputData appendData:paddingData];
                        //                        NSData *paddingData_base64=[GTMBase64 encodeData:paddingData];
                        //                        if (![self writeToSteam:paddingData_base64])
                        //                        {
                        //                            self.resultCode= RC_SYS_UNKOWN;
                        //                            self.completionBlock();
                        //                            return;
                        //                        }
                        /*******结束计算md5值********/
                        hashValue=[hashTool md5Final];
                        /*************************/
                    }
                    break;
                }
            }
            
            if(largeData)
            {
                self.resultCode= RC_SYS_MAXLARGE;
                self.customcompletionBlock();
            }
            else
            {
                NSData  *encodeInputData_base64=[TTMBase64 encodeData:encodeInputData];
                //对称加密结果写入流
                if (![self writeToSteam:encodeInputData_base64])
                {
                    self.resultCode= RC_SYS_UNKOWN;
                    self.customcompletionBlock();
                    return;
                }
                
                //$分隔符写入流
                if (![self writeToSteam:DATA(@"$")])
                {
                    self.resultCode= RC_SYS_UNKOWN;
                    self.customcompletionBlock();
                    return;
                }
                
                NSString *signStr=[self sign:hashValue];
                //NSLog(@"hashValue:%@", hashValue);
                //签名值写入流
                if (![self writeToSteam:DATA(signStr)])
                {
                    self.resultCode= RC_SYS_UNKOWN;
                    self.customcompletionBlock();
                    return;
                }
            }
            
            [self.inputStream close];
            [self.outputStream close];
            self.customcompletionBlock();
        }
    }
    [self.lock unlock];
}

- (BOOL)writeToSteam:(NSData *)data
{
    BOOL result=NO;
    unsigned int writeLen = (unsigned int)[data length];
    uint8_t writeBuf[writeLen];
    [data getBytes:writeBuf range:NSMakeRange(0,writeLen)];
    NSInteger bytesWritten = [self.outputStream write:writeBuf maxLength:sizeof(writeBuf)];
    if (bytesWritten>0)
    {
        NSLog(@"写入流输出%d个字节",(int)bytesWritten);
        result=YES;
    }
    else
    {
        NSLog(@"写入流输出错误");
        result=NO;
    }
    return result;
}
/**
 *签名
 *@author huwenjun
 *@param hashAlg hash算法标识
 *@return 返回签名数据
 */
- (NSString *)sign:(NSString *)hashValue
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
    
    [content appendString:hashValue];
    
    //拼接签名数据
    NSMutableString *signData=[[NSMutableString alloc] init];
    if (localDataLogic.dataModel.cerID)
    {
        [signData appendString:localDataLogic.dataModel.cerID];
        [signData appendString:@"#"];
    }
    NSLog(@"TestMsspSDK 签名content:%@", content);
    NSInputStream *contentInputStream=[NSInputStream inputStreamWithData:[content dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *hashContent=[HashTool md5WithInputStream:contentInputStream];
    [signData appendString:hashContent];
    NSLog(@"TestMsspSDK 签名数据signData:%@", signData);
    //拼接结果
    NSMutableString *resultData=[[NSMutableString alloc] init];
    if (localDataLogic.dataModel.cerID)
    {
        [resultData appendString:localDataLogic.dataModel.cerID];
        [resultData appendString:@"#"];
    }
    [resultData appendString:@"00#"];
    
    OpensslUtil *openssl=[OpensslUtil sharedOpensslUtil];
    NSString *signAlgData= [openssl sign:localDataLogic.dataModel.userPrivateKeyStr data:signData hashAlg:@"md5"];
    [resultData appendString:signAlgData];
    NSLog(@"TestMsspSDK resultData:%@", resultData);
    return resultData;
}
@end
