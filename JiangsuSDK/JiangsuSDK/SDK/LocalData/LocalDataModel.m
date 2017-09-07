//
//  LocalDataModel.m
//  JiangsuSDK
//
//  Created by Luo on 16/11/28.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import "LocalDataModel.h"

//! 为了防止存取key手写有出入，最好是声明

@implementation LocalDataModel


#pragma mark - 序列化(模型->数据)

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    //object=属性的值，key=最好是属性的名字，与取出来---记得完善！

    [aCoder encodeObject:_userName forKey:@"userName"];
   // [aCoder encodeObj]
    

    [aCoder encodeObject:_privateKey forKey:@"privateKey"];
    [aCoder encodeObject:_publicKey forKey:@"publicKey"];
    [aCoder encodeObject:_certNO forKey:@"certNO"];
    [aCoder encodeObject:_certHashAlg forKey:@"certHashAlg"];
    [aCoder encodeObject:_cert forKey:@"cert"];
}


#pragma mark - 反序列化（从数据->模型）

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        
        self.userName = [aDecoder decodeObjectForKey:@"userName"];
        self.privateKey = [aDecoder decodeObjectForKey:@"privateKey"];
        self.publicKey = [aDecoder decodeObjectForKey:@"publicKey"];
        self.certNO = [aDecoder decodeObjectForKey:@"certNO"];
        self.certHashAlg = [aDecoder decodeObjectForKey:@"certHashAlg"];
        self.cert = [aDecoder decodeObjectForKey:@"cert"];
    }
    
    return self;
}
@end
