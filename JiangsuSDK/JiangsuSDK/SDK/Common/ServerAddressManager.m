//
//  ServerAddress.m
//  JiangsuSDK
//
//  Created by Luo on 16/12/23.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import "ServerAddressManager.h"

@implementation ServerAddressManager


+ (ServerAddressManager *)sharedServerAdressManager
{
    static ServerAddressManager *__single;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        
        __single = [[ServerAddressManager alloc] init];
        
    });
    
    return __single;
}


+ (NSString *)getURLwithPortName:(NSString *)portName
{
    ServerAddressManager *manager = [ServerAddressManager sharedServerAdressManager];
    
    NSString *serverAdress = manager.serverAddress;
    
    NSString *url = [NSString stringWithFormat:@"%@%@",serverAdress,portName];
    
    
    return url;
}

@end
