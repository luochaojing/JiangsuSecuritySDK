//
//  EncodeSignOperation.h
//  MsspSDK
//
//  Created by huwenjun on 16-1-2.
//  Copyright (c) 2016年 aspire. All rights reserved.
//

#import "MsspOperation.h"
#import "ResultHeader.h"
#define MAXENCODESIGN 10*1024*1024
#define DATA(str) [str dataUsingEncoding:NSUTF8StringEncoding]

@interface EncodeSignOperation : MsspOperation
/**用于加密签名的输入流 */
@property (nonatomic, strong) NSInputStream *inputStream;

/**用于加密签名的输出流 */
@property (nonatomic, strong) NSOutputStream *outputStream;

/**加密签名结果 */
@property (nonatomic, assign) ResultCode resultCode;

/**用于加密的对称密钥 */
@property (nonatomic,copy) NSString *symmetricKey;

/**
 *设置完成回调block
 *@author huwenjun
 *@param success 加解密的成功block回调
 *@param failure 加解密的失败block回调
 *@return
 */
- (void)setCompletionBlockWithsuccess:(void (^)(EncodeSignOperation *operation))success
                              failure:(void (^)(EncodeSignOperation *operation, ResultCode code))failure;
@end
