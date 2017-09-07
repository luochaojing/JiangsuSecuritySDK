//
//  InitOperation.m
//  MsspSDK
//  初始化的NSOperation 继承MsspOperation 主要实现初始化api的操作
//  Created by huwenjun on 15-12-26.
//  Copyright (c) 2015年 aspire. All rights reserved.
//

#import "InitOperation.h"
#import "InitLogic.h"
#import "OpensslUtil.h"
#import "LocalDataLogic.h"
#import "LocalDataModel.h"
#import "HTTPSTool.h"
#import "TTMBase64.h"
@implementation InitOperation

/**
 *设置完成回调block
 *@author huwenjun
 *@param block 初始化完成的block
 *@return
 */
- (void)setCompletionWithBlock:(void (^)(InitOperation *operation,ResultCode result))block
{
    [self.lock lock];
    __weak __typeof(self) weakSelf = self;
    
    self.customcompletionBlock = ^
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(weakSelf,weakSelf.resultCode);
            [weakSelf finishOperation];
        });
    };
    [self.lock unlock];
}



/**
 *	@brief	设置请求block
 */
- (void)setRequestBlock
{
    __weak __typeof(self) weakSelf = self;
    self.requestBlock = ^(NSUInteger option){
        
        NSString *version = [NSString stringWithFormat:@"0001"];
        __block LocalDataLogic *localDataLogic=[LocalDataLogic sharedLocalData];
        
        [HTTPSTool applyForCertificateWithURL:weakSelf.msspEndPoint appID:weakSelf.appID token:weakSelf.accessToken version:version oprCode:option phoneNumber:weakSelf.userName dynamicCode:@"" publicKey:localDataLogic.dataModel.userPublicKeyStr succeedBlock:^(NSDictionary *bodyDic) {
            
            if (![bodyDic objectForKey:@"certID"]) {
                //证书ID不存在证书也不存在，则重新请求-- 这不是得一直重复吗？
                [NSThread sleepForTimeInterval:3.0]; //3秒请求一次
                weakSelf.requestBlock(option);
            } else {
                
                //证书ID和证书存在，保存证书ID和证书
                localDataLogic.dataModel.cerID = [bodyDic objectForKey:@"certID"];
                
                //此处从bodyDic中获得的证书是base64编码的证书
                localDataLogic.dataModel.x509CerData = [TTMBase64 decodeString:[bodyDic objectForKey:@"cert"]];
                [localDataLogic saveLocalData];
                
                weakSelf.resultCode=RC_SUCCESS;
                weakSelf.customcompletionBlock();
                NSLog(@"证书ID:%@  证书:%@", [bodyDic objectForKey:@"certID"], [bodyDic objectForKey:@"cert"]);
            }
        } failedBlock:^(ResultCode ret) {
            
            //请求失败
            [localDataLogic saveLocalData];
            weakSelf.resultCode=ret;
            weakSelf.customcompletionBlock();
        }];
    };
}

