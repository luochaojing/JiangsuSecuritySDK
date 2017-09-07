//
//  ServerlPort.h
//  JiangsuSDK
//
//  Created by Luo on 16/12/20.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#ifndef ServerlPort_h
#define ServerlPort_h

////! 服务器地址，可根据实际情况修改
//#define jServerAddress     @"http://10.1.4.74:8084/essportal/"
//
////#define jServerAddress @"http://10.1.25.60:8080/portal/"
//
////! 获取接口的URL，portName为接口名字：⬇️
//#define jPostURL(portName) [NSString stringWithFormat:@"%@%@",jServerAddress,portName]



/**
 接口的名称：请勿乱修改，后果自负！
 */

//! 获取证书状态接口
#define jGetCertStatus @"getCertStatus"

//! 发送短信验证码
#define jSendVerifyCode    @"sendVerifyCode"

//! 申请证书
#define jApplyCert         @"applyCert"

//! 吊销证书
#define jRevokeCert        @"revokeCert"

//! 获取文档下载链接
#define jDocumentDownload  @"documentDownload"

//! 通过的关键字获取坐标位置
#define jGetSignPosition   @"getSignPosition"

//! 获取文档哈希值
#define jGetDocumentHash   @"getDocumentHash"

//! 签章
#define jSignDocument      @"signDocument"

//! 查看签章详情
#define jGetSignInfo       @"getSignInfo"

//! 签章信息验证
#define jSignInfoVerify    @"signInfoVerify"


// 项目打包上线都不会打印日志，因此可放心。
#ifdef DEBUG
#define DebugLog(s, ... ) NSLog( @"[%@ in line %d] : %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DebugLog(s, ... )
#endif



#endif /* ServerlPort_h */
