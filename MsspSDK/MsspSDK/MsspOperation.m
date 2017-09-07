//
//  MsspOperation.m
//  MsspSDK
//  自定义NSOperation的父类 主要实现线程安全和block回调 不具体实现功能
//  Created by huwenjun on 15-12-26.
//  Copyright (c) 2015年 aspire. All rights reserved.
//

#import "MsspOperation.h"

static NSString * const kMsspSDKLockName = @"com.aspire.ca.mssp.operation.lock";

@implementation MsspOperation

/**
 *线程的run启动
 *@author huwenjun
 *@return
 */
+ (void)networkRequestThreadEntryPoint:(id)__unused object {
    @autoreleasepool {
        [[NSThread currentThread] setName:@"MSSPThread"];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

/**
 *单利创建线程
 *@author huwenjun
 *@return 线程对象
 */
+ (NSThread *)networkRequestThread
{
    static NSThread *_networkRequestThread = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _networkRequestThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkRequestThreadEntryPoint:) object:nil];
        [_networkRequestThread start];
    });
    
    return _networkRequestThread;
}

- (instancetype)init
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    self.lock = [[NSRecursiveLock alloc] init];
    self.lock.name = kMsspSDKLockName;
    self.runLoopModes = [NSSet setWithObject:NSRunLoopCommonModes];
    
    return self;
}

/**
 *NSOperation的start方法
 *@author huwenjun
 *@return
 */
- (void)start
{
    [self.lock lock];
    if ([self isCancelled])
    {
        //        [self performSelector:@selector(cancelConnection) onThread:[[self class] networkRequestThread] withObject:nil waitUntilDone:NO modes:[self.runLoopModes allObjects]];
    }
    else if ([self isReady])
    {
        [self willChangeValueForKey:@"isExecuting"];
        self.excute = YES;
        [self didChangeValueForKey:@"isExecuting"];
        
        [self willChangeValueForKey:@"isFinished"];
        self.finish  = NO;
        [self didChangeValueForKey:@"isFinished"];
        
        [self performSelector:@selector(operationDidStart) onThread:[[self class] networkRequestThread] withObject:nil waitUntilDone:NO modes:[self.runLoopModes allObjects]];
    }
    [self.lock unlock];
}

/**
 *NSOperation的具体执行方法
 *@author huwenjun
 *@return
 */
- (void)operationDidStart
{
    [self.lock lock];
    if (![self isCancelled])
    {
        
    }
    [self.lock unlock];
}


- (BOOL)isExecuting {
    return self.excute;
}

- (BOOL)isFinished {
    return self.finish;
}

- (BOOL)isConcurrent {
    return YES;
}

- (void)finishOperation
{
    [self.lock lock];
    [self willChangeValueForKey:@"isExecuting"];
    self.excute = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self willChangeValueForKey:@"isFinished"];
    self.finish  = YES;
    [self didChangeValueForKey:@"isFinished"];
    [self.lock unlock];
}

- (void)cancel
{
    [self.lock lock];
    if (![self isFinished] && ![self isCancelled])
    {
        [super cancel];
    }
    [self.lock unlock];
}
@end
