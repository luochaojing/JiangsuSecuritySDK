//
//  CoreAPIManager.h
//  JiangsuSDK
//
//  Created by Luo on 16/11/24.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HttpRequestOperation;

#import "CertApplyOperation.h"
#import "DocSignOperation.h"
//! API调度管理对象，所有的API以多线程队列来实现，以block异步返回结果
@interface CoreAPIManager : NSObject


/**
 *  单例返回
 *
 *  @return 唯一的管理者
 */
+ (CoreAPIManager *)sharedCoreAPIManager;


/**
 *  发起HTTP请求，并将请求线程放入管理类进行管理
 *
 *  @param urlStr       URL地址
 *  @param requestDic   请求的字典
 *  @param successBlock 成功回调
 *  @param error        失败回调
 *
 *  @return HttpRequestOperation的线程
 */
- (HttpRequestOperation *)postHttpRequestWithRUL:(NSString *)urlStr
                                           token:(NSString *)token
                                      requestDic:(NSDictionary *)requestDic
                                    successBlock:(void(^)(id data))successBlock
                                      errorBlock:(void(^)(NSError *error))errorBlock;




/**
 *  证书申请：请不要传入空！！！！
 *
 *  @param token        token
 *  @param userName     用户名
 *  @param verifyCode   短信验证码
 *  @param pesName      姓名
 *  @param cardType     证书类型
 *  @param cardNO       证书号码
 *  @param mobileNO     手机号码
 *  @param userType     证书用户类型
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调：请查看错误码表。
 *
 *  @return 返回证书申请的线程，用于结束取消等操作
 */
- (CertApplyOperation *)certApplyWithToken:(NSString *)token
                                       pin:(NSString *)pin
                                  userName:(NSString *)userName
                                verifyCode:(NSString *)verifyCode
                                   pesName:(NSString *)pesName
                                  cardType:(CardType)cardType
                                    cardNO:(NSString *)cardNO
                                  mobileNO:(NSString *)mobileNO
                                  userType:(CertUserType)userType
                              successBlock:(void(^)())successBlock
                                errorBlock:(void(^)(ResultCode errrCode))errorBlock;



/**
 *  传入坐标数组：对数组里的位置（坐标+页数），逐个发请求签章
 *
 *  @param docID         文档ID
 *  @param userName      用户名
 *  @param certNO        证书NO
 *  @param token         token
 *  @param positionArray 位置数组
 *  @param todoID        xxxx
 *  @param successBlock  成功
 *  @param errorBlock    失败
 */
- (void)docSignWithDocID:(NSString *)docID
                userName:(NSString *)userName
                     pin:(NSString *)pin
                  certNO:(NSString *)certNO
                   token:(NSString *)token
                  todoID:(NSString *)todoID
           positionArray:(NSArray *)positionArray
            successBlock:(void(^)())successBlock
               failBlock:(void(^)(ResultCode resultCode))errorBlock;

@end
