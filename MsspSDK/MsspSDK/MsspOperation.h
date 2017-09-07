//
//  MsspOperation.h
//  MsspSDK
//  自定义NSOperation的父类 主要实现线程安全和block回调 不具体实现功能
//  Created by huwenjun on 15-12-26.
//  Copyright (c) 2015年 aspire. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^customCompletionBlock)();

@interface MsspOperation : NSOperation

/**NSOperation的线程锁 */
@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;

/**NSOperation的线程runloop模式 */
@property (nonatomic, strong) NSSet *runLoopModes;

/**NSOperation的操作完成回调block */
@property (atomic, readwrite, copy) customCompletionBlock customcompletionBlock;

/**NSOperation的操作发生的错误 */
@property (nonatomic, readwrite, retain) NSError *error;

/**NSOperation的操作完成标识 */
@property (nonatomic, assign) BOOL finish;

/**NSOperation的操作执行标识 */
@property (nonatomic, assign) BOOL excute;

- (void)finishOperation;
@end
