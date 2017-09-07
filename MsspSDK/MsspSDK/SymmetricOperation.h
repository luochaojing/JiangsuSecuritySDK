//
//  AESOperation.h
//  TestMssp
//  对称加密的NSOperation 继承MsspOperation 主要实现本地数据加解密api的操作
//  Created by huwenjun on 15-12-25.
//  Copyright (c) 2015年 aspire. All rights reserved.
//

#import "MsspOperation.h"
#import "ResultHeader.h"

typedef enum
{
    Encryption=1,
    Decryption,
}
symmetricModel;

@interface SymmetricOperation : MsspOperation<NSStreamDelegate>

/**用于加解密的对称密钥 */
@property (nonatomic,copy) NSString *symmetricKey;

/**NSOperation的操作模式  Encryption代表加密 Decryption代表解密*/
@property (nonatomic, assign) symmetricModel model;

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
- (void)setCompletionBlockWithsuccess:(void (^)(SymmetricOperation *operation))success
                              failure:(void (^)(SymmetricOperation *operation, ResultCode resultCode))failure;
@end

