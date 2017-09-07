//
//  JSSNetworking.m
//  JiangsuSDK
//
//  Created by Luo on 16/11/24.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import "JSSNetworking.h"
#import "HYBNetworking.h"

@implementation JSSNetworking


+ (NSURLSessionTask *)postWithURL:(NSString *)urlStr
                            token:(NSString *)token
                         infoDict:(NSDictionary *)infoDict
                     successBlock:(NetworkingSuccessBlock)successBlock
                       errorBlock:(NetworkingErrorBlock)errorBlock


{
    
    
    [HYBNetworking configRequestType:kHYBRequestTypeJSON responseType:kHYBResponseTypeJSON shouldAutoEncodeUrl:YES callbackOnCancelRequest:NO];
    [HYBNetworking setTimeout:145];   //超时时间
    //post不使用URL缓存,get使用URL缓存
    [HYBNetworking cacheGetRequest:YES shoulCachePost:NO];

    //调用HYB的网络接口
    //[HYBNetworking acce]
    
    if (token) {
        
    }
    NSDictionary *headerDic = @{@"token":token};
    [HYBNetworking configCommonHttpHeaders:headerDic];//这里设置表头

    HYBURLSessionTask *task = [HYBNetworking postWithUrl:urlStr refreshCache:NO params:infoDict success:successBlock fail:errorBlock];
    
    return task;
}
@end
