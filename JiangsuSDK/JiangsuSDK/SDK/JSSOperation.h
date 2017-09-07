//
//  JSSOperation.h
//  JiangsuSDK
//
//  抽象的Operation，主要实现线程安全和block回调 不实现具体功能
//  将具体的功能封装成一个Operation便于管理
//  SDK内的Operation都使用这个来实现
//
//  Created by Luo on 16/11/24.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import <Foundation/Foundation.h>


//! 操作完成的回调
typedef void(^customCompletionBlock)();


//! SDK内Operation的基类
@interface JSSOperation : NSOperation


//! 线程锁
@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;

//! 线程的runloop模式
@property (nonatomic, strong) NSSet *runLoopModes;

//! 操作完成的回调
@property (nonatomic, readwrite, copy) customCompletionBlock customCompletionBlock;

//! 操作发生的错误
@property (nonatomic, readwrite, retain) NSError *error;

//! 操作完成的标识
@property (nonatomic, assign) BOOL finish;

//! 操作执行的标识
@property (nonatomic, assign) BOOL excute;


/**
 *  结束线程
 */
- (void)finishOpertion;
@end
