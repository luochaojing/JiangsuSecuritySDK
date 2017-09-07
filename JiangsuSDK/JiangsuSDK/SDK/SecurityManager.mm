//
//  SecurityManager.m
//  JiangsuSDK
//   
//  Created by Luo on 16/11/23.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import "SecurityManager.h"
#import "CoreAPIManager.h"

#import "JSSCommon.h"
#import "LocalDataManager.h"

#import "OpensslUtil.h"
#import "GTMBase64.h"

#import "ServerAddressManager.h"

@interface SecurityManager()

//! 登录口令
@property (nonatomic, copy) NSString *token;

//! 用户名字
@property (nonatomic, copy) NSString *userName;

@end

@implementation SecurityManager

#pragma mark - 获取单例

+ (SecurityManager *)sharedManager
{
    static SecurityManager *__single;
    static dispatch_once_t once;

    dispatch_once(&once, ^{
       
        __single = [[SecurityManager alloc] init];
        
    });
    return __single;
}


#pragma mark - 1.初始化SDK

+ (void)initSDKWithToken:(NSString *)token
                userName:(NSString *)userName
           serverAddress:(NSString *)serverAddress
            successBlock:(void (^)())successBlock
              errorBlock:(void (^)(ResultCode))errorBlock
{
    //检验参数
    if (!token || !userName || [token isEqualToString:@""] || [userName isEqualToString:@""] || !serverAddress || [serverAddress isEqualToString:@""]) {
        errorBlock(EC_PARA_ERROR);
        return;
    }
    
    
    //初始化
    SecurityManager *securityManager = [SecurityManager sharedManager];
    securityManager.token = token;
    securityManager.userName = userName;
    
    //初始化网络地址
    [ServerAddressManager sharedServerAdressManager].serverAddress = serverAddress;
    
    //初始化证书
    [LocalDataManager initSharedLocalDataManagerWithUserName:userName];
    successBlock();
}


#pragma mark - 2.申请动态验证码

+ (void)applyDynamicCodeWithPhoneNum:(NSString *)phoneNum
                        successBlock:(void (^)())successBlock
                          errorBlock:(void (^)(ResultCode resultCode))errorBlock;
{

    //判断参数
    if (!phoneNum || [phoneNum isEqualToString:@""]) {
        errorBlock(EC_PARA_ERROR);
        return;
    }
    
    //判断是否已经初始化
    SecurityManager *securityManager = [SecurityManager sharedManager];
    if (!securityManager.token) {
        errorBlock(EC_INIT_ERROR);
        return;
    }
    
    //参数
    NSString *token = [NSString stringWithFormat:@"%@",securityManager.token];
    NSString *transationID = [JSSCommon getTransactionID];
    NSString *mobileNo = phoneNum;
    NSString *clearText = [NSString stringWithFormat:@"%@%@",transationID,mobileNo];
    
    //参数字典
    NSMutableDictionary *paraDic = [[NSMutableDictionary alloc] init];
    [paraDic setObject:transationID forKey:@"transactionID"];
    [paraDic setObject:mobileNo forKey:@"mobileNO"];
    [paraDic setObject:[JSSCommon HMACMD5WithClearText:clearText] forKey:@"hmac"];

    //请求字典
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setObject:@"SendVerifyCodeReq" forKey:@"messageName"];
    [requestDic setObject:paraDic forKey:@"para"];
    
    //3.发起一个Post的操作
    NSString *url = [ServerAddressManager getURLwithPortName:jSendVerifyCode];  //jPostURL(jSendVerifyCode);
    CoreAPIManager *coreAPIManager = [CoreAPIManager sharedCoreAPIManager];
    [coreAPIManager postHttpRequestWithRUL:url token:token requestDic:requestDic successBlock:^(id data) {
        
        //解析返回的json包
        ResultCode resultCode;
        NSDictionary *returnMessage = data;
        NSDictionary *paraDic = returnMessage[@"para"];
        NSNumber *returnCodeNum = paraDic[@"returnCode"];//为啥是num？
        NSInteger returnCodeInt = [returnCodeNum integerValue];
        switch (returnCodeInt) {
            
            case 0:
                //服务器成功检验数据包，还分为发送成功或者失败

            {
                //发送状态
                NSString *state = [NSString stringWithFormat:@"%@",paraDic[@"status"]];
                
                if ([state isEqualToString:@"1"]) {
                    //已发送
                    resultCode = EC_SUCCESS;
                    successBlock();
                }
                else if ([state isEqualToString:@"2"])
                {
                    //发送失败
                    resultCode = EC_SMS_SERVER_SEND_FAIL;
                    errorBlock(resultCode);
                    
                }
                break;
            }
            
            case 1:
                //hmac检验失败
                resultCode = EC_HMAC_VERIFY_ERROR;
                errorBlock(resultCode);
                break;
                
            case 2:
                //TOKEN错误
                resultCode = EC_TOKENERROR;
                errorBlock(resultCode);
                break;
                
            case 3:
                //未知错误：是分为服务器错误还是未知错误？
                resultCode = EC_FAILURE;
                errorBlock(resultCode);
                break;
                
            default:
                //防止服务器抽风返回其他数据
                resultCode = EC_SERVER_FAILURE;
                errorBlock(resultCode);
                break;
        }


    } errorBlock:^(NSError *error) {
        //网络错误
        errorBlock(EC_NETWORK_UNACCESS);
    }];
}



