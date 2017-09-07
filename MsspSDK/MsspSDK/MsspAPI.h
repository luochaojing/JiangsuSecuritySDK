//
//  MsspAPI.h
//  MsspSDK
//  移动安全服务平台安全凭证sdk的接口定义
//  Created by huwenjun on 15-12-10.
//  Copyright (c) 2015年 aspire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResultHeader.h"


@interface MsspAPI : NSObject

/**
 *初始化sdk
 *@author huwenjun
 *@param accessToken 应用程序通过业务系统代理向移动安全服务平台获取到访问令牌
 *@param appID
 *@param msspEndPoint 移动安全服务平台部署后提供到应用程序访问的服务地址
 *@param debug 当取值为true时是测试环境，不做应用合法性检查
 *@param block 初始化异步回调block 返回初始化结果
 *@return ResultCode  同步返回验签结果状态码
 */
+ (ResultCode)initSDK:(NSString *)accessToken
             userName:(NSString *)userName
                appID:(NSString *)appID
         msspEndPoint:(NSString *)msspEndPoint
          debugEnable:(BOOL)debug
                block:(void(^)(ResultCode code))block;
/*
 initSDK接口用法实例
 //该接口要在使用其他接口之前调用一次，调用一次之后，以后不再调用
 
 //封装参数
 
 NSString *token = @"令牌"; 
 //令牌是应用程序通过业务系统代理向移动安全服务平台获取到的
 
 NSString *userName = @"用户名"; 
 //用户名为用户手机号码
 
 NSString *appID = @"appID"; 
 //appID是调用该api的应用程序的appID
 
 NSString *msspEndPoint = @"服务地址";
 //服务地址为移动安全服务平台提供的，例如：https://10.1.4.113:8443/scsweb/services/scs.action
 
 //BOOL debugEnabled = YES;
 debugEnabled=YES 时为测试环境，不做应用合法性检查 debugEnabled=NO为正式应用环境
 
 //调用接口
 [MsspAPI initSDK:token userName:userName appID:appID msspEndPoint:msspEndPoint debugEnable:debugEnabled block:^(ResultCode code) {
     if (RC_SUCCESS == code) {
        //请求证书成功
     } else {
        //请求失败
        //如果请求证书失败可以获取并打印code值
        ResultCode resultCode = code;
        NSLog(@"请求失败 error=%hu", code);
        //可以参考ResultHeader.h查看code的具体含义
     }
 }];
*/



/**
 *数据保护 使用平台公钥加密数据
 *@author huwenjun
 *@param userName 用户名
 *@param inputStream 加密输入流
 *@param outputStream 加密输出流
 *@param block 数据保护异步回调block 返回加密结果
 *@return
 */
+ (void)protectData:(NSString *)userName
        inputStream:(NSInputStream *)inputStream
       outputStream:(NSOutputStream *)outputStream
              block:(void(^)(ResultCode code))block;
/*
 //数据保护接口用法实例
 
 //参数封装
 
 NNSString *userName = @"用户名";
 //用户名为用户手机号码
 
 //inputStream为数据输入流，下面给3种参考方法:
 //1.从文件中获取
 NSString *inputFilePath = @"文件路径放这里";
 NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath:inputFilePath];
 //2.从字符串/NSData中获取
 NSString *inputString = @"要加密的字符串放这里";
 NSInputStream *inputStream = [[NSInputStream alloc] initWithData:[inputString dataUsingEncoding:NSUTF8StringEncoding]];
 //3.从网络中获取（url）
 NSURL *url = [[NSURL alloc] initWithString:@"https:1.1.1.1:8000"];
 NSInputStream *inputStream = [[NSInputStream alloc] initWithURL:url];
 
 //outputStream为数据输出流，下面给出2种参考方法：
 //1.输出到文件
 NSString *outputFilePath = @"文件路径放这里";
 NSOutputStream *outputStream = [[NSOutputStream alloc] initToFileAtPath:encOutputFilePath append:NO];
 //2.输出到buffer
 static uint8_t buffer[1024];  //请确保数组大小够用
 memset(buffer, 0, sizeof(uint8_t) * 1024);
 NSOutputStream *outputStream = [[NSOutputStream alloc] initToBuffer:buffer capacity:1024];
 
 //调用接口
 [MsspAPI protectData:userName inputStream:inputStream outputStream:outputStream  block:^(ResultCode code) {
     if (RC_SUCCESS == code) {
        //数据保护成功，查看数据
 
        //如果输出到buffer就从buffer中获取
         NSData *data = [NSData dataWithBytes:buffer length:strlen(buffer)];
         //data = [TMBase64 encodeData:data];
         NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
 
        //如果是文件则需要以数据流的方式打开来读取
        NSInputStream *readStream = [[NSInputStream alloc] initWithFileAtPath:outputFilePath];
        [readStream open];
         bool moreData = true;
         unsigned long readLen = 0;
         uint8_t buf[1024];
         
         //循环读取数据
         while (moreData) {
             readLen = [readStream read:buf maxLength:1024];
             
             if (readLen == 0) {
                 moreData = false;
                 continue;
             }
             
             if (readLen > 0) {
                 NSData *readData = [[NSData alloc] initWithBytes:buf length:readLen];
                 NSString *ret = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
                 NSLog(@"%@", ret);
             }
         }
        [readStream close];
    } else {
         //数据保护失败
         //如果失败可以获取并打印code值
         ResultCode resultCode = code;
         NSLog(@"数据保护失败 error=%hu", code);
         //可以参考ResultHeader.h查看code的具体含义
    }
 }];
 */



