//
//  HTTPSTool.h
//  HTTPSTool
//
//  Created by ASPire on 15/12/14.
//  Copyright © 2015年 ASPire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAFNetworking.h"
#import "ResultHeader.h"

@interface HTTPSTool : NSObject

//定义block类型
typedef void (^SucceedBlock)(TAFHTTPRequestOperation *operation, id responseObject);
typedef void (^SucceedBlock2)(NSDictionary *bodyDic);
typedef void (^FailedBlock)(NSError *error);
typedef void (^FailedBlock2)(ResultCode resultCode);

/**
 *	@brief	申请证书接口
 *  @author tangshihao
 *	@param 	strURL          url 字符串
 *  @param  appID           appID
 *	@param 	token           令牌，由第三方业务app调用sdk初始化时传进来
 *	@param 	version         业务流程版本号 对于统一消息应答与请求版本号始终一致
 *	@param 	oprCode 	    具体请求内容 1:申请证书  2：更新证书 3：吊销证书
 *	@param 	phoneNumber 	用户手机号
 *	@param 	dynamicCode 	验证码
 *	@param 	publicKey       公钥
 *	@param 	succeedBlock 	请求成功时的block
 *	@param 	failedBlock 	请求失败时的block
 */
+(void)applyForCertificateWithURL:(NSString *)strURL
                            appID:(NSString *)appID
                            token:(NSString *)token
                          version:(NSString *)version
                          oprCode:(NSInteger )oprCode
                      phoneNumber:(NSString *)phoneNumber
                      dynamicCode:(NSString *)dynamicCode
                        publicKey:(NSString *)publicKey
                     succeedBlock:(SucceedBlock2)succeedBlock
                      failedBlock:(FailedBlock2)failedBlock;

@end