#pragma mark - 3.证书查询

+ (void)certStateQueryWithSuccessBlock:(void (^)(NSInteger))successBlock
                            errorBlock:(void (^)(ResultCode))errorBlock
{
    //判断是否初始化
    SecurityManager *securityManager = [SecurityManager sharedManager];
    NSString *token = securityManager.token;
    NSString *userName = securityManager.userName;
    if (!token || [token isEqualToString:@""] || !userName || [userName isEqualToString:@""])
    {
        errorBlock(EC_INIT_ERROR);
        return;
    }
    
    //查本地
    LocalDataModel *localDataModel = [LocalDataManager getLocalModel];
    if (!localDataModel) {
        //本地无证书
        errorBlock(EC_NOCERT);
        return;
    }
    //参数
    NSString *certNO = localDataModel.certNO;
    NSString *transactionID = [JSSCommon getTransactionID];
    NSString *clearText = [NSString stringWithFormat:@"%@%@",transactionID,certNO];
    NSString *hmac = [JSSCommon HMACMD5WithClearText:clearText];
    
    //参数字典
    NSMutableDictionary *paraDic = [[NSMutableDictionary alloc] init];
    [paraDic setObject:transactionID forKey:@"transactionID"];
    [paraDic setObject:certNO forKey:@"certNO"];
    [paraDic setObject:hmac forKey:@"hmac"];
    
    //请求字典
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setObject:@"GetCertStatusReq" forKey:@"messageName"];
    [requestDic setObject:paraDic forKey:@"para"];
    

    
    //发起请求
    NSString *getCertStatusURL = [ServerAddressManager getURLwithPortName:jGetCertStatus];//jPostURL(jGetCertStatus);
    CoreAPIManager *coreManager = [CoreAPIManager sharedCoreAPIManager];
    [coreManager postHttpRequestWithRUL:getCertStatusURL token:token requestDic:requestDic successBlock:^(id data) {
       
        //解析数据
        NSDictionary *returnDic = data;
        NSDictionary *paraDic = [returnDic objectForKey:@"para"];
        NSNumber *returnCodeNum = [paraDic objectForKey:@"returnCode"];
        NSInteger returnCodeInt = [returnCodeNum integerValue];
        
        if (returnCodeInt == 0) {
            
            NSNumber *statusNumber = [paraDic objectForKey:@"status"];
            NSInteger statusInt = [statusNumber integerValue];
            
            //属于1，2，3，4
            if (statusInt > 0 && statusInt < 5) {
                successBlock(statusInt);

            }
            
        }
        else if (returnCodeInt == 1)
        {
            //hmac错误
            errorBlock(EC_HMAC_VERIFY_ERROR);
        }
        else if (returnCodeInt == 2)
        {
            //token错误
            errorBlock(EC_TOKENERROR);
        }
        else if (returnCodeInt == 3)
        {
            //其他错误
            errorBlock(EC_FAILURE);
        }
        else
        {
            //服务器抽风
            errorBlock(EC_SERVER_FAILURE);
        }
        
    } errorBlock:^(NSError *error) {
        
        //网络不给力
        errorBlock(EC_NETWORK_UNACCESS);
    }];
    
}


