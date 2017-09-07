//
//  CertApplyOperation.m
//  JiangsuSDK
//
//  Created by Luo on 16/12/7.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import "CertApplyOperation.h"

#import "OpensslUtil.h"

#import "JSSNetworking.h"
#import "JSSCommon.h"
#import "LocalDataManager.h"

#import "ThreeDes.h"
#import "ServerAddressManager.h"

@implementation CertApplyOperation



- (void)operationDidStart
{
    [self.lock lock];
    if (![self isCancelled]) {
        
        //生成RSA密钥对
        
        DebugLog(@"开始产生密钥对");
        
        OpensslUtil *opensslUtil = [OpensslUtil sharedOpensslUtil];
        NSDictionary *keysDic = [opensslUtil generateKeyDicRSAWithKeyLength:1024];
        NSString *publicKey = keysDic[@"publicKey"];
        NSString *privateKey = keysDic[@"privateKey"];
        
        
        if (!publicKey || !privateKey) {
            //生成密钥串失败
            self.erorrBlock(EC_GEN_KEY_ERROR);
            [self finishOpertion];

            return;
        }
        DebugLog(@"产生密钥对成功!");
        
        //判断参数是否为空
        if (self.transactionID
            && self.userName
            && self.verifyCode
            && self.imei
            && self.pesName
            && self.cardType
            && self.cardNO
            && self.mobileNO
            && self.userType
            && self.pin
            ) {
            
        }
        else
        {
            //参数为空
            self.erorrBlock(EC_PARA_ERROR);
            [self finishOpertion];

            return;
        }
        
        //拷贝用于网络线程里的参数
        __block NSString *blockPrivateKey = [NSString stringWithFormat:@"%@",privateKey];
        __block NSString *blockUserName = [NSString stringWithFormat:@"%@",self.userName];
        __block NSString *blockPin = [NSString stringWithFormat:@"%@",self.pin];
        
        
        
        //! 参数字典
        NSMutableDictionary *paraDic = [[NSMutableDictionary alloc] init];
        
        [paraDic setObject:self.transactionID forKey:@"transactionID"];
        [paraDic setObject:self.userName forKey:@"userName"];
        [paraDic setObject:self.verifyCode forKey:@"verifyCode"];
        [paraDic setObject:publicKey forKey:@"publicKey"];
        [paraDic setObject:self.imei forKey:@"imei"];
        [paraDic setObject:self.pesName forKey:@"pesName"];
        [paraDic setObject:[NSNumber numberWithInteger:self.cardType] forKey:@"cardType"];
        [paraDic setObject:self.cardNO forKey:@"cardNO"];
        [paraDic setObject:self.mobileNO forKey:@"mobileNO"];
        [paraDic setObject:[NSNumber numberWithInteger:self.userType] forKey:@"userType"];
        
        
        //文档里写的加上token，不对的，不要token
        NSString *clearText = [NSString stringWithFormat:@"%@%@%@%@%@%@%ld%@%@%ld",self.transactionID,
                               self.userName,
                               self.verifyCode,
                               publicKey,
                               self.imei,
                               self.pesName,
                               self.cardType,//ld
                               self.cardNO,
                               self.mobileNO,
                               self.userType];//ld
        NSString *hmac = [JSSCommon HMACMD5WithClearText:clearText];
        [paraDic setObject:hmac forKey:@"hmac"];
        
        
        NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
        [requestDic setObject:paraDic forKey:@"para"];
        [requestDic setObject:@"ApplyCertReq" forKey:@"messageName"];
        

        //发起请求
        NSString *url = [ServerAddressManager getURLwithPortName:jApplyCert];//jPostURL(jApplyCert);
        [JSSNetworking postWithURL:url token:self.token infoDict:requestDic successBlock:^(id data) {
            
            //解析字典
            NSDictionary *returnDic = data;
            NSDictionary *paraDic = [returnDic objectForKey:@"para"];
            
            //返回的标识码
            NSString *returnCode = [paraDic objectForKey:@"returnCode"];
            if ([returnCode isEqualToString:@"001"]) {
                
                //token校验失败
                self.erorrBlock(EC_TOKENERROR);
                [self finishOpertion];

            }
            else if ([returnCode isEqualToString:@"002"])
            {
                //hma校验失败
                self.erorrBlock(EC_HMAC_VERIFY_ERROR);
                [self finishOpertion];

            }
            else if ([returnCode isEqualToString:@"003"])
            {
                //短信验证码失败
                self.erorrBlock(EC_SMS_INVALID);
                [self finishOpertion];

            }
            else if ([returnCode isEqualToString:@"004"])
            {
                //未知名错误
                self.erorrBlock(EC_FAILURE);
                [self finishOpertion];

            }
            else if ([returnCode isEqualToString:@"000"])
            {
                
                
                //成功拿回证书
                NSString *certificate = [paraDic objectForKey:@"certificate"];
                //在这里解析证书
                
                [LocalDataManager initSharedLocalDataManagerWithUserName:self.userName];
                LocalDataModel *localDataModel = [[LocalDataModel alloc] init];
                localDataModel.userName = blockUserName;
                
                //以pin算出3DES密钥，再用3des加密私钥
                NSString *tripleKey = [ThreeDes getTripleDesKeyWithUserPin:blockPin];
                NSString *tripleCipherPrivateKey = [ThreeDes threeDesEncrypttWithKey:tripleKey clearText:blockPrivateKey];
                localDataModel.privateKey = tripleCipherPrivateKey;
                localDataModel.publicKey = publicKey;
                //打印证书+密钥对                
                
                OpensslUtil *opensslU = [OpensslUtil sharedOpensslUtil];
                localDataModel.certNO = [opensslU x509SerialNumWithDataString:certificate];
                localDataModel.certHashAlg = [opensslU getHashAlgWithCertDataString:certificate];
                localDataModel.cert = certificate;
                
                //存入本地
                [LocalDataManager updateLocalDataModel:localDataModel];
                
                self.successBlock();
                
                [self finishOpertion];
                
            }
            
        } errorBlock:^(NSError *error) {
            
            //网络不给力
            self.erorrBlock(EC_NETWORK_UNACCESS);
            [self finishOpertion];

            
        }];
        
    }
    [self.lock unlock];
}


//线程停止
- (void)finishOpertion
{
    [self.lock lock];
    
    [self willChangeValueForKey:@"isExecuting"];
    self.excute = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self willChangeValueForKey:@"isFinished"];
    self.finish = YES;
    [self didChangeValueForKey:@"isFinished"];
    
    [self.lock unlock];
}


@end
