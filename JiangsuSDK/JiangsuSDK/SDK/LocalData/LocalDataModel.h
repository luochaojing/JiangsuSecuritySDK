//
//  LocalDataModel.h
//  JiangsuSDK
//  本地数据模型
//  Created by Luo on 16/11/28.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>


/**
 *  本地单个证书+用户模型
 *
 *  将多个该模型存入文件，读取遍历根据userName是否存在且有效
 */
@interface LocalDataModel : NSObject<NSCoding>

//! 用户名（一个用户对应一个证书）
@property (nonatomic, copy) NSString *userName;

//! 证书对应的私钥（加密过的）
@property (nonatomic, copy) NSString *privateKey;
//! 证书的公钥
@property (nonatomic,copy) NSString *publicKey;

//! 证书序列号
@property (nonatomic, copy) NSString *certNO;

//! 证书的签名hash算法：sha1 或者md5
@property (nonatomic, copy) NSString *certHashAlg;

//! x509证书 -- 先假设是个string
@property (nonatomic, copy) NSString *cert;


//- (void)setClearPrivateKey:(NSString *)privateKey withUserPin:(NSString *)pin;

//- (NSString *)getPrivateWithPin:(NSString *)pin;
@end
