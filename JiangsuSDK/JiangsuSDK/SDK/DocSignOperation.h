//
//  DocSignOperation.h
//  JiangsuSDK
//  电子签章线程
//  Created by Luo on 16/12/8.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import "JSSOperation.h"
#import "ResultCodeHeader.h"



//! 电子签章线程 - 只能传像素点
@interface DocSignOperation : JSSOperation


//! token
@property (nonatomic, copy) NSString *token;

//! 文档ID
@property (nonatomic, copy) NSString *docID;

//! 证书序列号
@property (nonatomic, copy) NSString *certNO;

//! 用户账号
@property (nonatomic, copy) NSString *userName;

//! 定位模式:1.关键词 2.坐标点
@property (nonatomic, assign) NSInteger positionType;

/**
 *  必须严格按照要求，否则后果自负
 *  位置的值：1.关键词（@“关键词的String”） 2.坐标点（x值#y值）
 */
@property (nonatomic, copy) NSString *positionValue;

/**
 *  页数：“关键词模式可以为0”
 */
@property (nonatomic, assign) NSInteger pageValue;

//! 流程id
@property (nonatomic, copy) NSString *todoID;


//! 用户签名密码
@property (nonatomic, copy) NSString *pin;


//! 成功的回调函数---失败回调
@property (atomic, copy, readwrite) SuccessBlock successBlock;
@property (atomic, copy, readwrite) ErrorBlock errorBlock;

@end