/**
 *加密数据 随机生成iv值和key值 根据iv和key值选择3des或者aes加密
 *@author huwenjun
 *@param userName 用户名
 *@param inputStream 加密输入流
 *@param outputStream 加密输出流
 *@param block 加密数据异步回调block 返回加密结果
 *@return
 */
+ (void)encryptData:(NSString *)userName
        inputStream:(NSInputStream *)inputStream
       outputStream:(NSOutputStream *)outputStream
              block:(void(^)(ResultCode code))block;
/*
 //加密数据接口用法实例
 
 //参数封装
 
 NNSString *userName = @"用户名";
 //用户名为用户手机号码
 
 //inputStream为加密数据输入流，下面给3种参考方法:
 //1.从文件中获取
 NSString *inputFilePath = @"文件路径放这里";
 NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath:inputFilePath];
 //2.从字符串/NSData中获取
 NSString *inputString = @"要加密的字符串放这里";
 NSInputStream *inputStream = [[NSInputStream alloc] initWithData:[inputString dataUsingEncoding:NSUTF8StringEncoding]];
 //3.从网络中获取（url）
 NSURL *url = [[NSURL alloc] initWithString:@"https:1.1.1.1:8000"];
 NSInputStream *inputStream = [[NSInputStream alloc] initWithURL:url];
 
 //outputStream为加密数据的输出流，下面给出2种参考方法：
 //1.输出到文件
 NSString *outputFilePath = @"文件路径放这里";
 NSOutputStream *outputStream = [[NSOutputStream alloc] initToFileAtPath:encOutputFilePath append:NO];
 //2.输出到字符串
 static uint8_t buffer[1024];  //请确保数组大小够用
 memset(buffer, 0, sizeof(uint8_t) * 1024);
 NSOutputStream *outputStream = [[NSOutputStream alloc] initToBuffer:buffer capacity:1024];
 
 //调用接口
 [MsspAPI encryptData:userName inputStream:inputStream outputStream:outputStream block:^(ResultCode code) {
     if (RC_SUCCESS == code) {
         //加密成功，查看数据
 
         //如果输出到buffer就从buffer中获取
         NSData *data = [NSData dataWithBytes:buffer length:strlen(buffer)];
         data = [TMBase64 encodeData:data];
         NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
 
         //如果输出到文件建议直接在文件夹中找到文件进行查看，如果想直接打印出来需要以数据流的方式打开来读取，方法如下：
         NSInputStream *readStream = [[NSInputStream alloc] initWithFileAtPath:outputFilePath];
         [readStream open];
         bool moreData = true;
         unsigned long readLen = 0;
         uint8_t buf[1024];
         
         //循环读取数据
         while (moreData) {
             readLen = [readStream read:buf maxLength:1024];
             
             if (readLen == 0) {
                 moreData = false;
                 continue;
             }
             
             if (readLen > 0) {
                 NSData *readData = [[NSData alloc] initWithBytes:buf length:readLen];
                 readData = [TMBase64 encodeData:readData];
                 NSString *ret = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
                 NSLog(@"%@", ret);
             }
         }
         [readStream close];
     } else {
         //失败
         //如果失败可以获取并打印code值
         ResultCode resultCode = code;
         NSLog(@"加密失败 error=%hu", code);
         //可以参考ResultHeader.h查看code的具体含义
     }
 }];
 */



/**
 *解密数据 根据随机生成iv值和key值进行3des或者aes解密
 *@author huwenjun
 *@param userName 用户名
 *@param inputStream 解密输入流
 *@param outputStream 解密输出流
 *@param block 解密数据异步回调block 返回解密结果
 *@return
 */
+ (void)decryptData:(NSString *)userName
        inputStream:(NSInputStream *)inputStream
       outputStream:(NSOutputStream *)outputStream
              block:(void(^)(ResultCode code))block;
