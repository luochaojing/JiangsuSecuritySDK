//
//  RSAOperation.m
//  MsspSDK
//  非对称加密的NSOperation 继承MsspOperation 主要实现数据保护api的操作
//  Created by huwenjun on 15-12-21.
//  Copyright (c) 2015年 aspire. All rights reserved.
//

#import "RSAOperation.h"
#import "OpensslUtil.h"
#import "TTMBase64.h"

static unsigned int  RSAEncryptBlockSize=117; //128-11
static unsigned int  RSADecryptBlockSize=128;

@implementation RSAOperation

/**
 *设置完成回调block
 *@author huwenjun
 *@param success 加解密的成功block回调
 *@param failure 加解密的失败block回调
 *@return
 */
- (void)setCompletionBlockWithsuccess:(void (^)(RSAOperation *operation))success
                              failure:(void (^)(RSAOperation *operation, ResultCode resultCode))failure
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
        while (YES)
        {
            unsigned int readBlock=0;
            if (self.model==RSAEncryption)
            {
                readBlock = RSAEncryptBlockSize;
            }
            else
            {
                readBlock = RSADecryptBlockSize;
            }
            uint8_t readBuf[readBlock];
            unsigned int readLen = 0;
            readLen = (unsigned int)[self.inputStream read:readBuf maxLength:readBlock];
            if (readLen>0)
            {
                readcount++;//片数
                
                readindex+=readLen;//字符数
                
                NSData *data=[[NSData alloc] initWithBytes:readBuf length:readLen];
                NSMutableData *mutilRedata=[NSMutableData data];
                if (self.model==RSAEncryption)
                {
                    NSLog(@"开始加密%d字节,总共加密%d字节,第%d加密 ",readLen,readindex,readcount);
                    if (readcount!=1)
                    {
                        NSLog(@"不是第一次加密，前面加$符号");
                        [mutilRedata appendData:DATA(@"$")];
                    }
                    NSData *encodeData=[TTMBase64 encodeData:[opensslUtil encryptionByRSA:self.userPublicKeyRef data:readBuf length:readLen]];
                    [mutilRedata appendData:encodeData];
                }
                else
                {
                    //由于分段加密用$分隔开 这里解密不适用
                    NSLog(@"开始解密%d字节,总共解密%d字节,第%d解密 ",readLen,readindex,readcount);
                    mutilRedata=[NSMutableData dataWithData:[TTMBase64 decodeData:[opensslUtil decryptionByRSA:self.userPrivateKeyRef data:readBuf length:readLen]]];
                }
                data=nil;
                if ([mutilRedata length]==0)
                {
                    [self setResultCodeInfo];
                    break;
                }
                
                unsigned int writeLen = (unsigned int)[mutilRedata length];
                uint8_t writeBuf1[writeLen];
                [mutilRedata getBytes:writeBuf1 range:NSMakeRange(0,writeLen)];
                NSInteger bytesWritten = [self.outputStream write:writeBuf1 maxLength:sizeof(writeBuf1)];
                if (bytesWritten>0)
                {
                    writeindex+=bytesWritten;
                    if (self.model==RSAEncryption)
                    {
                        NSLog(@"加密出了%d字节,总共加密出了%d字节",(int)bytesWritten,(int)writeindex);
                    }
                    else
                    {
                        NSLog(@"解密出了%d字节,总共解密出了%d字节",(int)bytesWritten,(int)writeindex);
                    }
                    
                }
                else
                {
                    [self setResultCodeInfo];
                    break;
                }
            }
            else
            {
                NSLog(@"出错或结束字节%d 总共加密%d字节",readLen,readindex);
                if (self.inputStream.streamError)
                {
                    self.error=self.inputStream.streamError;
                    [self setResultCodeInfo];
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
    if (self.model==RSAEncryption)
    {
        self.resultCode=RC_USER_ENCRYPTERROR;
    }
    else
    {
        self.resultCode=RC_USER_DECRYPTERROR;
    }
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
//        [self.inputStream open];
//        [self.outputStream open];
//        unsigned int readindex=0,writeindex=0;
//        unsigned int readcount=0;
//        while (YES)
//        {
//            unsigned int readBlock=0;
//            if (self.model==RSAEncryption)
//            {
//                readBlock = RSAEncryptBlockSize;
//            }
//            else
//            {
//                readBlock = RSADecryptBlockSize;
//            }
//            uint8_t readBuf[readBlock];
//            unsigned int readLen = 0;
//            readLen = [self.inputStream read:readBuf maxLength:readBlock];
//            if (readLen>0)
//            {
//                readcount++;
//
//                readindex+=readLen;
//
//                NSData *data=[[NSData alloc] initWithBytes:readBuf length:readLen];
//                NSData *resultData=nil;
//                if (self.model==RSAEncryption)
//                {
//                    NSLog(@"开始加密%d字节,总共加密%d字节,第%d加密 ",readLen,readindex,readcount);
//                    resultData=[self encryptionByRSA:self.userPublicKeyRef1 data:data];
//                }
//                else
//                {
//                    NSLog(@"开始解密%d字节,总共解密%d字节,第%d解密 ",readLen,readindex,readcount);
//                    resultData = [self decryptionByRSA:self.userPrivateKeyRef1 data:data];
//                }
//                data=nil;
//                unsigned int writeLen = [resultData length];
//                uint8_t writeBuf[writeLen];
//                [resultData getBytes:writeBuf range:NSMakeRange(0,writeLen)];
//                NSInteger bytesWritten = [self.outputStream write:writeBuf maxLength:sizeof(writeBuf)];
//                if (bytesWritten>0)
//                {
//                    writeindex+=bytesWritten;
//                    if (self.model==RSAEncryption)
//                    {
//                        NSLog(@"加密出了%d字节,总共加密出了%d字节",bytesWritten,writeindex);
//                    }
//                    else
//                    {
//                        NSLog(@"解密出了%d字节,总共解密出了%d字节",bytesWritten,writeindex);
//                    }
//                }
//                else
//                {
//                    if (self.outputStream.streamError)
//                    {
//                        self.error=self.outputStream.streamError;
//                    }
//                    break;
//                }
//            }
//            else
//            {
//                NSLog(@"出错或结束字节%d 总共加密%d字节",readLen,readindex);
//                if (self.inputStream.streamError)
//                {
//                    self.error=self.inputStream.streamError;
//                }
//                break;
//            }
//        }
//        [self.inputStream close];
//        [self.outputStream close];
//        self.completionBlock();
//
//    }
//    [self.lock unlock];
//}

///**
// *使用公钥对数据进行加密
// *@author huwenjun
// *@param publicKey RSA加密的公钥
// *@param data RSA加密的数据对象
// *@return 加密后的数据
// */
//- (NSMutableData *)encryptionByRSA:(SecKeyRef)publicKey data:(NSData *)data
//{
//    // 分配内存块，用于存放加密后的数据段
//    size_t cipherBufferSize = SecKeyGetBlockSize(publicKey);
//    uint8_t *cipherBuffer = malloc(cipherBufferSize * sizeof(uint8_t));
//    double totalLength = [data length];
//    size_t blockSize = cipherBufferSize - 12;
//    size_t blockCount = (size_t)ceil(totalLength / blockSize);
//    NSMutableData *encryptedData = [NSMutableData data];
//    // 分段加密
//    for (int i = 0; i < blockCount; i++)
//    {
//        NSUInteger loc = i * blockSize;
//        // 数据段的实际大小。最后一段可能比blockSize小。
//        //int dataSegmentRealSize = MIN(blockSize, [plainData length] - loc);
//        int dataSegmentRealSize=(int)(blockSize>([data length] - loc)?([data length] - loc):blockSize);
//        // 截取需要加密的数据段
//        NSData *dataSegment = [data subdataWithRange:NSMakeRange(loc, dataSegmentRealSize)];
//        OSStatus status = SecKeyEncrypt(publicKey, kSecPaddingPKCS1, (const uint8_t *)[dataSegment bytes], dataSegmentRealSize, cipherBuffer, &cipherBufferSize);
//        if (status == errSecSuccess)
//        {
//            NSData *encryptedDataSegment = [[NSData alloc] initWithBytes:(const void *)cipherBuffer length:cipherBufferSize];
//            // 追加加密后的数据段
//            [encryptedData appendData:encryptedDataSegment];
//            encryptedDataSegment=nil;
//        }
//        else
//        {
//            if (cipherBuffer)
//            {
//                free(cipherBuffer);
//            }
//            return nil;
//        }
//    }
//    if (cipherBuffer)
//    {
//        free(cipherBuffer);
//    }
//    return encryptedData;
//}
//
///**
// *使用私钥对数据进行解密
// *@author huwenjun
// *@param privateKey RSA解密的私钥
// *@param data RSA加密的数据对象
// *@return 解密后的数据
// */
//- (NSMutableData *)decryptionByRSA:(SecKeyRef)privateKey data:(NSData *)data
//{
//    // 分配内存块，用于存放解密后的数据段
//    size_t plainBufferSize = SecKeyGetBlockSize(privateKey);
//    uint8_t *plainBuffer = malloc(plainBufferSize * sizeof(uint8_t));
//    // 计算数据段最大长度及数据段的个数
//    int totalLength = [data length];
//    size_t blockSize = plainBufferSize;
//    size_t blockCount = (size_t)ceil(totalLength / blockSize);
//    NSMutableData *decryptedData = [NSMutableData data];
//    // 分段解密
//    for (int i = 0; i < blockCount; i++)
//    {
//        NSUInteger loc = i * blockSize;
//        // 数据段的实际大小。最后一段可能比blockSize小。
//        int dataSegmentRealSize = MIN(blockSize, totalLength - loc);
//        // 截取需要解密的数据段
//        NSData *dataSegment = [data subdataWithRange:NSMakeRange(loc, dataSegmentRealSize)];
//        OSStatus status = SecKeyDecrypt(privateKey, kSecPaddingPKCS1, (const uint8_t *)[dataSegment bytes], dataSegmentRealSize, plainBuffer, &plainBufferSize);
//        if (status == errSecSuccess)
//        {
//            NSData *decryptedDataSegment = [[NSData alloc] initWithBytes:(const void *)plainBuffer length:plainBufferSize];
//            [decryptedData appendData:decryptedDataSegment];
//            decryptedDataSegment=nil;
//        }
//        else
//        {
//            if (plainBuffer)
//            {
//                free(plainBuffer);
//            }
//            return nil;
//        }
//    }
//    if (plainBuffer)
//    {
//        free(plainBuffer);
//    }
//    return decryptedData;
//}

@end

