//
//  JSSNetworking.h
//  JiangsuSDK
//
//  Created by Luo on 16/11/24.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import <Foundation/Foundation.h>

//AFNetworking post方法的请求回调
typedef void(^NetworkingSuccessBlock)(id data);
typedef void(^NetworkingErrorBlock)(NSError *error);


//! 用于实现网络接口
@interface JSSNetworking : NSObject


/**
 *  HTTP请求通用方法Post
 *
 *  @param urlStr       post的URL地址
 *  @param token        放入字典里的token
 *  @param infoDict     信息字典，会封装成json的格式
 *  @param successBlock 成功回调，返回数据为data，json格式，需解析
 *  @param errorBlock   失败回调
 */
+ (NSURLSessionTask *)postWithURL:(NSString *)urlStr
                            token:(NSString *)token
                         infoDict:(NSDictionary *)infoDict
                     successBlock:(NetworkingSuccessBlock)successBlock
                       errorBlock:(NetworkingErrorBlock)errorBlock;

@end
