//
//  ResultHeader.h
//  MsspSDK
//  
//  Created by huwenjun on 15-12-10.
//  Copyright (c) 2015年 aspire. All rights reserved.
//

#ifndef MsspSDK_ResultHeader_h
#define MsspSDK_ResultHeader_h

typedef enum ResultCode: unsigned short
{
    RC_SUCCESS = (unsigned short)0X0000,	//成功
    
   	RC_NETWORK_UNACCESS	= (unsigned short)0X10001,	// 1 网络层错误 网络不可用
    RC_NETWORK_TIMEOUT	= (unsigned short)0X10002,	//网络超时
				
    RC_DEVICE_UNTRUST = (unsigned short)0X20001,	//设备不可信 2	设备层错误
    RC_DEVICE_INBACKLIST = (unsigned short)0X20002,	//设备为黑名单
    RC_DEVICE_ENCRYPTERROR= (unsigned short)0X20003,	//加密失败
    RC_DEVICE_DECRYPTERROR	= (unsigned short)0X20004,	//解密失败
    RC_DEVICE_NOKEY= (unsigned short)0X20005,	//解密KEY不存在
				
    RC_APP_AGENTUNEXSIST= (unsigned short)0X30001,	//AGENT未安装 3	应用层错误
    RC_APP_AGENTUNACCESS= (unsigned short)0X30002,	//AGENT不可用
    RC_APP_AGENTUNTRUST= (unsigned short)0X30003	,//AGENT不可信
    RC_APP_AGENTEXPIRED= (unsigned short)0X30004,	//AGENT过期
    RC_APP_AGENTUPGRADE= (unsigned short)0X30005,	//AGENT升级中
    RC_APP_UNTRUST= (unsigned short)0X30006,	//应用不可信
    RC_APP_BLACKLIST= (unsigned short)0X30007,	//应用为黑名单
    RC_APP_EXPIRED= (unsigned short)0X30008,	//APP版本过期
    RC_APP_FORCEDOWNLINE= (unsigned short)0X30009,	//应用强制下线
    RC_APP_NOKEY= (unsigned short)0X3000A,	//KEY不存在
				
    RC_USER_INBAKLIST= (unsigned short)	0X40001,	//用户在黑名单 4	用户层错误
    RC_USER_NOSIM= (unsigned short)	0X40002,	//SIM卡不存在
    RC_USER_UNREGISTER= (unsigned short)	0X40003,	//用户未注册
    RC_USER_EXSIST= (unsigned short)	0X40004,	//用户已存在
    RC_USER_VERIFYERROR= (unsigned short)	0X40005,	//验证码错误或者过期
    RC_USER_OHTERLOGIN= (unsigned short)	0X40006,	//其他用户已登录
    RC_USER_PWDERROR	= (unsigned short)0X40007,	//用户登录密码错误
    RC_USER_UNLOGON= (unsigned short)	0X40008,	//用户未登录
    RC_USER_UNBIND= (unsigned short)	0X40009,	//用户未绑定
    RC_USER_PINERROR	= (unsigned short)0X4000A,	//用户PIN码错误
    RC_USER_ENCRYPTERROR= (unsigned short)	0X4000B,	//加密失败
    RC_USER_DECRYPTERROR= (unsigned short)	0X4000C,	//解密失败
    RC_USER_NOKEY= (unsigned short)	0X4000D,	//解密KEY不存在
    RC_USER_INVALID	= (unsigned short)0X4000E,	//用户名非法
    RC_PWD_INVALID= (unsigned short)	0X40010,	//密码或者pin码非法
    RC_USER_UNVERIFY= (unsigned short)	0X40011,	//用户待验证
				
				
    RC_CERT_EXPIRE	= (unsigned short)0X50001,	//证书已过期 5	证书错误
    RC_CERT_SIGNERROR= (unsigned short)	0X50002,	//验签失败
    RC_CERT_SIGNINVALID	= (unsigned short)0X50003,	//验签原文格式错误
    RC_CERT_NOEXSIST= (unsigned short)	0X50005,	//证书不存在
				
				
    RC_SYS_CALLINVALID= (unsigned short)	0X9FFFF,	//未按顺序调用API 9	系统错误
    RC_SYS_CRYPTERROR= (unsigned short)	0X90001,	//消息解密失败
    RC_SYS_SERVICEINVALID= (unsigned short)	0X90002,	//服务不可用
    RC_SYS_PARAMETERINVALID	= (unsigned short)0X90003,	//参数错误
    RC_SYS_INTERNALERROR= (unsigned short)	0X90004,	//系统内部错误
    RC_SYS_TRANIDREPEAT	= (unsigned short)0X90005,	//流水号重复
    RC_SYS_NOKEY	= (unsigned short)0X90006,	//Key不存在
    RC_SYS_TOKENEXPIRE= (unsigned short)	0X90007,	//令牌过期
    RC_SYS_INVALIDPACK	= (unsigned short)0X90008,	//包数据验证失败
    RC_SYS_MAXLARGE= (unsigned short)	0X90009,	//加密签名数据过大（不超过10m）
    RC_SYS_UNKOWN= (unsigned short)	0X90FFF,	//未知错误
}ResultCode;

#endif
