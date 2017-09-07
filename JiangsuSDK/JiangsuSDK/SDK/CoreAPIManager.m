//
//  CoreAPIManager.m
//  JiangsuSDK
//
//  Created by Luo on 16/11/24.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import "CoreAPIManager.h"
#import "HttpRequestOperation.h"
#import "JSSCommon.h"
#import "DocSignOperation.h"
#import <UIKit/UIKit.h>

static NSInteger MaxConcurrentOperationCount = 20;

@implementation CoreAPIManager
{
    //! 多线程队列
    NSOperationQueue *_operationQueue;
}


#pragma mark - 单例初始化

+ (CoreAPIManager *)sharedCoreAPIManager
{
    static CoreAPIManager *_coreAPIManager = nil;
    static dispatch_once_t onceToken;
   
    dispatch_once(&onceToken, ^{
       
        _coreAPIManager = [[self alloc] init];
    });
    
    return _coreAPIManager;
}


- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _operationQueue = [[NSOperationQueue alloc] init];
    _operationQueue.maxConcurrentOperationCount = MaxConcurrentOperationCount;
    
    return self;
}


#pragma mark - HTTP请求线程

- (HttpRequestOperation *)postHttpRequestWithRUL:(NSString *)urlStr
                                           token:(NSString *)token
                                      requestDic:(NSDictionary *)requestDic
                                    successBlock:(void (^)(id data))successBlock
                                      errorBlock:(void (^)(NSError *error))errorBlock

{
    HttpRequestOperation *httpOperation = [[HttpRequestOperation alloc] init];
    httpOperation.urlStr = urlStr;
    httpOperation.token = token;
    httpOperation.requestDic = requestDic;
    httpOperation.successBlock = successBlock;
    httpOperation.errorBlock = errorBlock;
    
    [_operationQueue addOperation:httpOperation];
    return httpOperation;
}


#pragma mark - 证书申请线程

- (CertApplyOperation *)certApplyWithToken:(NSString *)token
                                       pin:(NSString *)pin
                                  userName:(NSString *)userName
                                verifyCode:(NSString *)verifyCode
                                   pesName:(NSString *)pesName
                                  cardType:(CardType)cardType
                                    cardNO:(NSString *)cardNO
                                  mobileNO:(NSString *)mobileNO
                                  userType:(CertUserType)userType
                              successBlock:(void (^)())successBlock
                                errorBlock:(void (^)(ResultCode))errorBlock
{
    CertApplyOperation *certApplyOperation = [[CertApplyOperation alloc] init];
    
    //传递参数--不可为空
    certApplyOperation.token = token;
    certApplyOperation.pin = pin;
    certApplyOperation.transactionID = [JSSCommon getTransactionID];
    certApplyOperation.userName = userName;
    certApplyOperation.verifyCode = verifyCode;
    certApplyOperation.imei = [JSSCommon getIMEI];
    certApplyOperation.pesName = pesName;
    certApplyOperation.cardType = cardType;
    certApplyOperation.cardNO = cardNO;
    certApplyOperation.mobileNO = mobileNO;
    certApplyOperation.userType = userType;
    
    certApplyOperation.successBlock = successBlock;
    certApplyOperation.erorrBlock = errorBlock;
    
    //加入线程管理
    [_operationQueue addOperation:certApplyOperation];
    
    return certApplyOperation;
}




- (void)docSignWithDocID:(NSString *)docID
                userName:(NSString *)userName
                     pin:(NSString *)pin
                  certNO:(NSString *)certNO
                   token:(NSString *)token
                  todoID:(NSString *)todoID
           positionArray:(NSArray *)positionArray
            successBlock:(void(^)())successBlock
               failBlock:(void(^)(ResultCode resultCode))errorBlock
{
    //先将所有的操作产生
    NSMutableArray *docSignOperationsArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < positionArray.count; i++) {

        DocSignOperation *docSignOper = [[DocSignOperation alloc] init];
        //设置属性
        NSDictionary *positionDic = [positionArray objectAtIndex:i];
        NSNumber *positionX = positionDic[@"x"];
        NSNumber *positionY = positionDic[@"y"];
        double x = [positionX doubleValue];
        double y = [positionY doubleValue];
        NSString *positionValue = [NSString stringWithFormat:@"%f#%f",x,y];

        //对positionValue进行base64加密
        positionValue = [JSSCommon base64EncodingWithClearText:positionValue];
        
        NSNumber *pageValue = [positionDic objectForKey:@"pageNum"];
        
        docSignOper.userName = userName;
        docSignOper.docID = docID;
        docSignOper.certNO = certNO;
        docSignOper.token = token;
        docSignOper.positionValue = positionValue;
        docSignOper.pageValue = [pageValue integerValue];//怎么转成0了
        docSignOper.pin = pin;
        docSignOper.positionType = 2;
        docSignOper.todoID = todoID;
        
        [docSignOperationsArray addObject:docSignOper];
    }
    
    
    //设置串行关系:前n-1个成功回调为发起下一个线程任务
    for (int i = 0; i < docSignOperationsArray.count; i++) {
        
        DocSignOperation *docSignOper = [docSignOperationsArray objectAtIndex:i];
        
        //不是最后一个
        if (i != docSignOperationsArray.count - 1) {
        
            //设置成功的block
            docSignOper.successBlock = ^{

                //下一个
                DocSignOperation *nextOper = [docSignOperationsArray objectAtIndex:i+1];
                [_operationQueue addOperation:nextOper];
                
            };
            
        }
        //是最后一个，就执行传入的成功回调：
        else
        {
            //最终的成功
            docSignOper.successBlock = successBlock;
        }
        
        
        //失败的话
        docSignOper.errorBlock = ^(ResultCode resultCode)
        {
            //最终的code
            errorBlock(resultCode);
        };
        
    }
    
    
    //取出第一个
    DocSignOperation *firstSignOperation = [docSignOperationsArray firstObject];
    [_operationQueue addOperation:firstSignOperation];
    
}



@end
