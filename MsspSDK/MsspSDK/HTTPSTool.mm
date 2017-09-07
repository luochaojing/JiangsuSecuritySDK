//
//  HTTPSTool.m
//  HTTPSTool
//
//  Created by ASPire on 15/12/14.
//  Copyright © 2015年 ASPire. All rights reserved.
//

#import "HTTPSTool.h"
#import "GDataXMLNode.h"
//#import "HmacTool.h"
#import "TTMBase64.h"
#import "OpensslUtil.h"
//#import "MD5Tool.h"
#import "ResultHeader.h"
#import "LocalDataLogic.h"
#import "TAFHTTPSessionManager.h"
#import "TAFURLSessionManager.h"

@interface HTTPSTool()


#pragma mark 设置证书验证
/**
 *	@brief	该方法用于设置证书验证的对象（TAFSecurityPolicy）
 *  @author tangshihao
 *	@return	返回验证证书的对象 （TAFSecurityPolicy）
 */
+(TAFSecurityPolicy*)customSecurityPolicy;


#pragma mark 创建请求体request
/**
 *	@brief	创建请求体request
 *  @author tangshihao
 *	@param 	strURL 	URL字符串
 *	@param 	token 	令牌，由第三方业务app调用sdk初始化时传进来
 *	@param 	messageName 	消息名称
 *	@param 	version 	业务流程版本号 对于统一消息应答与请求版本号始终一致
 *	@param 	requestMessageBody 	xml格式的请求体字符串
 *
 *	@return	创建好的请求体request
 */
+(NSMutableURLRequest*)customRequestWithURL:(NSString *)strURL
                                      token:(NSString *)token
                                messageName:(NSString *)messageName
                                    version:(NSString *)version
                         requestMessageBody:(NSString *)requestMessageBody;


#pragma mark 发送请求
/**
 *	@brief	该方法用于发送请求
 *  @author tangshihao
 *	@param 	strURL 	URL字符串
 *	@param 	token 	令牌，由第三方业务app调用sdk初始化时传进来
 *	@param 	messageName 	消息名称
 *	@param 	version 	业务流程版本号 对于统一消息应答与请求版本号始终一致
 *	@param 	requestMessageBody 	xml格式的请求体字符串
 *	@param 	succeedBlock 	请求成功时的block
 *	@param 	failedBlock 	请求失败时的block
 */
+(void)requestSCSWithURL:(NSString *)strURL
                   token:(NSString *)token
             messageName:(NSString *)messageName
                 version:(NSString *)version
      requestMessageBody:(NSString *)requestMessageBody
            succeedBlock:(SucceedBlock)succeedBlock
             failedBlock:(FailedBlock)failedBlock;


@end

@implementation HTTPSTool


#pragma mark 设置证书验证
/**
 *	@brief	该方法用于设置证书验证的对象（TAFSecurityPolicy）
 *  @author tangshihao
 *	@return	返回验证证书的对象 （TAFSecurityPolicy）
 */