#pragma mark - 4.证书申请

+ (void)certApplyWithPin:(NSString *)pin
              verifyCode:(NSString *)verifyCode
                 pesName:(NSString *)pesName
                cardType:(CardType)cardType
                  cardNO:(NSString *)cardNO
                mobileNO:(NSString *)mobileNO
                userType:(CertUserType)userType
            successBlock:(void (^)())successBlock
              errorBlock:(void (^)(ResultCode))errorBlock
{
    
    //在此判断参数
    if (!pin || !verifyCode || !pesName || !cardType || !cardNO || !mobileNO || !cardType || [verifyCode isEqualToString:@""] || [pin isEqualToString:@""] || [pesName isEqualToString:@""] || [cardNO isEqualToString:@""] || [mobileNO isEqualToString:@""]) {
        errorBlock(EC_PARA_ERROR);
        return;
    }

    
    //获取初始化单例的token
    SecurityManager *securityManager = [SecurityManager sharedManager];
    NSString *token = securityManager.token;
    NSString *userName = securityManager.userName;
    if (!token || [token isEqualToString:@""] || !userName || [userName isEqualToString:@""]) {
        //token为空，没有初始化
        errorBlock(EC_INIT_ERROR);
        return;
    }
    
    //发起一个申请的线程
    CoreAPIManager *coreManager = [CoreAPIManager sharedCoreAPIManager];
    [coreManager certApplyWithToken:token
                                pin:pin
                           userName:userName
                         verifyCode:verifyCode
                            pesName:pesName
                           cardType:cardType
                             cardNO:cardNO
                           mobileNO:mobileNO
                           userType:userType
                       successBlock:successBlock
                         errorBlock:errorBlock];
    
}



#pragma mark - 5.吊销证书

+ (void)certCancelWithSuccessBlock:(void (^)())successBlock
                        errorBlock:(void (^)(ResultCode))errorBlock
{
    //判断初始化
    SecurityManager *securityManager = [SecurityManager sharedManager];
    NSString *token = securityManager.token;
    NSString *userName = securityManager.userName;
    if (!token || [token isEqualToString:@""] || !userName || [userName isEqualToString:@""])
    {
        errorBlock(EC_INIT_ERROR);
        return;
    }
    
    
    //读取Local的单例获取到证书序列号
    LocalDataModel *localDataModel = [LocalDataManager getLocalModel];
    if (!localDataModel) {
        //本地无证书
        errorBlock(EC_NOCERT);
        return;
    }
    
    //证书ID
    NSString *certNO = localDataModel.certNO;
    
    //参数
    NSString *transactionID = [JSSCommon getTransactionID];
    NSString *clearText = [NSString stringWithFormat:@"%@%@",transactionID,certNO];
    NSString *hmac = [JSSCommon HMACMD5WithClearText:clearText];
    
    //参数字典
    NSMutableDictionary *paraDic = [[NSMutableDictionary alloc] init];
    [paraDic setObject:transactionID forKey:@"transactionID"];
    [paraDic setObject:certNO forKey:@"certNO"];
    [paraDic setObject:hmac forKey:@"hmac"];
    
    //请求字典
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setObject:@"RevokeCertReq" forKey:@"messageName"];
    [requestDic setObject:paraDic forKey:@"para"];
    
    //请求地址
    NSString *revokeCertReqURL = [ServerAddressManager getURLwithPortName:jRevokeCert];//jPostURL(jRevokeCert);
    
    //发起请求
    CoreAPIManager *coreAPIManager = [CoreAPIManager sharedCoreAPIManager];
    [coreAPIManager postHttpRequestWithRUL:revokeCertReqURL
                                     token:token
                                requestDic:requestDic
                              successBlock:^(id data) {
       
        //解析返回字典
        NSDictionary *returnDic = data;
        NSDictionary *paraDic = [returnDic objectForKey:@"para"];
        NSNumber *returnCodeNum = [paraDic objectForKey:@"returnCode"];
        NSInteger returnCodeInt = [returnCodeNum integerValue];
        
        //对情况进行解析
        if (returnCodeInt == 0) {
            //成功
            successBlock();
        }
        else if (returnCodeInt == 1)
        {
            //hmac
            errorBlock(EC_HMAC_VERIFY_ERROR);
        }
        else if (returnCodeInt == 2)
        {
            //token
            errorBlock(EC_TOKENERROR);
        }
        else if (returnCodeInt == 3)
        {
            //其他错误
            errorBlock(EC_FAILURE);
        }
        else
        {
            //服务器错误
            errorBlock(EC_SERVER_FAILURE);
        }
        
        
        
    } errorBlock:^(NSError *error) {
       
        //网络错误
        errorBlock(EC_NETWORK_UNACCESS);
    }];
}


