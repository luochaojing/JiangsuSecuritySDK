//
//  SignOperation.h
//  MsspSDK
//
//  Created by huwenjun on 15-12-27.
//  Copyright (c) 2015年 aspire. All rights reserved.
//

#import "MsspOperation.h"
#import "ResultHeader.h"

@interface SignOperation : MsspOperation

/**用于签名的输入流 */
@property (nonatomic, strong) NSInputStream *inputStream;

/**用于签名的输出流 */
@property (nonatomic, strong) NSOutputStream *outputStream;

/**签名结果 */
@property (nonatomic, assign) ResultCode resultCode;

/**
 *设置完成回调block
 *@author huwenjun
 *@param success 加解密的成功block回调
 *@param failure 加解密的失败block回调
 *@return
 */
- (void)setCompletionBlockWithsuccess:(void (^)(SignOperation *operation))success
                              failure:(void (^)(SignOperation *operation, ResultCode code))failure;

/**
 *设置完成回调block
 *@author huwenjun
 *@param hashAlg hash算法标识
 *@return 返回签名数据
 */
- (NSString *)sign:(NSString *)hashAlg;
@end
