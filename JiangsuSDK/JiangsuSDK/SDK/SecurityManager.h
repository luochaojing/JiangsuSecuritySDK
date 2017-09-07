//
//  SecurityManager.h
//  JiangsuSDK
//  安全SDK -- 开发者调用的接口都从这里开始
//  Created by Luo on 16/11/23.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

// --------使用说明---------
// 1.必须先初始化
// 2.SDK使用到了c++编译，所以请将调用的文件后缀名改成.mm 或者在设置为c++
// 3.需要在buildSetting搜bitcode设置为NO
// 4.添加静态库需设置headerSearch Path以找到头文件
// ------------------------



#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include "ResultCodeHeader.h"


//! 江苏电子签章平台iOS端安全SDK
@interface SecurityManager : NSObject


#pragma mark - 初始化接口

/**
*  1.初始SDK，token为登录令牌。管理为单例模式，请在第一步初始化
*
*  @param token         口令牌，必备！！发请求的基础！
*  @param userName      用户名字，这很重要！未初始化调用API后果自负。
*  @param serverAddress 服务器地址(需要在项目后加/):如http://10.1.1.1:8080/essport/ 内部不做网址规范检验请确保传入的是正确的地址
*  @param successBlock  成功回调
*  @param errorBlock    失败回调：22
*/
+ (void)initSDKWithToken:(NSString *)token
                userName:(NSString *)userName
           serverAddress:(NSString *)serverAddress
            successBlock:(void(^)())successBlock
              errorBlock:(void(^)(ResultCode resultCode))errorBlock;



#pragma mark - 申请动态验证码接口
/**
 *  2.申请动态验证码
 *
 *  @param phoneNum     手机号码
 *  @param successBlock 成功发送
 *  @param errorBock    失败回调:(2,7,8,9,19,22,26)
 */
+ (void)applyDynamicCodeWithPhoneNum:(NSString *)phoneNum
                        successBlock:(void (^)())successBlock
                          errorBlock:(void (^)(ResultCode resultCode))errorBlock;



#pragma mark - 证书状态查询接口

/**
 *  3.证书状态查询
 *
 *  @param successBlock state:1.正常 2.吊销 3.过期 4.已申请
 *  @param errorBlock   失败回调:(2,7,8,11,19,26)
 */
+ (void)certStateQueryWithSuccessBlock:(void(^)(NSInteger state))successBlock
                            errorBlock:(void(^)(ResultCode errorCode))errorBlock;




#pragma mark - 证书申请
/**
 *  4.证书申请 - 需要实现初始化!!
 *
 *  @param pin          PIN值，用于保存本地的私钥
 *  @param verifyCode   短信验证码
 *  @param pesName      姓名，证件上的名字
 *  @param cardType     证件类型:严格对照类型，否则后台返回未知错误！
 *  @param cardNO       证件号码
 *  @param mobileNO     手机
 *  @param userType     用户类型:严格对照类型，否则后台返回未知错误！
 *  @param successBlock 成功申请并保存在本地
 *  @param errorBlock   失败：其中EC_FAILURE为后台返回是”其他错误“的参数错误，可表现为证件类型，号码，名字等错误
 *                      (2,7,8,10,19,20,22,26)
 */
+ (void)certApplyWithPin:(NSString *)pin
              verifyCode:(NSString *)verifyCode
                 pesName:(NSString *)pesName
                cardType:(CardType)cardType
                  cardNO:(NSString *)cardNO
                mobileNO:(NSString *)mobileNO
                userType:(CertUserType)userType
            successBlock:(void (^)())successBlock
              errorBlock:(void (^)(ResultCode))errorBlock;



#pragma mark - 证书吊销
/**
 *  5.证书吊销接口-一个用户只能拥有一个证书，必须先初始化SDK
 *
 *  @param successBlock 成功吊销
 *  @param errorBlock   失败回调:(2,7,8,11,19,26)
 */
+ (void)certCancelWithSuccessBlock:(void (^)())successBlock
                        errorBlock:(void (^)(ResultCode))errorBlock;