#pragma mark - 6.数字签名

+ (void)digitalSignatrueWithPin:(NSString *)pin
                        orignal:(NSString *)orignal
           ifNeedBase64Decoding:(BOOL)isNeedBase64Decoding
                   successBlock:(void (^)(NSString *cipherText))successBlock
                     errorBlock:(void (^)(ResultCode))errorBlock
{
    //参数判断
    if (!pin || [pin isEqualToString:@""] || !orignal || [orignal isEqualToString:@""]) {
        errorBlock(EC_PARA_ERROR);
        return;
    }
    
    //判断初始化
    SecurityManager *securityManager = [SecurityManager sharedManager];
    if (!securityManager.userName || [securityManager.userName isEqualToString:@""]) {
        //未初始化
        errorBlock(EC_INIT_ERROR);
        return;
    }    
    
    //获取单例模式的privateKey
    //用pin-3DES-解密
    //用私钥加密orignal(注意情况：不能超过128-11=117个)，这个是随机值，所以应该是几十位数

    //获取证书
    LocalDataModel *localDataModel = [LocalDataManager getLocalModel];
    if (!localDataModel) {
        //本地无证书
        errorBlock(EC_NOCERT);
        return;
    }

    
    //验证PIN值
    BOOL pinIsRight = [LocalDataManager verifyPIN:pin];
    if (!pinIsRight) {
        errorBlock(EC_PIN_INVALID);
        return;
    }
    
    
    //不需要base64解密的签名
    if (!isNeedBase64Decoding) {
        NSString *signValue = [LocalDataManager signDataString:orignal withUserName:securityManager.userName pin:pin];
        if (!signValue || [signValue isEqualToString:@""]) {
            
            //加密失败
            errorBlock(EC_RSASIGN_FALURE);
            return;
        }
        successBlock(signValue);
    }
    
    //需要base64解密的，如哈希值
    else
    {
        NSString *signValue = [LocalDataManager signHashString:orignal userName:securityManager.userName pin:pin];
        if (!signValue || [signValue isEqualToString:@""]) {
            errorBlock(EC_RSASIGN_FALURE);
            return;
        }
        successBlock(signValue);
    }
    
}



#pragma mark - 7.获取文档下载链接