+(TAFSecurityPolicy*)customSecurityPolicy
{
    //使用TAFSecurityPolicy类验证证书
    
    //AFSSLPinningModeNone 这个模式表示不做SSL pinning，只跟浏览器一样在系统的信任机构列表里验证服务端返回的证书。若证书是信任机构签发的就会通过，若是自己服务器生成的证书，这里是不会通过的。
    //AFSSLPinningModeCertificate  这个模式表示用证书绑定方式验证证书，需要客户端保存有服务端的证书拷贝，这里验证分两步，第一步验证证书的域名/有效期等信息，第二步是对比服务端返回的证书跟客户端返回的是否一致。
    //AFSSLPinningModePublicKey 这个模式同样是用证书绑定方式验证，客户端要有服务端的证书拷贝，只是验证时只验证证书里的公钥，不验证证书的有效期等信息。只要公钥是正确的，就能保证通信不会被窃听，因为中间人没有私钥，无法解开通过公钥加密的数据。
    TAFSecurityPolicy *securityPolicy = [TAFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    
    //是否允许无效证书(如果是自建证书要改为yes)
    securityPolicy.allowInvalidCertificates = NO;
    
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO
    //如果证书域名为www.google.com 则请求的必须是www.google.com，mail.google.com就不行
    securityPolicy.validatesDomainName = YES;
    
    return securityPolicy;
}


/**
 *	@brief	该方法用于设置证书验证的对象（TAFSecurityPolicy）
 *  @author tangshihao
 *	@return	返回验证证书的对象 （TAFSecurityPolicy）
 */
+(TAFSecurityPolicy*)customSecurityPolicy2
{
    //获取本地证书
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"pemcer" ofType:@"der"];
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    
    //使用TAFSecurityPolicy类验证证书
    //AFSSLPinningModeNone 这个模式表示不做SSL pinning，只跟浏览器一样在系统的信任机构列表里验证服务端返回的证书。若证书是信任机构签发的就会通过，若是自己服务器生成的证书，这里是不会通过的。
    //AFSSLPinningModeCertificate  这个模式表示用证书绑定方式验证证书，需要客户端保存有服务端的证书拷贝，这里验证分两步，第一步验证证书的域名/有效期等信息，第二步是对比服务端返回的证书跟客户端返回的是否一致。
    //AFSSLPinningModePublicKey 这个模式同样是用证书绑定方式验证，客户端要有服务端的证书拷贝，只是验证时只验证证书里的公钥，不验证证书的有效期等信息。只要公钥是正确的，就能保证通信不会被窃听，因为中间人没有私钥，无法解开通过公钥加密的数据。
    TAFSecurityPolicy *securityPolicy = [TAFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    
    //设置本地证书，该证书会与从服务器获取的证书进行对比，同时验证证书的域名和有效期等信息
    //tsh 2016.3.11
    //    [securityPolicy setPinnedCertificates:[[NSSet alloc] initWithObjects:certData, nil]];
    [securityPolicy setPinnedCertificates:[[NSArray alloc] initWithObjects:certData, nil]];
    
    //是否允许无效证书(如果是自建证书要改为yes)
    securityPolicy.allowInvalidCertificates = NO;
    
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO
    //如果证书域名为www.google.com 则请求的必须是www.google.com，mail.google.com就不行
    securityPolicy.validatesDomainName = YES;
    
    return securityPolicy;
}


#pragma mark 普通字符串转换为十六进制
//普通字符串转换为十六进制的
+ (NSString *)hexStringFromString:(NSString *)string{
    //NSLog(@"length:%ld", [string length]);
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    //NSLog(@"data:%@", myD);
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%X", bytes[i]];///16进制数
        
        if(1 == [newHexStr length]) {
            hexStr = [NSString stringWithFormat:@"%@0%@", hexStr, newHexStr];
        }
        else {
            if (0 == i) {
                hexStr = [NSString stringWithFormat:@"%@", newHexStr];
            } else {
                hexStr = [NSString stringWithFormat:@"%@ %@",hexStr, newHexStr];
            }
        }
        
    }
    return hexStr;
}

+ (NSString *)hexStringFromString2:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    NSString *hexStr=@"";
    char buf[] = "0123456789ABCDEF";
    
    NSLog(@"myD length:%ld", (unsigned long)[myD length]);
    
    for(int i=0;i<[myD length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%c", buf[((bytes[i]&0xff) >> 4)]];
        NSString *oldHexStr = [NSString stringWithFormat:@"%c", buf[bytes[i]&0x0f]];
        if (0 == i) {
            hexStr = [NSString stringWithFormat:@"%@%@", newHexStr, oldHexStr];
        } else {
            hexStr = [NSString stringWithFormat:@"%@ %@%@", hexStr, newHexStr, oldHexStr];
        }
        
    }
    return hexStr;
}