/*
 //解密数据接口用法实例
 
 //参数封装
 
 NNSString *userName = @"用户名";
 //用户名为用户手机号码
 
 //inputStream为解密数据输入流，下面给3种参考方法:
 //这个参数需是加密数据接口加密后的数据
 //1.从文件中获取
 NSString *inputFilePath = @"文件路径放这里";
 NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath:inputFilePath];
 //2.从字符串/NSData中获取
 NSString *inputString = @"要解密的东西放这里";
 NSInputStream *inputStream = [[NSInputStream alloc] initWithData:[inputString dataUsingEncoding:NSUTF8StringEncoding]];
 //3.从网络中获取（url）
 NSURL *url = [[NSURL alloc] initWithString:@"https:1.1.1.1:8000"];
 NSInputStream *inputStream = [[NSInputStream alloc] initWithURL:url];
 
 //outputStream为解密数据的输出流，下面给出2种参考方法：
 //1.输出到文件
 NSString *outputFilePath = @"文件路径放这里";
 NSOutputStream *outputStream = [[NSOutputStream alloc] initToFileAtPath:encOutputFilePath append:NO];
 //2.输出到字符串
 static uint8_t buffer[1024];  //请确保数组大小够用
 memset(buffer, 0, sizeof(uint8_t) * 1024);
 NSOutputStream *outputStream = [[NSOutputStream alloc] initToBuffer:buffer capacity:1024];
 
 //调用接口
 [MsspAPI decryptData:userName inputStream:inputStream outputStream:outputStream block:^(ResultCode code) {
     if (RC_SUCCESS == code) {
         //解密成功，查看结果
 
         //如果输出到buffer就从buffer中获取
         NSString *str = [[NSString alloc] initWithCString:buffer encoding:NSUTF8StringEncoding];
         
         //如果输出到文件建议直接在文件夹中找到文件进行查看，如果想直接打印出来需要以数据流的方式打开来读取，方法如下：
         NSInputStream *readStream = [[NSInputStream alloc] initWithFileAtPath:outputFilePath];
         [readStream open];
         bool moreData = true;
         unsigned long readLen = 0;
         uint8_t buf[1024];
         
         //循环读取数据
         while (moreData) {
             readLen = [readStream read:buf maxLength:1024];
             
             if (readLen == 0) {
                 moreData = false;
                 continue;
             }
             
             if (readLen > 0) {
                 NSData *readData = [[NSData alloc] initWithBytes:buf length:readLen];
                 NSString *ret = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
                 NSLog(@"%@", ret);
             }
         }
         [readStream close];
     } else {
         //解密失败
         //如果失败可以获取并打印code值
         ResultCode resultCode = code;
         NSLog(@"解密失败 error=%hu", code);
         //可以参考ResultHeader.h查看code的具体含义
     }
 }];
 */




/**
 *数据签名 根据固定格式对输入的数据用用户私钥签名
 *@author huwenjun
 *@param userName 用户名
 *@param inputStream 签名输入流
 *@param outputStream 签名输出流
 *@param block 签名异步回调block 返回签名结果
 *@return
 */
+ (void)dataSign:(NSString *)userName
     inputStream:(NSInputStream *)inputStream
    outputStream:(NSOutputStream *)outputStream
           block:(void(^)(ResultCode code))block;
