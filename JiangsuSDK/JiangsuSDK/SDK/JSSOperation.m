//
//  JSSOperation.m
//  JiangsuSDK
//
//  Created by Luo on 16/11/24.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import "JSSOperation.h"


//! 卓望-江苏安全SDK的线程锁名
static NSString *kJSSSDKLockName = @"com.aspire.jsssdk.opertion.lock";

@implementation JSSOperation


/**
 *  线程的run启动？
 *
 *  @param __unused 用不到的对象
 */
+ (void)networkRequestThreadEntryPoint:(id)__unused object
{
    @autoreleasepool {
        
        [[NSThread currentThread] setName:@"JSSSDKThread"];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}


/**
 *  单例创建线程
 *
 *  @return 线程对象
 */
+ (NSThread *)netwokRequestThread
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
    if (!self) {
        return nil;
    }
    self.lock = [[NSRecursiveLock alloc] init];
    self.lock.name = kJSSSDKLockName;
    self.runLoopModes = [NSSet setWithObject:NSRunLoopCommonModes];
    
    return self;
}


/**
 *  重写父类的start
 */
- (void)start
{
    [self.lock lock];
    if ([self isCancelled]) {
        
        //取消了
    }
    else if ([self isReady])
    {
        [self willChangeValueForKey:@"isExecuting"];
        self.excute = YES;
        [self didChangeValueForKey:@"isExecuting"];
        
        [self willChangeValueForKey:@"isFinished"];
        self.finish = NO;
        [self didChangeValueForKey:@"isFinished"];
        
        [self performSelector:@selector(operationDidStart) onThread:[[self class] netwokRequestThread] withObject:nil waitUntilDone:NO modes:[self.runLoopModes allObjects]];
    }
    [self.lock unlock];
}


/**
 *  实际的操作。
 *  子类需重写该方法，实现具体功能
 */
- (void)operationDidStart
{
    [self.lock lock];
    if (![self isCancelled]) {
        
    }
    [self.lock unlock];
}


#pragma mark - 一些方法的重写

- (BOOL)isExecuting
{
    return self.excute;
}

- (BOOL)isFinished
{
    return self.finish;
}

- (BOOL)isConcurrent
{
    return YES;
}

- (void)finishOpertion
{
    [self.lock lock];
    
    [self willChangeValueForKey:@"isExecuting"];
    self.excute = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self willChangeValueForKey:@"isFinished"];
    self.finish = YES;
    [self didChangeValueForKey:@"isFinished"];

    [self.lock unlock];
}

- (void)cancel
{
    [self.lock lock];
    //?
    if (![self isFinished] && ![self isCancelled])
    {
        [super cancel];
        
        //如果是网络请求，线程取消是否要对其网络请求取消？
    }
    [self.lock unlock];
}

@end
