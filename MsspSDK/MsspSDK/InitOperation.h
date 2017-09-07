//
//  InitOperation.h
//  MsspSDK
//  初始化的NSOperation 继承MsspOperation 主要实现初始化api的操作
//  Created by huwenjun on 15-12-26.
//  Copyright (c) 2015年 aspire. All rights reserved.
//

#import "MsspOperation.h"
#import "ResultHeader.h"
@class LocalDataLogic;

typedef void (^requestBlock)(NSUInteger);

@interface InitOperation : MsspOperation

/**初始化结果 */
@property (nonatomic, assign) ResultCode resultCode;

/**用户传入的appid */
@property (nonatomic,copy) NSString *appID;

/**用户传入的userName */
@property (nonatomic,copy) NSString *userName;

/**用户传入的msspEndPoint */
@property (nonatomic,copy) NSString *msspEndPoint;

/**用户传入的accessToken */
@property (nonatomic,copy) NSString *accessToken;

/**请求block*/
@property (atomic, readwrite, copy) requestBlock requestBlock;

/**
 *设置完成回调block
 *@author huwenjun
 *@param block 初始化完成的block
 *@return
 */
- (void)setCompletionWithBlock:(void (^)(InitOperation *operation,ResultCode result))block;

/**
 *设置请求block
 *@author tangshihao
 *@return
 */
- (void)setRequestBlock;


@end
