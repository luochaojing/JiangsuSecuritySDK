//
//  DocSignOperation.m
//  JiangsuSDK
//
//  Created by Luo on 16/12/8.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import "DocSignOperation.h"
#import "JSSNetworking.h"
#import "JSSCommon.h"
#import "LocalDataManager.h"
#import "ServerAddressManager.h"


@implementation DocSignOperation


//1.获取哈希值  2.读取密钥对hash签名 3.发请求
- (void)operationDidStart
{

    [self.lock lock];
    if (![self isCancelled]) {

        
        NSString *transactionID = [JSSCommon getTransactionID];
    
        //参数字典
        NSMutableDictionary *paraDic = [[NSMutableDictionary alloc] init];
        [paraDic setObject:transactionID forKey:@"transactionID"];
        [paraDic setObject:self.docID forKey:@"docID"];
        [paraDic setObject:self.certNO forKey:@"certNO"];
        [paraDic setObject:[NSNumber numberWithInteger:self.positionType] forKey:@"positionType"];
        [paraDic setObject:self.positionValue forKey:@"positionValue"];
        [paraDic setObject:[NSNumber numberWithInteger:self.pageValue] forKey:@"pageValue"];//文档是value，是num？
        [paraDic setObject:self.userName forKey:@"userName"];
    
        //这个原文注意跟文档确认，文档有误。
        NSString *clearText = [NSString stringWithFormat:@"%@%@%@%@%ld%@%ld",
                           transactionID,self.docID,self.certNO,self.userName,self.positionType,self.positionValue,self.pageValue
                           ];
        NSString *hmac = [JSSCommon HMACMD5WithClearText:clearText];
    
        [paraDic setObject:hmac forKey:@"hmac"];
    
        
        //请求字典
        NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
        [requestDic setObject:paraDic forKey:@"para"];
        [requestDic setObject:@"GetDocumentHashReq" forKey:@"messageName"];
    
        
        //发起请求
        NSString *getDocumentHashURL = [ServerAddressManager getURLwithPortName:jGetDocumentHash];//jPostURL(jGetDocumentHash);
        [JSSNetworking postWithURL:getDocumentHashURL token:self.token infoDict:requestDic successBlock:^(id data) {
           
            //这里应该做一个强引用，不然回来的时候没了，不过，线程在队列里不主动结束他，是会一直存在的吧
            
            NSDictionary *returnDic = data;
            NSDictionary *paraDic = [returnDic objectForKey:@"para"];
            NSNumber *returnCodeNum = [paraDic objectForKey:@"returnCode"];
            NSInteger returnCodeInt = [returnCodeNum integerValue];
            
            
            //成功哈希值
            if (returnCodeInt == 0) {
                //成功
                NSString *hash = [paraDic objectForKey:@"hash"];

                if (hash && ![hash isEqualToString:@""]) {
                    //发起签章请求
                    
                    NSString *transactionID = [JSSCommon getTransactionID];
                    
                    //调用私钥对sign进行签名
                    NSString *signValue = [LocalDataManager signHashString:hash userName:self.userName pin:self.pin];
                    if (!signValue) {
                        self.errorBlock(EC_RSASIGN_FALURE);
                        return;
                    }                    
                    
                    //~~~~~~~~~对签名进行验证~~~~~~~~~
                    if (![LocalDataManager verifySignWithCipherText:signValue clearText:hash]) {
                        //self.errorBlock(EC_RSASIGN_FALURE);
                        //return;
                    }
                    
                    
                    NSString *clearText = [NSString stringWithFormat:@"%@%@%@%@%@%ld%@%ld",transactionID,self.docID,self.certNO,signValue,self.userName,self.positionType,self.positionValue,self.pageValue];
                    NSString *hmac = [JSSCommon HMACMD5WithClearText:clearText];
                    
                    //参数字典
                    NSMutableDictionary *paraDic = [[NSMutableDictionary alloc] init];
                    [paraDic setObject:transactionID forKey:@"transactionID"];
                    [paraDic setObject:self.docID forKey:@"docID"];
                    [paraDic setObject:self.certNO forKey:@"certNO"];
                    [paraDic setObject:signValue forKey:@"signValue"];
                    [paraDic setObject:self.userName forKey:@"userName"];
                    [paraDic setObject:[NSNumber numberWithInteger:self.positionType] forKey:@"positionType"];
                    [paraDic setObject:self.positionValue forKey:@"positionValue"];
                    [paraDic setObject:[NSNumber numberWithInteger:self.pageValue] forKey:@"pageValue"];
                    [paraDic setObject:hmac forKey:@"hmac"];
                    [paraDic setObject:self.todoID forKey:@"todoID"];
                    //请求字典
                    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
                    [requestDic setObject:paraDic forKey:@"para"];
                    [requestDic setObject:@"SignDocumentReq" forKey:@"messageName"];
                    
                    
                    //发起请求
                    NSString *signDocumentURL = [ServerAddressManager getURLwithPortName:jSignDocument]; //jPostURL(jSignDocument);
                    [JSSNetworking postWithURL:signDocumentURL token:self.token infoDict:requestDic successBlock:^(id data) {
                        
                        //解析返回字典
                        NSDictionary *returnDic = data;
                        NSDictionary *paraDic = [returnDic objectForKey:@"para"];
                        NSNumber *returnCodeNum = [paraDic objectForKey:@"returnCode"];
                        NSInteger returnCodeInt = [returnCodeNum integerValue];
                        
                        if (returnCodeInt == 0) {
                            
                            //成功--结束
                            self.successBlock();
                            [self finishOpertion];

                            
                        }
                        else if (returnCodeInt == 1)
                        {
                            //hmac错误
                            self.errorBlock(EC_HMAC_VERIFY_ERROR);
                            [self finishOpertion];

                        }
                        else if (returnCodeInt == 2)
                        {
                            //token
                            self.errorBlock(EC_TOKENERROR);
                            [self finishOpertion];
                            
                        }
                        else if (returnCodeInt == 3)
                        {
                            //签章失败：其他错误-可能是其他参数错误？文档不存在呢？
                            self.errorBlock(EC_SERVER_SIGN_FAILURE);
                            [self finishOpertion];

                        }
                        else
                        {
                            //其他错误
                            self.errorBlock(EC_SERVER_FAILURE);
                            [self finishOpertion];

                        }
                        
                        
                    } errorBlock:^(NSError *error) {
                        
                        //网络不给力
                        self.errorBlock(EC_NETWORK_UNACCESS);
                        [self finishOpertion];

                    }];
                }
                else
                {
                    //hash值为空或者不存在
                    self.errorBlock(EC_GET_HASH_ERROR);
                    [self finishOpertion];
                }
                
                
                
                
            }
            else if (returnCodeInt == 1)
            {
                //hmac错误
                self.errorBlock(EC_HMAC_VERIFY_ERROR);
                [self finishOpertion];

                
            }
            else if (returnCodeInt == 2)
            {
                //token错误
                self.errorBlock(EC_TOKENERROR);
                [self finishOpertion];

            }
            else if (returnCodeInt == 3)
            {
                //文档不存在
                self.errorBlock(EC_NOPDF);
                [self finishOpertion];

            }
            else if (returnCodeInt == 4)
            {
                //获取哈希值失败
                self.errorBlock(EC_GET_HASH_ERROR);
                [self finishOpertion];

            }
            else
            {
                //其他
                self.errorBlock(EC_SERVER_FAILURE);
                [self finishOpertion];

            }
            
            
        } errorBlock:^(NSError *error) {
            
            //网络不给力哦
            self.errorBlock(EC_NETWORK_UNACCESS);
            [self finishOpertion];
        }];

    }
    [self.lock unlock];
}


- (void)cancel
{
    [self.lock lock];
    //?
    if (![self isFinished] && ![self isCancelled])
    {
        [super cancel];
        //如果是网络请求，线程取消是否要对其网络请求取消？
    }
    [self.lock unlock];
}

@end