#pragma mark 创建请求体request
/**
 *	@brief	创建请求体request
 *  @author tangshihao
 *	@param 	strURL 	URL字符串
 *	@param 	token 	令牌，由第三方业务app调用sdk初始化时传进来
 *	@param 	messageName 	消息名称
 *	@param 	version 	业务流程版本号 对于统一消息应答与请求版本号始终一致
 *	@param 	requestMessageBody 	xml格式的请求体字符串
 *
 *	@return	创建好的请求体request
 */
+(NSMutableURLRequest*)customRequestWithURL:(NSString *)strURL
                                      token:(NSString *)token
                                messageName:(NSString *)messageName
                                    version:(NSString *)version
                         requestMessageBody:(NSString *)requestMessageBody
{
    //编码
    strURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //创建url
    NSURL *url = [NSURL URLWithString:strURL];
    
    //创建可变请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    //设置请求类型为post类型
    [request setHTTPMethod:@"POST"];
    
    //**http消息头设置
    //设置消息类型
    NSString *type = [NSString stringWithFormat:@"text/xml"];
    [request setValue:type forHTTPHeaderField:@"Content-Type"];
    
    //设置令牌
    [request setValue:token forHTTPHeaderField:@"token"];
    
    //设置消息名称
    [request setValue:messageName forHTTPHeaderField:@"messageName"];
    
    //设置交易流水号，规则：14位时间＋6位随机数
    NSString *transactionID;
    
    //获取此刻时间
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    //获取6位随机数
    NSString *strRandom = @"";
    for(int i=0; i<6; i++)
    {
        strRandom = [ strRandom stringByAppendingFormat:@"%i", (arc4random() % 9)];
    }
    
    transactionID = [NSString stringWithFormat:@"%@%@", strDate, strRandom];
    
    //processTime请求时间／应答时间
    //获取此刻时间
    NSString *processTime = [dateFormatter stringFromDate:[NSDate date]];
    
    //设置消息
    NSString *xml = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><request><head><actionCode>0</actionCode><transactionID>%@</transactionID><version>%@</version><processTime>%@</processTime></head><body>%@</body></request>",transactionID,version,processTime,requestMessageBody];
    NSLog(@"xml:%@", xml);
    
    //设置消息长度,由 xml的长度算出
    NSString *contentLength = [NSString stringWithFormat:@"%ld",(unsigned long)[xml length]];
    [request setValue:contentLength forHTTPHeaderField:@"Content-Length"];
    
    //计算hamcmd5值
    OpensslUtil *opensslUtil = [OpensslUtil sharedOpensslUtil];
    NSString *key = @"12345678";
    NSString *hmacmd5 = [opensslUtil hmacEncode:@"md5" key:key key_length:(int)key.length input:xml input_length:(int)xml.length];
    /*
     NSString *temp = [HmacTool HMACMD5WithString:xml WithKey:@"12345678"];
     //temp = [MD5Tool md516BitLower:temp];
     NSString *tmp1 = [temp substringFromIndex:8];
     NSString *tmp2 = [tmp1 substringToIndex:16];
     NSString *tmp3 = [GTMBase64 base64StringBystring:tmp2];
     NSString *hmacmd5 = [self hexStringFromString2:tmp3];
     */
    
    NSString *hashCode = [NSString stringWithFormat:@"100001#%@", hmacmd5];
    
    //设置hashCode
    [request setValue:hashCode forHTTPHeaderField:@"hashCode"];
    
    // 将字符串转换成数据
    request.HTTPBody = [xml dataUsingEncoding:NSUTF8StringEncoding];
    
    return request;
}


#pragma mark 发送请求
/**
 *	@brief	该方法用于发送请求
 *  @author tangshihao
 *	@param 	strURL 	URL字符串
 *	@param 	token 	令牌，由第三方业务app调用sdk初始化时传进来
 *	@param 	messageName 	消息名称
 *	@param 	version 	业务流程版本号 对于统一消息应答与请求版本号始终一致
 *	@param 	requestMessageBody 	xml格式的请求体字符串
 *	@param 	succeedBlock 	请求成功时的block
 *	@param 	failedBlock 	请求失败时的block
 */
