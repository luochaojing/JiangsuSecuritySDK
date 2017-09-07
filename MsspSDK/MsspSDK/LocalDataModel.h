//
//  LocalDataModel.h
//  MsspSDK
//  本地需要存储的数据模型
//  Created by huwenjun on 15-12-14.
//  Copyright (c) 2015年 aspire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface LocalDataModel : NSObject<NSCoding>

//ios原生security框架的加解密 待用
// /**sdk生成的本地RSA公钥 */
//@property (nonatomic,assign) SecKeyRef userPublicKeyRef;
//
///**sdk生成的本地RSA公钥NSData类型 */
//@property (nonatomic,strong) NSData *userPublicKeyData;
//
///**sdk生成的本地RSA私钥 */
//@property (nonatomic,assign) SecKeyRef userPrivateKeyRef;
//
///**sdk生成的本地RSA私钥NSData类型 */
//@property (nonatomic,assign) NSData *userPrivateKeyData;
//
///**sdk生成的AES对称密钥 */
//@property (nonatomic,assign) SecKeyRef AESKeyRef;
//
///**sdk生成的AES对称密钥NSData类型  */
//@property (nonatomic,assign) NSData *AESKeyData;

 /**sdk生成的本地RSA公钥 */
@property (nonatomic,copy) NSString *userPublicKeyStr;

/**sdk生成的本地RSA私钥 */
@property (nonatomic,copy) NSString *userPrivateKeyStr;

/**sdk生成的用于本地对称加密的密钥*/
@property (nonatomic,copy) NSString *localSymmetricKeyStr;

/**sdk生成的用于加密签名的密钥*/
@property (nonatomic,copy) NSString *signSymmetricKeyStr;

/**请求获得的x509证书 */
@property (nonatomic,assign) SecCertificateRef x509Cer;

/**请求获得的x509证书NSData类型 */
@property (nonatomic,strong) NSData *x509CerData;

/**请求获得的x509证书ID */
@property (nonatomic,strong) NSString *cerID;

/**用户传入的appid */
@property (nonatomic,copy) NSString *appID;

/**用户传入的userName */
@property (nonatomic,copy) NSString *userName;

/**生成的设备标识 */
@property (nonatomic,copy) NSString *deviceIdentity;

/**sim卡标识？ */
@property (nonatomic,copy) NSString *simIdentity;

@end
