//
//  SignInfoModel.h
//  JiangsuSDK
//
//  Created by Luo on 16/12/1.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import <Foundation/Foundation.h>

//! 电子签章信息模型
@interface SignInfoModel : NSObject

//! 用户账号
@property (nonatomic, copy) NSString *userName;

//! 印章类型：1.个人章 2.企业章
@property (nonatomic, assign) NSInteger userType;

//! 签章时间
@property (nonatomic, copy) NSString *signDate;

//! 证书编号
@property (nonatomic, copy) NSString *certNO;

//! 签章证书--返回证书串
@property (nonatomic, copy) NSString *certificate;

//! 签章图片--文档说是返回base64的格式，实际运行后台返回的是图片的链接
@property (nonatomic, copy) NSString *signPic;

//! 签名域：诸如Aspie_172_01这样的格式
@property (nonatomic, copy) NSString *signArea;
@end