+(void)requestSCSWithURL:(NSString *)strURL
                   token:(NSString *)token
             messageName:(NSString *)messageName
                 version:(NSString *)version
      requestMessageBody:(NSString *)requestMessageBody
            succeedBlock:(SucceedBlock)succeedBlock
             failedBlock:(FailedBlock)failedBlock
{
    //创建请求体
    TAFHTTPRequestOperationManager *manager = [TAFHTTPRequestOperationManager manager];
    
    //声明服务器返回的数据类型为data
    manager.responseSerializer = [[AFHTTPResponseSerializer alloc]init];
    
    //设置对证书的验证
    manager.securityPolicy = [self customSecurityPolicy2];
    
    //创建请求
    NSMutableURLRequest *request = [self customRequestWithURL:strURL token:token messageName:messageName version:version requestMessageBody:requestMessageBody];
    
    TAFHTTPRequestOperation *operation =[manager HTTPRequestOperationWithRequest:request success:^(TAFHTTPRequestOperation *operation, id responseObject) {
        succeedBlock(operation, responseObject);
    } failure:^(TAFHTTPRequestOperation *operation, NSError *error) {
        failedBlock(error);
    }];
    [operation start];
}


#pragma mark 申请动态验证码
/**
 *	@brief	申请动态验证码接口
 *  @author tangshihao
 *	@param 	strURL          URL字符串
 *	@param 	token           令牌，由第三方业务app调用sdk初始化时传进来
 *	@param 	version         业务流程版本号 对于统一消息应答与请求版本号始终一致
 *	@param 	phoneNumber 	用户手机号
 *	@param 	appID           appID
 *	@param 	succeedBlock 	请求成功时的block
 *	@param 	failedBlock 	请求失败时的block
 */
+(void)applyForTestNumberWithURL:(NSString *)strURL
                           token:(NSString *)token
                         version:(NSString *)version
                     phoneNumber:(NSString *)phoneNumber
                           appID:(NSString *)appID
                    succeedBlock:(SucceedBlock2)succeedBlock
                     failedBlock:(FailedBlock)failedBlock

{
    //创建请求消息体
    NSString *requestMessageBody = [NSString stringWithFormat:@"<appID>%@</appID><misdn>%@</misdn>", appID, phoneNumber];
    
    //请求
    [self requestSCSWithURL:strURL token:token messageName:@"ApplyPassCode" version:version requestMessageBody:requestMessageBody succeedBlock:^(TAFHTTPRequestOperation *operation, id responseObject) {
        //请求成功时执行此处代码
        NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)operation;
        NSDictionary *dic = httpURLResponse.allHeaderFields;
        NSLog(@"headFields :%@", dic);
        
    } failedBlock:^(NSError *error) {
        //请求失败时执行此处代码
        NSLog(@"request failed. error:%@", error);
    }];
    
}

#pragma mark 申请证书
/**
 *	@brief	申请证书接口
 *  @author tangshihao
 *	@param 	strURL          url 字符串
 *  @param  appID           appID
 *	@param 	token           令牌，由第三方业务app调用sdk初始化时传进来
 *	@param 	version         业务流程版本号 对于统一消息应答与请求版本号始终一致
 *	@param 	oprCode 	    具体请求内容 1:申请证书  2：更新证书 3：吊销证书
 *	@param 	phoneNumber 	用户手机号
 *	@param 	dynamicCode 	验证码
 *	@param 	publicKey       公钥
 *	@param 	succeedBlock 	请求成功时的block
 *	@param 	failedBlock 	请求失败时的block
 */
+(void)applyForCertificateWithURL:(NSString *)strURL
                            appID:(NSString *)appID
                            token:(NSString *)token
                          version:(NSString *)version
                          oprCode:(NSInteger )oprCode
                      phoneNumber:(NSString *)phoneNumber
                      dynamicCode:(NSString *)dynamicCode
                        publicKey:(NSString *)publicKey
                     succeedBlock:(SucceedBlock2)succeedBlock
                      failedBlock:(FailedBlock2)failedBlock