+ (void)getDocURLWithDocID:(NSString *)docID
              SuccessBlock:(void(^)(NSString *docURL))successBlock
                errorBlock:(void(^)(ResultCode errorCode))errorBlock
{
    //判断参数
    if (!docID || [docID isEqualToString:@""]) {
        errorBlock(EC_PARA_ERROR);
        return;
    }
    
    //判断初始化
    SecurityManager *security = [SecurityManager sharedManager];
    if (!security.token) {
        
        errorBlock(EC_INIT_ERROR);
        return;
    }
    NSString *token = [NSString stringWithFormat:@"%@",security.token];
    
    
    //请求参数
    NSString *transactionID = [JSSCommon getTransactionID];
    NSString *clearText = [NSString stringWithFormat:@"%@%@",transactionID,docID];
    NSString *hmac = [JSSCommon HMACMD5WithClearText:clearText];
    
    //参数字典
    NSMutableDictionary *paraDic = [[NSMutableDictionary alloc] init];
    [paraDic setObject:transactionID forKey:@"transactionID"];
    [paraDic setObject:docID forKey:@"docID"];
    [paraDic setObject:hmac forKey:@"hmac"];
    
    //请求字典
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setObject:@"DocumentDownloadReq" forKey:@"messageName"];
    [requestDic setObject:paraDic forKey:@"para"];
    
    //请求URL
    NSString *url = [ServerAddressManager getURLwithPortName:jDocumentDownload]; //jPostURL(jDocumentDownload);

    //发起请求
    CoreAPIManager *coreAPIManager = [CoreAPIManager sharedCoreAPIManager];
    [coreAPIManager postHttpRequestWithRUL:url token:token requestDic:requestDic successBlock:^(id data) {
        
        //解析字典
        ResultCode resultCode;
        
        NSDictionary *returnDic = data;
        NSDictionary *para = returnDic[@"para"];
        NSString *returnCode = [NSString stringWithFormat:@"%@",para[@"returnCode"]];

        if ([returnCode isEqualToString:@"000"]) {
            //成功
            NSString *docUrl = para[@"docUrl"];
            successBlock(docUrl);
            
        }
        else if ([returnCode isEqualToString:@"001"])
        {
            //hmac校验失败
            resultCode = EC_HMAC_VERIFY_ERROR;
            errorBlock(resultCode);
        }
        else if ([returnCode isEqualToString:@"002"])
        {
            //token错误
            resultCode = EC_TOKENERROR;
            errorBlock(resultCode);

        }
        else if ([returnCode isEqualToString:@"003"])
        {
            //文档不存在
            resultCode = EC_NOPDF;
            errorBlock(resultCode);

        }
        else if ([returnCode isEqualToString:@"004"])
        {
            //其他错误，分为服务器错误
            resultCode = EC_FAILURE;
            errorBlock(resultCode);

        }
        else
        {
            //为了防止服务器抽风返回其他数据，也定为服务器错误
            resultCode = EC_SERVER_FAILURE;
            errorBlock(resultCode);

        }
        
    } errorBlock:^(NSError *error) {
        
        //网络不行
        ResultCode resultCode = EC_NETWORK_UNACCESS;
        errorBlock(resultCode);
        //解析错误
    }];
    
}


#pragma mark - 8.电子签章


+ (void)docSignWithPin:(NSString *)pin
                 docID:(NSString *)docID
               keyWord:(NSString *)keyWord
                todoID:(NSString *)todoID
          successBlock:(void (^)())successBlock
             failBlock:(void (^)(ResultCode errorCode))errorBlock

