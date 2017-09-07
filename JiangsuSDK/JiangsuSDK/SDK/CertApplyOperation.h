//
//  CertApplyOperation.h
//  JiangsuSDK
//
//  Created by Luo on 16/12/7.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import "JSSOperation.h"
#import "ResultCodeHeader.h"



/**
 *  证书申请线程
 *  1.生成密钥对 2.发请求 3.验证和保存
 */
@interface CertApplyOperation : JSSOperation


//! token
@property (nonatomic, copy) NSString *token;

//! 20位时间戳
@property (nonatomic, copy) NSString *transactionID;

//! 用户名
@property (nonatomic, copy) NSString *userName;

//! 短信验证码
@property (nonatomic, copy) NSString *verifyCode;

//! 国际通用标识
@property (nonatomic, copy) NSString *imei;

//! 证件姓名
@property (nonatomic, copy) NSString *pesName;

//! 证件类型
@property (nonatomic, assign) CardType cardType;

//! 证件号码
@property (nonatomic, copy) NSString *cardNO;

//! 手机号码
@property (nonatomic, copy) NSString *mobileNO;

//! 用户类型
@property (nonatomic, assign) CertUserType userType;

//! pin:用户加密
@property (nonatomic, copy) NSString *pin;

@property (atomic, copy, readwrite) ErrorBlock erorrBlock;

@property (atomic, copy, readwrite) SuccessBlock successBlock;

@end
