//
//  HttpReuqestOpertion.h
//  JiangsuSDK
//  继承于JSSOperation，用于再次封装管理HTTP请求
//  Created by Luo on 16/11/25.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import "JSSOperation.h"

typedef void(^successBlock)(id data);
typedef void(^errorBlock)(NSError *error);

//! 用于Http操作的线程
@interface HttpRequestOperation : JSSOperation

//! 网络请求的地址
@property (nonatomic, copy) NSString *urlStr;

//! 发送的数据字典
@property (nonatomic, strong) NSDictionary *requestDic;

//! 成功的回调函数
@property (atomic, copy ,readwrite) successBlock successBlock;

//! 失败的回调函数
@property (atomic, copy, readwrite) errorBlock errorBlock;

//! token
@property (nonatomic, copy) NSString *token;
@end