{
    //检验参数
    if (!docID ||
        [docID isEqualToString:@""] ||
        !keyWord ||
        [keyWord isEqualToString:@""] ||
        !pin ||
        [pin isEqualToString:@""] || !todoID || [todoID isEqualToString:@""]) {
        errorBlock(EC_PARA_ERROR);
        return;
    }
    
    //检查初始化
    NSString *checkToken = [SecurityManager sharedManager].token;
    NSString *userName = [SecurityManager sharedManager].userName;
    if (!checkToken || [checkToken isEqualToString:@""] || !userName || [userName isEqualToString:@""]) {
        errorBlock(EC_INIT_ERROR);
        return;
    }
    
    //检查证书
    LocalDataModel *localDataModel = [LocalDataManager getLocalModel];
    if (!localDataModel) {
        //本地无证书
        errorBlock(EC_NOCERT);
        return;
    }
    //证书ID
    NSString *certNO = localDataModel.certNO;
    
    //检查pin是否正确
    if ([LocalDataManager verifyPIN:pin] == NO) {
        errorBlock(EC_PIN_INVALID);
        return;
    }
    
    //请求模式：1.关键词 2.坐标模式
    NSInteger positionType = 1;

    //base64编码！！！关键词需要base64编码
    NSData *keyWUTF8 = [keyWord dataUsingEncoding:NSUTF8StringEncoding];
    NSString *keyBase64 = [keyWUTF8 base64EncodedStringWithOptions:0];
    NSString *positionValue = keyBase64;
    
    //关键词模式下的页数可以不填
    NSInteger pageValue = 0;
    
    //参数
    NSString *transactionID = [JSSCommon getTransactionID];
    NSString *clearText = [NSString stringWithFormat:@"%@%@%ld%@%ld",transactionID,docID,positionType,positionValue,pageValue];
    NSString *hmac = [JSSCommon HMACMD5WithClearText:clearText];
    
    //参数字典
    NSMutableDictionary *paraDic = [[NSMutableDictionary alloc] init];
    [paraDic setObject:transactionID forKey:@"transactionID"];
    [paraDic setObject:docID forKey:@"docID"];
    [paraDic setObject:[NSNumber numberWithInteger:positionType] forKey:@"positionType"];
    [paraDic setObject:positionValue forKey:@"positionValue"];
    [paraDic setObject:[NSNumber numberWithInteger:pageValue] forKey:@"pageValue"];
    [paraDic setObject:hmac forKey:@"hmac"];
    
    //请求字典
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setObject:paraDic forKey:@"para"];
    [requestDic setObject:@"GetSignPositionReq" forKey:@"messageName"];
    
    NSString *url = [ServerAddressManager getURLwithPortName:jGetSignPosition]; //jPostURL(jGetSignPosition);
    NSString *token = [SecurityManager sharedManager].token;
    CoreAPIManager *coreManager = [CoreAPIManager sharedCoreAPIManager];
    [coreManager postHttpRequestWithRUL:url token:token requestDic:requestDic successBlock:^(id data) {
       
        //获取到的位置数组
        NSDictionary *returnDic = data;
        NSDictionary *paraDic = [returnDic objectForKey:@"para"];
        NSNumber *returnCodeNum = [paraDic objectForKey:@"returnCode"];
        NSInteger returnCodeInt = [returnCodeNum integerValue];
        if (returnCodeInt == 0) {
            
            //成功~~怎么返回的是字典
            NSArray *positionSizeArray = [paraDic objectForKey:@"matchItems"];
            //将数组传入一个线程
            //如何并发多个返回一个结果????串行
            if(positionSizeArray.count <= 0)
            {
                //关键词对应的数据是为空
                errorBlock(EC_KEYWORD_NO_POSITION);
                return;
            }
            
            //发起一个签名线程
            CoreAPIManager *coreAPIManager = [CoreAPIManager sharedCoreAPIManager];
            [coreAPIManager docSignWithDocID:docID userName:userName pin:pin certNO:certNO token:token todoID:todoID positionArray:positionSizeArray successBlock:^{
                
                //成功签完全部x
                successBlock();
                
            } failBlock:^(ResultCode resultCode) {
                
                //错误
                errorBlock(resultCode);
                
            }];
            
        }
        else if (returnCodeInt == 1)
        {
            //hmac失败
            errorBlock(EC_HMAC_VERIFY_ERROR);
        }
        else if (returnCodeInt == 2)
        {
            //token失败
            errorBlock(EC_TOKENERROR);
        }
        else if (returnCodeInt == 3)
        {
            //文档不存在
            errorBlock(EC_NOPDF);
        }
        else if (returnCodeInt == 4)
        {
            //其他错误
            errorBlock(EC_FAILURE);
        }
        else
        {
            //服务器错误
            errorBlock(EC_SERVER_FAILURE);
        }
        
        
        
    } errorBlock:^(NSError *error) {
        
    
        DebugLog(@"获取位置网络error = %@",error);
        //网络不给力
        errorBlock(EC_NETWORK_UNACCESS);
    }];
    
}


#pragma mark - XY坐标加密

+ (void)docSignWithPin:(NSString *)pin
                 docID:(NSString *)docID
                     x:(CGFloat)x
                     y:(CGFloat)y
             pageValue:(NSInteger)pageValue
                todoID:(NSString *)todoID
          successBlock:(void (^)())successBlock
             failBlock:(void (^)(ResultCode))errorBlock
{
    //检查参数
    if (!pin || [pin isEqualToString:@""] || !docID || [docID isEqualToString:@""]) {
        errorBlock(EC_PARA_ERROR);
        return;
    }
    
    //检查参数
    if (x < 0 || y < 0 || pageValue <=0) {
        errorBlock(EC_PARA_ERROR);
        return;
    }
    
    //检查初始化
    NSString *checkToken = [SecurityManager sharedManager].token;
    NSString *userName = [SecurityManager sharedManager].userName;
    if (!checkToken || [checkToken isEqualToString:@""] || !userName || [userName isEqualToString:@""]) {
        errorBlock(EC_INIT_ERROR);
        return;
    }
    
    //检验证书
    LocalDataModel *localDataModel = [LocalDataManager getLocalModel];
    if (!localDataModel) {
        errorBlock(EC_NOCERT);
        return;
    }
    //证书ID
    NSString *certNO = localDataModel.certNO;
    
    //检查pin是否正确
    if ([LocalDataManager verifyPIN:pin] == NO) {
        errorBlock(EC_PIN_INVALID);
        return;
    }

    
    //装进数组调用通用接口
    NSMutableDictionary *positionDic = [[NSMutableDictionary alloc] init];
    [positionDic setObject:[NSNumber numberWithFloat:x] forKey:@"x"];
    [positionDic setObject:[NSNumber numberWithFloat:y] forKey:@"y"];
    [positionDic setObject:[NSNumber numberWithInteger:pageValue] forKey:@"pageNum"];
    //只有一个位置的字典，套用
    NSArray *positionsArray = @[positionDic];
    
    
    //发起线程
    CoreAPIManager *coreAPIManager = [CoreAPIManager sharedCoreAPIManager];
    [coreAPIManager docSignWithDocID:docID
                            userName:userName
                                 pin:pin
                              certNO:certNO
                               token:checkToken todoID:todoID
                       positionArray:positionsArray successBlock:^{
        
        successBlock();
        
    } failBlock:^(ResultCode resultCode) {
       
        errorBlock(resultCode);
    }];
    
}