#pragma mark - 数字签名：用户登录
/**
 *  6.数字签名--输入PIN调用私钥对传入的明文加密：1.读取私钥解密 2.加密返回.必须先初始化SDK
 *
 *  @param pin                   PIN值：应该是相当于密码或者二级密码
 *  @param orignal               明文：NO可以是“中文”。但是传入YES必须是base64编码的值。
 *  @param isNeedBase64Decoding  是否需要将原文base64解码之后再加密。一般是false。传入中文数字等直接加密的请传入NO
 *                               在哈希值传回是需要base64解密再加密的，传入YES。由于OC的NSString表示不了乱码，所以担心有特殊情况。
 *  @param successBlock          成功回调,cipherText为成功签名之后的数据
 *  @param errorBlock            失败回调:(8,11,14,22,30)
 */
+ (void)digitalSignatrueWithPin:(NSString *)pin
                        orignal:(NSString *)orignal
           ifNeedBase64Decoding:(BOOL)isNeedBase64Decoding
                   successBlock:(void (^)(NSString *cipherText))successBlock
                     errorBlock:(void (^)(ResultCode))errorBlock;



#pragma mark - 获取文档下载链接
/**
 *  7.获取文档下载链接
 *
 *  @param docID        文档ID
 *  @param successBlock 成功回调：docURL为文档下载链接
 *  @param errorBlock   失败回调：(2,7,8,15,19,22,26)
 */
+ (void)getDocURLWithDocID:(NSString *)docID
              SuccessBlock:(void(^)(NSString *docURL))successBlock
                errorBlock:(void(^)(ResultCode errorCode))errorBlock;



#pragma mark - 对文档进行签章
/**
 *  8.1 对文档的关键词进行电子签章:必须先初始化SDK，且查询证书的状态。
 *
 *  @param pin          pin
 *  @param docID        文档编号
 *  @param keyWord      关键词：不要base64等编码。直接如“负责人”即可。
 *  @param todoID       不知为何物
 *  @param successBlock 成功回调：成功对关键词对应的所有位置进行签章，10个位置9成1败也是失败，需求是这么说的。
 *  @param errorBlock   失败回调:(2,7,8,14,15,19,21,22,26,29)
 */
+ (void)docSignWithPin:(NSString *)pin
                 docID:(NSString *)docID
               keyWord:(NSString *)keyWord
                todoID:(NSString *)todoID
          successBlock:(void (^)())successBlock
             failBlock:(void (^)(ResultCode errorCode))errorBlock;



/**
 *  8.2 坐标模式：慎用
 *
 *  @param pin          pin
 *  @param docID        文档编号
 *  @param x            x坐标
 *  @param y            y坐标
 *  @param pageValue    页数：大于0
 *  @param todoID       todoID
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 */
+ (void)docSignWithPin:(NSString *)pin
                 docID:(NSString *)docID
                     x:(CGFloat)x
                     y:(CGFloat)y
             pageValue:(NSInteger)pageValue
                todoID:(NSString *)todoID
          successBlock:(void (^)())successBlock
             failBlock:(void (^)(ResultCode errorCode))errorBlock;



#pragma mark - 查看签章详情
/**
 *  9.查看电子签章详情 - 纯网络请求
 *
 *  @param docID        文档编号
 *  @param successBlock 返回多个签章详情的数组：是后台返回的直接数据，请根据需求自行解析。
 *  @param errorBlock   失败回调:(2,7,8,15,19,22)
 */

+ (void)querySignInfoWithDocID:(NSString *)docID
                  successBlock:(void (^)(NSArray<SignInfoModel *> *))successBlock
                    errorBlock:(void (^)(ResultCode))errorBlock;



#pragma mark - 对电子签章进行认证
/**
 *  10.电子签章验证 - 单纯的请求
 *
 *  @param docID        文档编号
 *  @param signArea     签名域
 *  @param successBlock 成功
 *  @param errorBlock   失败回调:(2,7,8,15,22,26,27)
 */
+ (void)signInfoVerifyWithDocID:(NSString *)docID
                       signArea:(NSString *)signArea
                   successBlock:(void (^)())successBlock
                     errorBlock:(void (^)(ResultCode errorCode))errorBlock;

@end
