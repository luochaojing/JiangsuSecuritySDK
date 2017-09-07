//
//  ServerAddress.h
//  JiangsuSDK
//
//  Created by Luo on 16/12/23.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerlPort.h"



//! 服务器地址单例模式
@interface ServerAddressManager : NSObject


//---属性----
@property (nonatomic, copy) NSString *serverAddress;


//---方法------
+ (NSString *)getURLwithPortName:(NSString *)portName;



+ (ServerAddressManager *)sharedServerAdressManager;


@end
