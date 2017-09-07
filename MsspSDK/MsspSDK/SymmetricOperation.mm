//
//  AESOperation.m
//  TestMssp
//  对称加密的NSOperation 继承MsspOperation 主要实现本地数据加解密api的操作
//  Created by huwenjun on 15-12-25.
//  Copyright (c) 2015年 aspire. All rights reserved.
//

#import "SymmetricOperation.h"
#import "OpensslUtil.h"
#import "TTMBase64.h"



static unsigned int symmetricBlockSize=1024;

@implementation SymmetricOperation

/**
 *设置完成回调block
 *@author huwenjun
 *@param success 加解密的成功block回调
 *@param failure 加解密的失败block回调
 *@return
 */
- (void)setCompletionBlockWithsuccess:(void (^)(SymmetricOperation *operation))success
                              failure:(void (^)(SymmetricOperation *operation, ResultCode resultCode))failure
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
        OpensslUtil *opensslUtil=[OpensslUtil sharedOpensslUtil];
        [self.inputStream open];
        [self.outputStream open];
        unsigned int readindex=0,writeindex=0;
        unsigned int readcount=0;
        switch (self.model) {
            case Encryption:
            {
                [opensslUtil symmetricOperationInit:self.symmetricKey encryptFlag:YES];
            }
                break;
            case Decryption:
            {
                [opensslUtil symmetricOperationInit:self.symmetricKey encryptFlag:NO];
            }
                break;
            default:
                break;
        }
        
        while (YES)
        {
            uint8_t readBuf[symmetricBlockSize];
            unsigned int readLen = 0;
            readLen = (unsigned int)[self.inputStream read:readBuf maxLength:symmetricBlockSize];
            if (readLen>0)
            {
                readcount++;
                
                readindex+=readLen;
                NSData *reData=nil;
                if (self.model==Encryption)
                {
                    NSLog(@"开始加密%d字节,总共加密%d字节,第%d加密 ",readLen,readindex,readcount);
                    reData=[opensslUtil symmetricOperationUpdate:readBuf length:readLen encryptFlag:YES];
                }
                else
                {
                    NSLog(@"开始解密%d字节,总共解密%d字节,第%d解密 ",readLen,readindex,readcount);
                    reData=[opensslUtil symmetricOperationUpdate:readBuf length:readLen encryptFlag:NO];
                }
                if ([reData length]!=0)
                {
                    unsigned int writeLen = (unsigned int)[reData length];
                    uint8_t writeBuf1[writeLen];
                    [reData getBytes:writeBuf1 range:NSMakeRange(0,writeLen)];
                    NSInteger bytesWritten = [self.outputStream write:writeBuf1 maxLength:sizeof(writeBuf1)];
                    if (bytesWritten>0)
                    {
                        writeindex+=bytesWritten;
                        if (self.model==Encryption)
                        {
                            NSLog(@"加密出了%d字节,总共加密出了%d字节",(int)bytesWritten,writeindex);
                        }
                        else
                        {
                            NSLog(@"解密出了%d字节,总共解密出了%d字节",(int)bytesWritten,writeindex);
                        }
                    }
                    else
                    {
                        [self setResultCodeInfo];
                        break;
                    }
                }
            }
            else
            {
                
                NSLog(@"出错或结束字节%d 总共%d字节",readLen,readindex);
                if (self.inputStream.streamError)
                {
                    [self setResultCodeInfo];
                    break;
                }
                else
                {
                    NSLog(@"调用finishe");
                    NSData *paddingData=nil;
                    if (self.model==Encryption)
                    {
                        paddingData=[opensslUtil symmetricOperationFinishe:YES];
                    }
                    else
                    {
                        paddingData=[opensslUtil symmetricOperationFinishe:NO];
                    }
                    
                    if (self.model==Encryption)
                    {
                        if ([paddingData length]==0)
                        {
                            [self setResultCodeInfo];
                            break;
                        }
                    }
                    else
                    {
                        if ([paddingData length]==0 && writeindex%16 != 0)
                        {
                            [self setResultCodeInfo];
                            break;
                        }
                    }
                    
                    unsigned int writeLen = (unsigned int)[paddingData length];
                    uint8_t writeBuf[writeLen];
                    [paddingData getBytes:writeBuf range:NSMakeRange(0,writeLen)];
                    NSInteger bytesWritten = [self.outputStream write:writeBuf maxLength:sizeof(writeBuf)];
                    if (bytesWritten>0)
                    {
                        if (self.model==Encryption)
                        {
                            NSLog(@"加密padding偏移为%d字节",(int)bytesWritten);
                        }
                        else
                        {
                            NSLog(@"解密出了%d字节",(int)bytesWritten);
                        }
                    }
                    else
                    {
                        if (self.outputStream.streamError)
                        {
                            [self setResultCodeInfo];
                        }
                        break;
                    }
                }
                break;
            }
        }
        [self.inputStream close];
        [self.outputStream close];
        self.customcompletionBlock();
        
    }
    [self.lock unlock];
}


- (void)setResultCodeInfo
{
    if (self.model==Encryption)
    {
        self.resultCode=RC_USER_ENCRYPTERROR;
    }
    else
    {
        self.resultCode=RC_USER_DECRYPTERROR;
    }
}
@end