{
    //获取imsi/imei
     LocalDataLogic *localDataLogic = [LocalDataLogic sharedLocalData];
     NSString *imei = [localDataLogic getDeviceIdentity];  //013787005271413
     NSString *imsi = [localDataLogic getSIMIdentity];
     
    
    //创建请求体
    NSString *requestMessageBody = [NSString stringWithFormat:@"<oprCode>%ld</oprCode><imei>%@</imei><imsi>%@</imsi><appid>%@</appid><misdn>%@</misdn><dynamicCode>%@</dynamicCode><publicKey>%@</publicKey>", (long)oprCode, imei, imsi, appID, phoneNumber, dynamicCode, publicKey];
    
    //请求
    [self requestSCSWithURL:strURL token:token messageName:@"CertOpr" version:version requestMessageBody:requestMessageBody succeedBlock:^(TAFHTTPRequestOperation *operation, id responseObject) {
        
        //成功时调用此处代码
        NSHTTPURLResponse *httpURLResponse = operation.response;
        NSDictionary *dic = httpURLResponse.allHeaderFields;
        NSLog(@"headFields :%@", dic);
        
        //获取http头中的resultCode参数
        NSString *resultCode = [dic valueForKey:@"resultCode"];
        if ([resultCode isEqualToString:@"0"]) {
            //服务器成功返回，进行数据处理
            NSData *tempData = (NSData *)responseObject;
            
            // 加载整个XML数据
            GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:tempData options:0 error:nil];
            
            //获取文档的根元素
            GDataXMLElement *root = doc.rootElement;
            
            //取出body 节点的全部元素
            NSArray *arr = [root elementsForName:@"body"];
            NSLog(@"body:%@", arr);
            
            //转为GDataXMLElement对象取出所有元素
            GDataXMLElement *body = [arr objectAtIndex:0];
            
            //将所有元素放入字典中
            NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
            
            //获取处理结果bizCode
            NSString *bizCode = ((GDataXMLElement *)[[body elementsForName:@"bizCode"] objectAtIndex: 0]).stringValue;
            [bodyDic setObject:bizCode forKey:@"bizCode"];
            
            //判断处理结果是否为0，为0表示成功返回
            if ([bizCode isEqualToString:@"0"]) {
                
                //提取证书信息
                NSString *certContent = ((GDataXMLElement *)[[body elementsForName:@"certContent"] objectAtIndex: 0]).stringValue;
                
                //判断字符串"$"是否包含
                NSRange range = [certContent rangeOfString:@"$"];
                
                if (range.length > 0){ //包含
                    NSArray *strArray = [certContent componentsSeparatedByString:@"$"];
                    //获取证书id
                    NSString *certID = [strArray objectAtIndex:0];
                    [bodyDic setObject:certID forKey:@"certID"];
                    //获取证书
                    NSString *cert = [strArray objectAtIndex:1];
                    [bodyDic setObject:cert forKey:@"cert"];
                }else{
                    [bodyDic setObject:certContent forKey:@"certID"];
                }
                //获取bizCodeDesc
                [bodyDic setObject:((GDataXMLElement *)[[body elementsForName:@"bizCodeDesc"] objectAtIndex: 0]).stringValue forKey:@"bizCodeDesc"];
                
                succeedBlock(bodyDic);
            } else {
                NSLog(@"bizeCode bu wei 0 %@",bizCode);
                ResultCode ret = (ResultCode)bizCode.intValue;
                failedBlock(ret);
            }
        } else {
            NSLog(@"resultCode %@",resultCode);
            ResultCode ret = RC_SUCCESS;
            unsigned short retInt = resultCode.intValue;
            ret = (ResultCode)retInt;
            failedBlock(ret);
        }
        
    } failedBlock:^(NSError *error) {
        //失败时调用此处代码
        NSLog(@"error:%@", error);
        ResultCode ret = RC_NETWORK_UNACCESS;
        failedBlock(ret);
    }];
}

@end
