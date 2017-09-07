//
//  LocalDataModel.m
//  MsspSDK
//  本地需要存储的数据模型
//  Created by huwenjun on 15-12-14.
//  Copyright (c) 2015年 aspire. All rights reserved.
//

#import "LocalDataModel.h"

@implementation LocalDataModel

/**
 *对象序列化
 *@author huwenjun
 *@return
 */
- (void)encodeWithCoder:(NSCoder *)aCoder
{
//    [aCoder encodeObject:_userPrivateKeyData forKey:@"userPrivateKeyData"];
//    [aCoder encodeObject:_userPublicKeyData forKey:@"userPublicKeyData"];
//    [aCoder encodeObject:_AESKeyData forKey:@"AESKeyData"];
    [aCoder encodeObject:_appID forKey:@"appID"];
    [aCoder encodeObject:_userName forKey:@"userName"];
    [aCoder encodeObject:_x509CerData forKey:@"x509CerData"];
    [aCoder encodeObject:_userPublicKeyStr forKey:@"userPublicKeyStr"];
    [aCoder encodeObject:_userPrivateKeyStr forKey:@"userPrivateKeyStr"];
    [aCoder encodeObject:_localSymmetricKeyStr forKey:@"localSymmetricKeyStr"];
    [aCoder encodeObject:_signSymmetricKeyStr forKey:@"signSymmetricKeyStr"];
    [aCoder encodeObject:_deviceIdentity forKey:@"deviceIdentity"];
    [aCoder encodeObject:_simIdentity forKey:@"simIdentity"];
    [aCoder encodeObject:_cerID forKey:@"cerID"];
}

/**
 *对象反序列化
 *@author huwenjun
 *@return
 */
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super init])
    {
//        self.userPublicKeyData =[aDecoder decodeObjectForKey:@"userPrivateKeyData"];
//        self.userPrivateKeyData = [aDecoder decodeObjectForKey:@"userPrivateKeyData"];
//        self.AESKeyData =[aDecoder decodeObjectForKey:@"AESKeyData"];
        self.appID =[aDecoder decodeObjectForKey:@"appID"];
        self.userName =[aDecoder decodeObjectForKey:@"userName"];
        self.x509CerData =[aDecoder decodeObjectForKey:@"x509CerData"];
        self.userPublicKeyStr =[aDecoder decodeObjectForKey:@"userPublicKeyStr"];
        self.userPrivateKeyStr =[aDecoder decodeObjectForKey:@"userPrivateKeyStr"];
        self.localSymmetricKeyStr =[aDecoder decodeObjectForKey:@"localSymmetricKeyStr"];
        self.signSymmetricKeyStr =[aDecoder decodeObjectForKey:@"signSymmetricKeyStr"];
        self.deviceIdentity =[aDecoder decodeObjectForKey:@"deviceIdentity"];
        self.simIdentity =[aDecoder decodeObjectForKey:@"simIdentity"];
        self.cerID =[aDecoder decodeObjectForKey:@"cerID"];
    }
    return (self);
    
}
@end