- (void)requestForCertificate:(int)option
{
    NSString *version = [NSString stringWithFormat:@"0001"];
    __block LocalDataLogic *localDataLogic=[LocalDataLogic sharedLocalData];
    [HTTPSTool applyForCertificateWithURL:self.msspEndPoint appID:self.appID token:self.accessToken version:version oprCode:option phoneNumber:self.userName dynamicCode:@"" publicKey:localDataLogic.dataModel.userPublicKeyStr succeedBlock:^(NSDictionary *bodyDic) {
        NSLog(@"请求成功");
        if (![bodyDic objectForKey:@"cert"]) {
            NSLog(@"证书ID不存在证书也不存在");
            //证书ID存在证书不存在，删除保存的证书
            localDataLogic.dataModel.cerID = [bodyDic objectForKey:@"certID"];
            localDataLogic.dataModel.x509CerData = nil;
            [localDataLogic saveLocalData];
            self.resultCode=RC_SUCCESS;
            self.customcompletionBlock();
        } else {
            
            //证书ID和证书存在，保存证书ID和证书
            localDataLogic.dataModel.cerID = [bodyDic objectForKey:@"certID"];
            
            //此处从bodyDic中获得的证书是base64编码的证书
            localDataLogic.dataModel.x509CerData = [TTMBase64 decodeString:[bodyDic objectForKey:@"cert"]];
            [localDataLogic saveLocalData];
            
            self.resultCode=RC_SUCCESS;
            self.customcompletionBlock();
            NSLog(@"TestMsspSDK 证书ID:%@  证书:%@", [bodyDic objectForKey:@"certID"], [bodyDic objectForKey:@"cert"]);
        }
    } failedBlock:^(ResultCode ret) {
        
        //请求失败
        [localDataLogic saveLocalData];
        self.resultCode=ret;
        self.customcompletionBlock();
    }];
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
        LocalDataLogic *localDataLogic=[LocalDataLogic sharedLocalData];
        [localDataLogic getLocalData];
        BOOL userNameChange=NO;
        if (![localDataLogic.dataModel.userName isEqualToString:self.userName])
        {
            userNameChange=YES;
        }
        localDataLogic.dataModel.appID=self.appID;
        localDataLogic.dataModel.userName=self.userName;
        
        if (![InitLogic checkKeyIsExist])
        {
            NSLog(@"公私密钥对不存在");
            OpensslUtil *openssl=[OpensslUtil sharedOpensslUtil];
            [openssl generateKeyPairRSA:1024 block:^(NSString *publicKey, NSString *privateKey) {
                NSLog(@"TestMsspSDK 生成公私密钥对 publicKey %@ privateKey %@",publicKey,privateKey);
                
                //保存公私密钥对
                localDataLogic.dataModel.userPublicKeyStr = publicKey;
                localDataLogic.dataModel.userPrivateKeyStr = privateKey;
                
                /************申请证书保存证书***********/
                //self.requestBlock(1);
                [self requestForCertificate:1];
                /************************************/
            }];
        }
        else
        {
            NSLog(@"公私密钥对存在,校验证书");
            ResultCode code=[InitLogic checkCertificateIsExist];
            if (code==RC_CERT_NOEXSIST)
            {
                NSLog(@"证书不存在");
                /************请求证书保存证书***********/
                //self.requestBlock(1);
                [self requestForCertificate:1];
                /************************************/
            }
            else if (code==RC_CERT_EXPIRE)
            {
                NSLog(@"证书过期");
                //self.requestBlock(1);
                [self requestForCertificate:1];
            }
            else
            {
                if (userNameChange)
                {
                    [self requestForCertificate:1];
                }
                else
                {
                    [localDataLogic saveLocalData];
                    self.resultCode=code;
                    self.customcompletionBlock();
                }
            }
        }
        
    }
    [self.lock unlock];
}

/*
 ******************block******************
 static void (^block)(void) = ^(void){
 [HTTPSTool applyForCertificateWithURL:self.msspEndPoint appID:self.appID token:self.accessToken version:version oprCode:oprCode phoneNumber:self.userName dynamicCode:@"" publicKey:publicKey succeedBlock:^(NSDictionary *bodyDic) {
 
 if (![bodyDic objectForKey:@"certID"]) {
 //证书ID不存在证书也不存在，则重新请求
 block();
 } else {
 //证书ID和证书存在，保存证书ID和证书
 localDataLogic.dataModel.cerID = [bodyDic objectForKey:@"certID"];
 //此处从bodyDic中获得的证书是base64编码的证书
 localDataLogic.dataModel.x509CerData = [TTMBase64 decodeString:[bodyDic objectForKey:@"cert"]];
 
 //保存公私密钥对
 localDataLogic.dataModel.userPublicKeyStr=publicKey;
 localDataLogic.dataModel.userPrivateKeyStr=privateKey;
 [localDataLogic saveLocalData];
 weakSelf.resultCode=RC_SUCCESS;
 self.completionBlock();
 NSLog(@"cerID:%@  cert:%@", [bodyDic objectForKey:@"certID"], [bodyDic objectForKey:@"cert"]);
 }
 } failedBlock:^(ResultCode ret) {
 //请求失败
 localDataLogic.dataModel.userPublicKeyStr=publicKey;
 localDataLogic.dataModel.userPrivateKeyStr=privateKey;
 [localDataLogic saveLocalData];
 weakSelf.resultCode=ret;
 self.completionBlock();
 }];
 };
 block();
 ***************block*****************
 */


@end
