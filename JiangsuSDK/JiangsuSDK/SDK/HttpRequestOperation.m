//
//  HttpReuqestOpertion.m
//  JiangsuSDK
//
//  Created by Luo on 16/11/25.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import "HttpRequestOperation.h"
#import "JSSNetworking.h"

@interface HttpRequestOperation()

//! 网络请求的task
@property (nonatomic, strong) NSURLSessionTask *task;

@end

@implementation HttpRequestOperation


- (void)operationDidStart
{
    [self.lock lock];
    if (![self isCancelled]) {
        
    
        //开始执行请求
       //self.task = [JSSNetworking postWithURL:self.urlStr infoDict:self.requestDic successBlock:self.successBlock errorBlock:self.errorBlock];
    
        __weak __typeof(self) weakSelf = self;
        
        NSString *token = [NSString stringWithFormat:@"%@",self.token];
        //NSLog(@"发送的字典=%@",self.requestDic);
        self.task = [JSSNetworking postWithURL:self.urlStr token:token infoDict:self.requestDic successBlock:^(id data) {
            weakSelf.successBlock(data);
            
            //记得要调用结束
            [weakSelf finishOpertion];
            
        } errorBlock:^(NSError *error) {
            weakSelf.errorBlock(error);
            [weakSelf finishOpertion];
            
        }];
        
    }
    [self.lock unlock];
    
}

- (void)cancel
{
    [self.lock lock];
    
    if (![self isFinished] && ![self isCancelled])
    {
        //如果是网络请求，线程取消是否要对其网络请求取消？
        [self.task cancel];
        [super cancel];
        
    }
    [self.lock unlock];
    
}

@end