#pragma mark - 9.查看电子签章详情

+ (void)querySignInfoWithDocID:(NSString *)docID
                  successBlock:(void (^)(NSArray<SignInfoModel *> *))successBlock
                    errorBlock:(void (^)(ResultCode))errorBlock
{
    //初始化检验
    SecurityManager *securityManager = [SecurityManager sharedManager];
    NSString *token = securityManager.token;
    if (!token || [token isEqualToString:@""]) {
        errorBlock(EC_INIT_ERROR);
        return;
    }
    
    //参数检验
    if (!docID || [docID isEqualToString:@""]) {
        errorBlock(EC_PARA_ERROR);
        return;
    }
    

    //参数
    NSString *transactionID = [JSSCommon getTransactionID];
    NSString *clearText = [NSString stringWithFormat:@"%@%@",transactionID,docID];
    NSString *hmac = [JSSCommon HMACMD5WithClearText:clearText];
    
    //参数字典
    NSMutableDictionary *paraDic = [[NSMutableDictionary alloc] init];
    [paraDic setObject:transactionID forKey:@"transactionID"];
    [paraDic setObject:docID forKey:@"docID"];
    [paraDic setObject:hmac forKey:@"hmac"];
    
    //请求字典
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setObject:paraDic forKey:@"para"];
    [requestDic setObject:@"GetSignInfoReq" forKey:@"messageName"];
    
    //查看电子签章详情地址
    NSString *url = [ServerAddressManager getURLwithPortName:jGetSignInfo]; //jPostURL(jGetSignInfo);
    
    
    //发起网络请求
    CoreAPIManager *coreManager = [CoreAPIManager sharedCoreAPIManager];
    [coreManager postHttpRequestWithRUL:url token:token requestDic:requestDic successBlock:^(id data) {
        
        NSDictionary *returnDic = data;
        NSDictionary *paraDic = [returnDic objectForKey:@"para"];
        NSNumber *returnCodeNum = [paraDic objectForKey:@"returnCode"];
        NSInteger returnCodeInt = [returnCodeNum integerValue];
        
        if (returnCodeInt == 0) {
            
            //后台返回的数组
            NSArray *signInfoArray = [paraDic objectForKey:@"signInfo"];
            //解析后返回给用户的数组
            NSMutableArray<SignInfoModel *> *signInfoMuArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < signInfoArray.count; i++) {
                
                //解析成签章模型
                NSDictionary *signDic = signInfoArray[i];
                SignInfoModel *signInfoModel = [[SignInfoModel alloc] init];
                
                
                signInfoModel.userName = signDic[@"userName"];
                
                NSNumber *typeNum = signDic[@"signType"];
                signInfoModel.userType = [typeNum integerValue];
                
                //注意这个
                NSString *signDate = signDic[@"signDate"];
                signInfoModel.signDate = signDate;
                
                //签章证书
                NSString *certificate = signDic[@"certificate"];
                signInfoModel.certificate = certificate;
                
                //章的序列号
                NSString *certNO = [[OpensslUtil sharedOpensslUtil] x509SerialNumWithDataString:certificate];
                signInfoModel.certNO = certNO;
                
                //图片
                NSString *signPicStr = signDic[@"signPic"];
                signInfoModel.signPic = signPicStr;
                
                signInfoModel.signArea = signDic[@"signArea"];
            
                [signInfoMuArray addObject:signInfoModel];
                
            }
            successBlock(signInfoMuArray);
            
            //成功
        }
        else if (returnCodeInt == 1)
        {
            //hmac失败
            errorBlock(EC_HMAC_VERIFY_ERROR);
            
        }
        else if (returnCodeInt == 2)
        {
            //token校验失败
            errorBlock(EC_TOKENERROR);
        }
        else if (returnCodeInt == 3)
        {
            //文档不存在
            errorBlock(EC_NOPDF);
        }
        else if (returnCodeInt == 4)
        {
            //其他错误
            errorBlock(EC_FAILURE);
        }
        else
        {
            //其他错误：服务器
            errorBlock(EC_SERVER_FAILURE);
        }
        
        
    } errorBlock:^(NSError *error) {
        
        //网络错误
        errorBlock(EC_NETWORK_UNACCESS);
        
    }];
    
}