/*
 //数据签名接口用法实例
 
 //参数封装
 
 NNSString *userName = @"用户名";
 //用户名为用户手机号码
 
 //inputStream为数据输入流，下面给3种参考方法:
 //1.从文件中获取
 NSString *inputFilePath = @"文件路径放这里";
 NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath:inputFilePath];
 //2.从字符串/NSData中获取
 NSString *inputString = @"要操作的放这里";
 NSInputStream *inputStream = [[NSInputStream alloc] initWithData:[inputString dataUsingEncoding:NSUTF8StringEncoding]];
 //3.从网络中获取（url）
 NSURL *url = [[NSURL alloc] initWithString:@"https:1.1.1.1:8000"];
 NSInputStream *inputStream = [[NSInputStream alloc] initWithURL:url];
 
 //outputStream为数据输出流，下面给出2种参考方法：
 //1.输出到文件
 NSString *outputFilePath = @"文件路径放这里";
 NSOutputStream *outputStream = [[NSOutputStream alloc] initToFileAtPath:encOutputFilePath append:NO];
 //2.输出到字符串
 static uint8_t buffer[1024];  //请确保数组大小够用
 memset(buffer, 0, sizeof(uint8_t) * 1024);
 NSOutputStream *outputStream = [[NSOutputStream alloc] initToBuffer:buffer capacity:1024];
 
 //调用接口
 [MsspAPI dataSign:userName inputStream:inputStream outputStream:outputStream block:^(ResultCode code) {
     if (RC_SUCCESS == code) {
         //数据签名成功，查看结果
         //如果输出到buffer就从buffer中获取
         NSString *str = [[NSString alloc] initWithCString:buffer encoding:NSUTF8StringEncoding];
         
         //如果输出到文件建议直接在文件夹中找到文件进行查看，如果想直接打印出来需要以数据流的方式打开来读取，方法如下：
         NSInputStream *readStream = [[NSInputStream alloc] initWithFileAtPath:outputFilePath];
         [readStream open];
         bool moreData = true;
         unsigned long readLen = 0;
         uint8_t buf[1024];
         
         //循环读取数据
         while (moreData) {
             readLen = [readStream read:buf maxLength:1024];
             
             if (readLen == 0) {
                 moreData = false;
                 continue;
             }
             
             if (readLen > 0) {
                 NSData *readData = [[NSData alloc] initWithBytes:buf length:readLen];
                 NSString *ret = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
                 NSLog(@"%@", ret);
             }
         }
         [readStream close];
     } else {
         //数据签名失败
         //如果失败可以获取并打印code值
         ResultCode resultCode = code;
         NSLog(@"数据签名失败 error=%hu", code);
         //可以参考ResultHeader.h查看code的具体含义
     }
 }];
 */




/**
 *加密签名 根据固定格式对输入的数据用用户私钥签名 对称加密
 *@author huwenjun
 *@param userName 用户名
 *@param inputStream 加密签名输入流
 *@param outputStream 加密签名输出流
 *@param block 加密签名异步回调block 返回加密签名结果
 *@return
 */
+ (void)encryptDataSign:(NSString *)userName
            inputStream:(NSInputStream *)inputStream
           outputStream:(NSOutputStream *)outputStream
                  block:(void(^)(ResultCode code))block;
/*
 //加密签名接口用法实例
 
 //参数封装
 
 NNSString *userName = @"用户名";
 //用户名为用户手机号码
 
 //inputStream为数据输入流，下面给3种参考方法:
 //1.从文件中获取
 NSString *inputFilePath = @"文件路径放这里";
 NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath:inputFilePath];
 //2.从字符串/NSData中获取
 NSString *inputString = @"要操作的字符串放这里";
 NSInputStream *inputStream = [[NSInputStream alloc] initWithData:[inputString dataUsingEncoding:NSUTF8StringEncoding]];
 //3.从网络中获取（url）
 NSURL *url = [[NSURL alloc] initWithString:@"https:1.1.1.1:8000"];
 NSInputStream *inputStream = [[NSInputStream alloc] initWithURL:url];
 
 //outputStream为数据输出流，下面给出2种参考方法：
 //1.输出到文件
 NSString *outputFilePath = @"文件路径放这里";
 NSOutputStream *outputStream = [[NSOutputStream alloc] initToFileAtPath:encOutputFilePath append:NO];
 //2.输出到字符串
 static uint8_t buffer[1024];  //请确保数组大小够用
 memset(buffer, 0, sizeof(uint8_t) * 1024);
 NSOutputStream *outputStream = [[NSOutputStream alloc] initToBuffer:buffer capacity:1024];
 
 //调用接口
 [MsspAPI encryptDataSign:userName inputStream:inputStream outputStream:outputStream block:^(ResultCode code) {
     if (RC_SUCCESS == code) {
         //加密签名成功，查看结果
         //如果输出到buffer就从buffer中获取
         NSString *str = [[NSString alloc] initWithCString:buffer encoding:NSUTF8StringEncoding];
         
         //如果输出到文件建议直接在文件夹中找到文件进行查看，如果想直接打印出来需要以数据流的方式打开来读取，方法如下：
         NSInputStream *readStream = [[NSInputStream alloc] initWithFileAtPath:outputFilePath];
         [readStream open];
         bool moreData = true;
         unsigned long readLen = 0;
         uint8_t buf[1024];
         
         //循环读取数据
         while (moreData) {
             readLen = [readStream read:buf maxLength:1024];
             
             if (readLen == 0) {
                 moreData = false;
                 continue;
             }
             
             if (readLen > 0) {
                 NSData *readData = [[NSData alloc] initWithBytes:buf length:readLen];
                 NSString *ret = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
                 NSLog(@"%@", ret);
             }
         }
         [readStream close];
     } else {
         //加密签名失败
         //如果失败可以获取并打印code值
         ResultCode resultCode = code;
         NSLog(@"加密签名失败 error=%hu", code);
         //可以参考ResultHeader.h查看code的具体含义
     }
 }];
 */

@end
