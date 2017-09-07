//
//  ResultCodeHeader.h
//  JiangsuSDK
//  返回结果编码表
//  Created by Luo on 16/11/25.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#ifndef ResultCodeHeader_h
#define ResultCodeHeader_h

#import "SignInfoModel.h"


typedef NS_ENUM(NSInteger,Sex)
{
    SexWomen = 1,
    SexMan = 2,
};


//! 证件类型
typedef enum CardType:NSInteger
{
    CardType_IDCard = 1,//身份证
    CardType_OfficerCertificate = 2,//军官证
    CardType_Passport = 3,//护照
    CardType_Soldbuch = 4,//士兵证
    CardType_DiplomatsCard = 5,//外交官证
    CardType_PoliceOfficerCertificate = 6,//武警警官证
    CardType_Other = 7, //其他
    
}CardType;


//! 证书申请用户类型
typedef enum CertUserType:NSInteger
{
    CertUserType_Personal = 1, //个人的
    CertUserType_Company  = 2, //企业
    CertUserType_Account  = 3, //账户
    
}CertUserType;



//! 错误返回码。后台接受到数据后，有很多错误类型，但是后台只返回几个+“其他错误”，导致用户无法确定到底是哪一个环节出错。不是SDK的锅。
typedef enum ResultCode: NSInteger
{
    EC_SUCCESS = 1,//成功
    
    //! DDDD
    EC_NETWORK_UNACCESS = 2,//网络请求错误，分为URL错误和网络不可用等，这个就是平常网络请求返回NSError的错误
    EC_NETWORK_TIMEOUT =   3,//网络超时间
    EC_NO_CONNECTION = 4,//无网络连接
    
    
    EC_PARSE_ERROR =   5,//数据解析错误
    EC_TRANSATIONID_ERROR =   6,//业务不匹配
    
    
    EC_TOKENERROR =   7,//令牌验证失败，token错误，请重新请求token，然后重新初始化SDK
    EC_INIT_ERROR =   8,//没有初始化，SDK没有初始化，传入的token和userName为空
    
    EC_SMS_SERVER_SEND_FAIL = 9,//服务器发送短信失败
    
    EC_SMS_INVALID =   10,//短信验证码验证失败
    
    EC_NOCERT =   11,//本地无证书：要发关于签章，签名，吊销等需要证书的操作需要先判断本地有无证书
    EC_CERT_ERROR =   12,//证书不匹配，这个暂无，因为只根据一个用户名读取对应的证书，名字不对为空
    
    EC_NOPIN =   13,//PIN码未输入，这个暂无，归类为输入参数错误
    EC_PIN_INVALID =   14,//PIN码错误
    
    EC_NOPDF =   15,//PDF文档不存在
    
    EC_MSGTYPE_ERROR =   16,//消息类型错误，暂无
    
    EC_SIGN_ERROR =   17,//签名运算错误
    
    EC_HMAC_ENCRY_ERROR =   18,//HMAC加密失败
    EC_HMAC_VERIFY_ERROR =   19,//HMAC验证失败
    
    EC_GEN_KEY_ERROR =   20,//密钥生成失败
    
    EC_GET_HASH_ERROR =   21,//获取文档哈希值失败（1.发送的位置不存在 2.该位置已经签过名了 3.其他参数错误）
    
    EC_PARA_ERROR =   22,//输入参数为空
    EC_SIGN_POS_ERROR =   23,//获取签章位置失败
    
    EC_SERVER_FAILURE =   24,//服务端错误,这个是指服务器返回约定外的值，一般不会出现
    EC_CLIENT_FAILURE =   25,//客户端错误
    
    EC_FAILURE =   26,//其他错误；普遍错误分为token，hmac等，其他参数错误统一分配为此。
                      //比如证书状态查询输入不存在的证书ID，分配为这个错误，这是后台没有细分。
                      //为了减少此类的错误，请根据逻辑的先后来调用，需先判断证书的可用性再请求签章
                      //电子签章，对已经签过的地方再发起请求，签章已经存在，也返回这个错误。
    
    EC_SIGNINFOVerify_FAILIRE = 27,//签章验证失败
    EC_SERVER_SIGN_FAILURE = 28,//服务器签章失败,这个也可能包含了其他参数的出错
    
    EC_KEYWORD_NO_POSITION = 29,//关键词对应的坐标位置为空，请重新选择关键词
    
    EC_RSASIGN_FALURE = 30,//RSA签名失败：私钥损坏;证书的签名算法（非sha1和md5）
    
}ResultCode;




typedef void(^ErrorBlock)(ResultCode errorCode);
typedef void(^SuccessBlock)();

#endif /* ResultCodeHeader_h */
