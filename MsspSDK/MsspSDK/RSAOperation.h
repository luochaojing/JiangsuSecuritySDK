//
//  RSAOperation.h
//  MsspSDK
//  非对称加密的NSOperation 继承MsspOperation 主要实现数据保护api的操作
//  Created by huwenjun on 15-12-21.
//  Copyright (c) 2015年 aspire. All rights reserved.
//

#import "MsspOperation.h"
#import "ResultHeader.h"

typedef enum
{
    RSAEncryption=1,
    RSADecryption
}
RSAModel;

#define DATA(str) [str dataUsingEncoding:NSUTF8StringEncoding]

@interface RSAOperation : MsspOperation<NSStreamDelegate>

/**用于加解密的RSA公钥 */
@property (nonatomic,copy) NSString *userPublicKeyRef;

/**用于加解密的RSA私钥*/
@property (nonatomic,copy) NSString *userPrivateKeyRef;

/**用于加解密的RSA公钥 */
@property (nonatomic,assign) SecKeyRef userPublicKeyRef1;

/**用于加解密的RSA私钥*/
@property (nonatomic,assign) SecKeyRef userPrivateKeyRef1;

/**NSOperation的操作模式  RSAEncryption代表加密 RSADecryption代表解密*/
@property (nonatomic, assign) RSAModel model;

/**用于加解密的输入流 */
@property (nonatomic, strong) NSInputStream *inputStream;

/**用于加解密的输出流 */
@property (nonatomic, strong) NSOutputStream *outputStream;

/**加解密结果 */
@property (nonatomic, assign) ResultCode resultCode;
/**
 *设置完成回调block
 *@author huwenjun
 *@param success 加解密的成功block回调
 *@param failure 加解密的失败block回调
 *@return
 */
- (void)setCompletionBlockWithsuccess:(void (^)(RSAOperation *operation))success
                              failure:(void (^)(RSAOperation *operation, ResultCode resultCode))failure;

@end