#pragma mark - 10.电子签章验证

+ (void)signInfoVerifyWithDocID:(NSString *)docID
                       signArea:(NSString *)signArea
                   successBlock:(void (^)())successBlock
                     errorBlock:(void (^)(ResultCode errorCode))errorBlock
{
    //初始化检验
    SecurityManager *securityManager = [SecurityManager sharedManager];
    NSString *token = securityManager.token;
    if (!token || [token isEqualToString:@""]) {
        errorBlock(EC_INIT_ERROR);
        return;
    }
    
    //参数检查
    if (!docID || !signArea || [docID isEqualToString:@""] || [signArea isEqualToString:@""]) {
        errorBlock(EC_PARA_ERROR);
        return;
    }
    
    //参数
    NSString *transactionID = [JSSCommon getTransactionID];
    NSString *clearText = [NSString stringWithFormat:@"%@%@%@",transactionID,docID,signArea];
    NSString *hmac = [JSSCommon HMACMD5WithClearText:clearText];
    
    //参数字典
    NSMutableDictionary *paraDic = [[NSMutableDictionary alloc] init];
    [paraDic setObject:transactionID forKey:@"transactionID"];
    [paraDic setObject:docID forKey:@"docID"];
    [paraDic setObject:signArea forKey:@"signArea"];
    [paraDic setObject:hmac forKey:@"hmac"];
    
    //请求字典
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setObject:paraDic forKey:@"para"];
    [requestDic setObject:@"SignInfoVerifyReq" forKey:@"messageName"];
    
    //请求地址
    NSString *url = [ServerAddressManager getURLwithPortName:jSignInfoVerify]; //jPostURL(jSignInfoVerify);
    
    //发起请求
    CoreAPIManager *coreManager = [CoreAPIManager sharedCoreAPIManager];
    [coreManager postHttpRequestWithRUL:url token:token requestDic:requestDic successBlock:^(id data) {
        
        //解析返回的数据
        NSDictionary *returnDic = data;
        NSDictionary *paraDic = [returnDic objectForKey:@"para"];
        
        NSNumber *returnCodeNum = [paraDic objectForKey:@"returnCode"];
        NSInteger returnCodeInt = [returnCodeNum integerValue];
        
        switch (returnCodeInt) {
            case 0:
                //成功
                successBlock();
                break;
                
            case 1:
                //hmac失败
                errorBlock(EC_HMAC_VERIFY_ERROR);
                break;
                
            case 2:
                //token检验失败
                errorBlock(EC_TOKENERROR);
                break;
                
            case 3:
                //签章认证失败
                errorBlock(EC_SIGNINFOVerify_FAILIRE);
                break;
                
            case 4:
                //文档不存在
                errorBlock(EC_NOPDF);
                break;
                
            case 5:
                //其他错误
                errorBlock(EC_FAILURE);
                break;

            default:
                //其他也表示为服务器错误
                errorBlock(EC_SERVER_FAILURE);
                break;
        }
        
        
    } errorBlock:^(NSError *error) {
        //网络不行
        errorBlock(EC_NETWORK_UNACCESS);
    }];
    
}

@end
