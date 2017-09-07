//
//  ViewController.m
//  JiangsuSDK
//
//  Created by Luo on 16/11/23.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import "ViewController.h"
#import "JSSNetworking.h"

#import "SecurityManager.h"
#import "JSSCommon.h"
#import "ThreeDes.h"
#import "MyRSA.h"

#import "GTMBase64.h"

#import "CoreAPIManager.h"

#import "LocalDataModel.h"

//----以下包含openssl----
#import "OpensslUtil.h"

//存储信息（密码等）在chainkey里
#import <Security/Security.h>

#import "LocalDataManager.h"


#import "InitSDKViewController.h"
#import "GetMessageCodeViewController.h"
#import "CertStateQueryViewController.h"
#import "CertApplyViewController.h"
#import "DocURL_SignVC.h"
#import "DocSignViewController.h"
#import "XYSignViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
    
    //功能数组
    NSArray *_functionsTitleArray;
    
    
    //RSA生成的公钥私钥
    NSString *_publicKey;
    NSString *_privateKey;
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //做个假的证书
    [self initCert];
    
    
    //判断存储的私钥正确性
    //[self opensslProvideKeys];
    

    //发签章请求hmac失败--检验
    //[self signVerify];
    //[self signAndVeritfy];
    
    //验证Java生成的密钥对
    //[self javaSignVerify];
    
    
    //----base64String的解码---
    NSString *basedStr = @"QVNEQVNEQVNEVzEyMTIzMTI=";
    NSString *decodedStr = [JSSCommon base64DecodingWithBasedString:basedStr];
    NSLog(@"base64解密 = %@",decodedStr);
    
    
    
    
    self.title = @"电子签章SDK";
    self.view.backgroundColor = [UIColor whiteColor];
    
    _functionsTitleArray = @[@"初始化",
                             @"获取验证码",
                             @"证书查询",
                             @"证书申请",
                             @"下载链接+签名+查看详情",
                             @"关键词电子签章 + 验证",
                             @"XY坐标签章"
                             ];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    
    
    [self.view addSubview:_tableView];
    
    
//    [SecurityManager docSignWithPin:@"123456" docID:@"20161221001" x:100 y:300 pageValue:7 successBlock:^{
//        NSLog(@"成功");
//    } failBlock:^(ResultCode errorCode) {
//        
//        NSLog(@"失败吗=%ld",errorCode);
//    }];
//
    
}


#pragma mark - 表格

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _functionsTitleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseID = @"reuseCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
    }
    cell.textLabel.text = _functionsTitleArray[indexPath.row];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSInteger row = indexPath.row;
    
    if (row == 0) {
        
        //初始化
        InitSDKViewController *initVC = [[InitSDKViewController alloc] init];
        initVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:initVC animated:YES];
        
    }
    
    //获取验证码
    else if (row == 1)
    {
        //获取验证码
        GetMessageCodeViewController *getMCVC = [[GetMessageCodeViewController alloc] init];
        getMCVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:getMCVC animated:YES];
    }
    
    
    
    else if (row == 2)
    {
        //证书查询
        CertStateQueryViewController *certStateQueryStateVC = [[CertStateQueryViewController alloc] init];
        certStateQueryStateVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:certStateQueryStateVC animated:YES];

    }
    
    
    //签名与验证
    else if (row == 3)
    {
        
        //证书申请
        CertApplyViewController *certApplyVC = [[CertApplyViewController alloc] init];
        certApplyVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:certApplyVC animated:YES];

        
    }
    
    
    else if (row == 4)
    {
        
        
        //下载链接+签名+查看详情
        DocURL_SignVC *doc_SignVC = [[DocURL_SignVC alloc] init];
        doc_SignVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:doc_SignVC animated:YES];

    }
    
    
    else if (row == 5)
    {

        
        //关键词电子签章 + 验证
        DocSignViewController *dockeyWordSignVC = [[DocSignViewController alloc] init];
        dockeyWordSignVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:dockeyWordSignVC animated:YES];


    }

    else if (row == 6)
    {
        //XY坐标签章
        XYSignViewController *xySignVC = [[XYSignViewController alloc] init];
        xySignVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:xySignVC animated:YES];
    }

}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



#pragma mark - 签名和认证
- (void)signAndVeritfy
{
    OpensslUtil *opensslUtil = [OpensslUtil sharedOpensslUtil];
    NSString *privateKey = @"MIICXAIBAAKBgQC6Grm+cA2GUA0YYIKMPUVKkREbti/URZBL/SRSFpT38wCffZCvbkaDGDJpN+IiwcEAqWBNoSZq+3IB6mhYwsrXOVJJQ8PdeBnb68SXqEqGsvD4Rz0uLAdi+ZcunnZ27xSLNJhdVyx/ge+cys2tMrrSodBW7nGicYfvEmEAaqHlkwIDAQABAoGBAI+TDrlcuRJlr7SewBhxLIPaZth6NWwOPsRhByRNR6ACWPiyZmzxJnT8ted2tX8a+0sHYMSDDqB6W/oeXWIc5V7Sdq6qUmbvIA7VOiuE2TqaI/Dh6HRxRfesxu1efbQXb0YBt5igky8TcF+E65xbyPUHDcIcja7TXIsqd+ii0VgBAkEA9A5NoNFGj8U5w7LEF7Uw7eNDYazwwDmq5qZES8w+FLwd+HaBYiMPF7nIBHcTCWbxxppittMgpFQPQZr5ouWPKQJBAMM2XfsVf+RoFjiM9j5AHM0ACmqetYN80raX/jl+tIiBbptqUCtBa66/8Vhtw+0weMFFyTp0pZqX2fJ1kLDCMlsCQAN3jIzDTFBQifCIwpZfoZFPkC58CXOBnjbml8PH4/3haj+UV2QwgU9h+UBu/Js+liKvIMXeG/GZrBnPfMpennkCQAMxcHga8eyah0KFi8GY6t+vkHwN/IoaEJhMBCyMlgdllpmUM5uBhnFlUl1P7lSC5nbC3XfHUK4mrbn5klRR2OECQFScbKgYMt7HKWcjWsqLw/w2pxyscnL8vnF5HQM/bYuPpNHLi/cQFWw8mP9Y7zBSRZLrwQgrnTYST5JhY1YZt90=";
    
    //privateKey =[JSSCommon base64EncodingWithClearText:privateKey];
    
    
    NSString *data = @"ABCDEFGHIJ";
    //data = [JSSCommon base64EncodingWithClearText:data];
    NSString *hashAlg = @"sha1";
    NSString *signedDataStr =[opensslUtil signWithPrivateKey:privateKey data:data hashAlg:hashAlg];
    NSLog(@"签名后=%@",signedDataStr);
    if (!signedDataStr) {
        
        NSLog(@"签名为空,私钥错误");
        return;
    }
    
    NSString *publicKey = @"MIGJAoGBALoaub5wDYZQDRhggow9RUqRERu2L9RFkEv9JFIWlPfzAJ99kK9uRoMYMmk34iLBwQCpYE2hJmr7cgHqaFjCytc5UklDw914GdvrxJeoSoay8PhHPS4sB2L5ly6ednbvFIs0mF1XLH+B75zKza0yutKh0FbucaJxh+8SYQBqoeWTAgMBAAE=";
    
    
    
    NSData *dataUTF8 = [data dataUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char *dataBytes = (unsigned char *)[dataUTF8 bytes];
    size_t dataLeng = strlen((char *)dataBytes);
    NSLog(@"原文长度=%d",(int)dataLeng);
    
    
    NSData *signUTF8 = [signedDataStr dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char *signBytes = (unsigned char *)[signUTF8 bytes];
    size_t signLen = strlen((char *)signBytes);
    NSLog(@"签名之后的长度=%d",(int)signLen);
    
    BOOL right = NO;
    if ([hashAlg isEqualToString:@"sha1"]) {
        
        //为什么传入172定长就可以
        right = [opensslUtil verifySha1:publicKey data:dataBytes length:(int)50 signData:signBytes length:(int)172];
        
        
    }
    else if ([hashAlg isEqualToString:@"md5"])
    {
        right = [opensslUtil verifymd5:publicKey data:dataBytes length:(int)50 signData:signBytes length:(int)172];
    }
    if (right) {
        NSLog(@"成");
    }else
    {
        NSLog(@"签名不正确");
    }
}


- (void)initCert
{

    NSString *privateKey = @"MIICXAIBAAKBgQC6Grm+cA2GUA0YYIKMPUVKkREbti/URZBL/SRSFpT38wCffZCvbkaDGDJpN+IiwcEAqWBNoSZq+3IB6mhYwsrXOVJJQ8PdeBnb68SXqEqGsvD4Rz0uLAdi+ZcunnZ27xSLNJhdVyx/ge+cys2tMrrSodBW7nGicYfvEmEAaqHlkwIDAQABAoGBAI+TDrlcuRJlr7SewBhxLIPaZth6NWwOPsRhByRNR6ACWPiyZmzxJnT8ted2tX8a+0sHYMSDDqB6W/oeXWIc5V7Sdq6qUmbvIA7VOiuE2TqaI/Dh6HRxRfesxu1efbQXb0YBt5igky8TcF+E65xbyPUHDcIcja7TXIsqd+ii0VgBAkEA9A5NoNFGj8U5w7LEF7Uw7eNDYazwwDmq5qZES8w+FLwd+HaBYiMPF7nIBHcTCWbxxppittMgpFQPQZr5ouWPKQJBAMM2XfsVf+RoFjiM9j5AHM0ACmqetYN80raX/jl+tIiBbptqUCtBa66/8Vhtw+0weMFFyTp0pZqX2fJ1kLDCMlsCQAN3jIzDTFBQifCIwpZfoZFPkC58CXOBnjbml8PH4/3haj+UV2QwgU9h+UBu/Js+liKvIMXeG/GZrBnPfMpennkCQAMxcHga8eyah0KFi8GY6t+vkHwN/IoaEJhMBCyMlgdllpmUM5uBhnFlUl1P7lSC5nbC3XfHUK4mrbn5klRR2OECQFScbKgYMt7HKWcjWsqLw/w2pxyscnL8vnF5HQM/bYuPpNHLi/cQFWw8mP9Y7zBSRZLrwQgrnTYST5JhY1YZt90=";
    NSString *publicKey = @"MIGJAoGBALoaub5wDYZQDRhggow9RUqRERu2L9RFkEv9JFIWlPfzAJ99kK9uRoMYMmk34iLBwQCpYE2hJmr7cgHqaFjCytc5UklDw914GdvrxJeoSoay8PhHPS4sB2L5ly6ednbvFIs0mF1XLH+B75zKza0yutKh0FbucaJxh+8SYQBqoeWTAgMBAAE=";
    NSString *certificate = @"MIICCzCCAXagAwIBAgIEASvlPDALBgkqhkiG9w0BAQUwKjELMAkGA1UEBhMCQ04xGzAZBgNVBAMMEkNNQ0EgSW5kaXZpZHVhbCBDQTAeFw0xNjEyMTYwMTI1MjlaFw0xNzEyMTYwMTI1MjlaMEAxCzAJBgNVBAYTAkNOMRowGAYDVQQFExEyMDE2MTIxNjA5MjUyODc0ODEVMBMGA1UEAwwM5Y2T5pyb5YWs5Y+4MIGdMAsGCSqGSIb3DQEBAQOBjQAwgYkCgYEAuhq5vnANhlANGGCCjD1FSpERG7Yv1EWQS/0kUhaU9/MAn32Qr25GgxgyaTfiIsHBAKlgTaEmavtyAepoWMLK1zlSSUPD3XgZ2+vEl6hKhrLw+Ec9LiwHYvmXLp52du8UizSYXVcsf4HvnMrNrTK60qHQVu5xonGH7xJhAGqh5ZMCAwEAAaMuMCwwCwYDVR0PBAQDAgeAMB0GA1UdDgQWBBQCSofuzgVLfXODkEJxsg9uBM6kfDALBgkqhkiG9w0BAQUDgYEABNcL56BmWPd4dq7uyyst09V6l8bRS0ivcxzfoRpuppViztcF9VnfS+urlXNkFxqm0/G8MeuTW+VenYe/wwSN2UnPCQ803ZsWyVHT+cjWV2lF3k7OfE49qptV4hd88X2sC9IZvA+kyPFxf9qMxacs1Yb8upuaOJHtxUM4XCazjlM=";

    //手动初始化
    [LocalDataManager initSharedLocalDataManagerWithUserName:@"aspire"];
    LocalDataModel *localDataModel = [[LocalDataModel alloc] init];
    localDataModel.userName = @"aspire";
    
    //以pin算出3DES密钥，再用3des加密私钥
    NSString *tripleKey = [ThreeDes getTripleDesKeyWithUserPin:@"123456"];
    NSString *tripleCipherPrivateKey = [ThreeDes threeDesEncrypttWithKey:tripleKey clearText:privateKey];
    localDataModel.privateKey = tripleCipherPrivateKey;
    
    OpensslUtil *opensslU = [OpensslUtil sharedOpensslUtil];
    localDataModel.certNO = [opensslU x509SerialNumWithDataString:certificate];
    localDataModel.certHashAlg = [opensslU getHashAlgWithCertDataString:certificate];
    localDataModel.cert = certificate;
    localDataModel.publicKey = publicKey;

    
    //存入本地
    [LocalDataManager updateLocalDataModel:localDataModel];
    
    
    
    //手动初始化
    //http://10.1.4.74:8088/essportal/
    [SecurityManager initSDKWithToken:@"YXNwaXJlIzEwLjEuMTE2LjE1NyNMYUs2VUYjMTQ4MTA5OTg0ODExNiMxNDk5MDk5ODQ4MTE2I0ZYVS9aUUFKY3dCMmRFRzc3SjAyM2c9PQ==" userName:@"aspire" serverAddress:@"http://211.139.191.152:8088/essportal/" successBlock:^{
    
        } errorBlock:^(ResultCode resultCode) {
    
        }];
}


//分析返回的证书串
- (void)readReturnCertStr
{
    //NSString *returnCert = @"MIICCzCCAXagAwIBAgIEASvi6jALBgkqhkiG9w0BAQUwKjELMAkGA1UEBhMCQ04xGzAZBgNVBAMMEkNNQ0EgSW5kaXZpZHVhbCBDQTAeFw0xNjEyMDkwODA4MDJaFw0xNzEyMDkwODA4MDJaMEAxCzAJBgNVBAYTAkNOMRowGAYDVQQFExEyMDE2MTIwOTE2MDgwMjIyNDEVMBMGA1UEAwwM5Y2T5pyb5YWs5Y+4MIGdMAsGCSqGSIb3DQEBAQOBjQAwgYkCgYEAux8RikagrLTDrt5vOH+CegBRcvCeifFejwN4xMNvhAyoOUwdVUtSvnr5+dnxiuLg+VCszrONLRwkOoYg+3iK3DnffgII2DGZIcWOsZo+8nvpB6gZVvFBIWHg+nr19i3zRe4dTKGGoONn1DWP68xVNnZrrYaWtubALa742KK9rfsCAwEAAaMuMCwwCwYDVR0PBAQDAgeAMB0GA1UdDgQWBBQM+Sjf0WObPQ4YTPT3CljlVeAyrzALBgkqhkiG9w0BAQUDgYEAJnuq1bNSAIr09hHM3m9eJD/IL0NHFojdgqWTxyIEezvqKlj582H/yX/BGdRTjaw2zbvxpmOe5PibPIFfZ4CV52j88hvz5KcT2rGai2ttd8eYa+YtR79QadV6MovfBxzuW/w2NUtGJzqGQ8ZxnHAww7rP+Qj0Zt453Q3Rr3LgMr4=";
    
       NSString *firstCertStr = @"MIICCzCCAXagAwIBAgIEASvkcjALBgkqhkiG9w0BAQUwKjELMAkGA1UEBhMCQ04xGzAZBgNVBAMMEkNNQ0EgSW5kaXZpZHVhbCBDQTAeFw0xNjEyMTQwMTQxMjdaFw0xNzEyMTQwMTQxMjdaMEAxCzAJBgNVBAYTAkNOMRowGAYDVQQFExEyMDE2MTIxNDA5NDEyNzMxMTEVMBMGA1UEAwwM5Y2T5pyb5YWs5Y+4MIGdMAsGCSqGSIb3DQEBAQOBjQAwgYkCgYEA5bVTLaI7ShU5xwoTCGEUXA7VV8dFLrG9TQSSZyEEIo8KbP/BXzl7tcbd4vnb6HOkfgpDnk2P+HFf6lRT4oDJzGQvHbe2z2fG2TGic8xIZ/Dl/YkZm9GOw3ecdOEN5g1FCTJdvFS7oJ0X9O58YbjPRlH5t1M+TCUr4md3t46XTW0CAwEAAaMuMCwwCwYDVR0PBAQDAgeAMB0GA1UdDgQWBBT5GDF0uKEfI5BzXMKmIEdAvs9YSTALBgkqhkiG9w0BAQUDgYEAQrdtaF3AJvnyuodgLipcteucprNhBCKyf6nr8tVSX1O4SBbyTGX2zly4Dcy1qoMAt7O14afL4aWPub/C3ZpLp8CxBiLfeB7uRuqGxDQ/jZ1g7g8Br2UjHrvc4ee6Wal96okWuCGBJU4GAWdCG0Xzk2DF0GHWortZ27DnfQZD5c0=";
    
    
    //NSData *certData = [GTMBase64 decodeString:returnCert];
    
    OpensslUtil *opensslUtil = [OpensslUtil sharedOpensslUtil];
    [opensslUtil x509SerialNumWithDataString:firstCertStr];
    NSString *alg = [opensslUtil getHashAlgWithCertDataString:firstCertStr];
}

//openssl生成密钥对，公钥加密，私钥解密
- (void)opensslProvideKeys
{
    OpensslUtil *opensslUtil = [OpensslUtil sharedOpensslUtil];
    [opensslUtil generateKeyPairRSA:1024 block:^(NSString *publicKey, NSString *privateKey) {
        
        
        _privateKey = privateKey;
        _publicKey = publicKey;
        
        
        
       // privateKey = @"=MIICXAIBAAKBgQDO0F61tRdpqaULI7AuDiW5Io7Gwyky8ID4SEcmaCxYG1X6AzhUa5XQcFb7ifIY2jA39ZM1bjn3FzELkGuu3SyNgVL2ZYOJP83JLgp6Q04fuqgpCCe6z/kQkUErTObhL2oQF8fwZkUYpMJa8+mT9ERuSrZTzVxtiwI42n28V+A1XQIDAQABAoGAFvkujCDBqQsfOk2MlJEdv6MHGS00tmPg77OXs7x+sIrY0hzpdPc+fRj9kJOSQRB7qruszpKf/cKlwBMa4yHOgPZj+8FA8FEPyAqlVoVPhf/l09eA4AHU1uJEVcTkAYmPyPsFKkMwm159fEaLdsQT6FeI9aTajCiAH8q1FvZ6+gECQQDvQZ7sBIXr/VIvvHZB3d/672c3zFah5O6Y27WB7PuVyXfjjSNM2drfXEbWes5vRlsFRdS9rsRaph7G/RFINx1lAkEA3UmHrWADQc508FS57PiSehn2O6elWcs++kCbKkfgnzUKmiHb/yfGhhJt/sczP/mzOHP4qvWklKPT7aJeIrjUmQJAN9Ob/X5gsVv+nVzgSyY2aRsLfp2TaVs9wTUi+RoO6jiEXPhF0FzVEWE6tjkZiiVkf6p3pXruHii87bmHGs6hcQJBAJO3Vd6iTQpMqzsTE9ngRMdFNV21F2fNiQi8v9eFi6g7XAxvtc+p2Zf+DXcZulhmcwCoScK1n1up0Pq8fGJpR2ECQGes2ofUz5VEm568+hbYVJbEbeb+4/pOSi9HF1ao6fWjzG9173SVxpQ7RHY2O2UAsJQ1hqRaaLjHaTl3MhJFahw=";
        
       // publicKey = @"=MIGJAoGBAM7QXrW1F2mppQsjsC4OJbkijsbDKTLwgPhIRyZoLFgbVfoDOFRrldBwVvuJ8hjaMDf1kzVuOfcXMQuQa67dLI2BUvZlg4k/zckuCnpDTh+6qCkIJ7rP+RCRQStM5uEvahAXx/BmRRikwlrz6ZP0RG5KtlPNXG2LAjjafbxX4DVdAgMBAAE=";
          // NSString *publicKey = @"MIGJAoGBALoaub5wDYZQDRhggow9RUqRERu2L9RFkEv9JFIWlPfzAJ99kK9uRoMYMmk34iLBwQCpYE2hJmr7cgHqaFjCytc5UklDw914GdvrxJeoSoay8PhHPS4sB2L5ly6ednbvFIs0mF1XLH+B75zKza0yutKh0FbucaJxh+8SYQBqoeWTAgMBAAE=";
        
        

        
        
        
        NSString *clearText = @"签名原文";//加密较短的时候还会返回null
        NSData *data = [clearText dataUsingEncoding:NSUTF8StringEncoding];
        unsigned char *keyDataStr = (unsigned char *)[data bytes];
        size_t len0 = strlen((char *)keyDataStr);
        //密钥对生成有误？
        //确实是同一个公钥：每次加密的结果都不一样。明文的长度不可以超过公钥的长度----加密没问题！！！
        NSData *dataA = [opensslUtil encryptionByRSA:publicKey data:keyDataStr length:len0];
        
        NSData *datax = [GTMBase64 encodeData:dataA];///???? 不用加这一步
        
        //utf8的char数组进去，出来也是utf8（c++），转成NSDATA后需要先base64,再utf8变string
        
        NSString *readStr = [[NSString alloc] initWithData:datax encoding:NSUTF8StringEncoding];
        
        NSLog(@"加密之后的长度 = %ld  数值=%@",readStr.length,readStr);
        //解密
        
        NSData *datay = [readStr dataUsingEncoding:NSUTF8StringEncoding];
        unsigned char *cipherData = (unsigned char *)[dataA bytes];
        size_t len = strlen((char *)cipherData);
        NSLog(@"密文utf8->btyes[]长度=%d",(int)len);
        //传定长128，因为不知名原因
        NSData *returnData =[opensslUtil decryptionByRSA:privateKey data:cipherData length:128];
        NSString *returnStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        NSLog(@"解密之后：%@",returnStr);
        
        
        privateKey = @"z/kQkUErTObhL2oQF8fwZkUYpMJa8+mT9ERuSrZTzVxtiwI42n28V+A1XQIDAQABAoGAFvkujCDBqQsfOk2MlJEdv6MHGS00tmPg77OXs7x+sIrY0hzpdPc+fRj9kJOSQRB7qruszpKf/cKlwBMa4yHOgPZj+8FA8FEPyAqlVoVPhf/l09eA4AHU1uJEVcTkAYmPyPsFKkMwm159fEaLdsQT6FeI9aTajCiAH8q1FvZ6+gECQQDvQZ7sBIXr/VIvvHZB3d/672c3zFah5O6Y27WB7PuVyXfjjSNM2drfXEbWes5vRlsFRdS9rsRaph7G/RFINx1lAkEA3UmHrWADQc508FS57PiSehn2O6elWcs++kCbKkfgnzUKmiHb/yfGhhJt/sczP/mzOHP4qvWklKPT7aJeIrjUmQJAN9Ob/X5gsVv+nVzgSyY2aRsLfp2TaVs9wTUi+RoO6jiEXPhF0FzVEWE6tjkZiiVkf6p3pXruHii87bmHGs6hcQJBAJO3Vd6iTQpMqzsTE9ngRMdFNV21F2fNiQi8v9eFi6g7XAxvtc+p2Zf+DXcZulhmcwCoScK1n1up0Pq8fGJpR2ECQGe";
        
        NSString *signHip = [opensslUtil signWithPrivateKey:privateKey data:@"xxxxxxxxx" hashAlg:@"sha1"];
        NSLog(@"签名之后=%@",signHip);
        
    }];

}


- (void)javaSignVerify
{
    for (int i = 0; i < 10; i++) {
        
        OpensslUtil *opensslUtil = [OpensslUtil sharedOpensslUtil];
        [opensslUtil generateKeyPairRSA:1024 block:^(NSString *publicKey, NSString *privateKey) {
           
            
            
            //---秦新梅的数据
            //privateKey = @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBALKUCM21PIhZHXvnydt+anyK1TbreVnjCOQYiPsSL7KyaWPdsYeHiqZzgnlgTTACzD4Zrk6m3Ym1Jtw8plvpqUk8idrhqdNzfhzr87Kx6j7TlZMHrc54gksnZYQjpAMyairf68w1G1SbtoZEhqDq/z/8fo4bEk9sqeYHeyCR9HPzAgMBAAECgYAsPDM6EYzfEYQWL0J3Voc2NoW+RvIWbADFz7YOy2B5WWx1ynKxacfUl4RYYJx+KhNBxsbAwODbvb3UjEmBNw4xpZ8B6oJUUEsByarqtvnyB5pGJSqHX+K8uFXN9FBEurk33mR6DiCncdBzmx66jFlrlBbMZK1KCekqr/hgZguQAQJBAOsnm5lr8QABVyiNZPRuZm7fNniBIlye7Y/O1VLbdjs8JaRydaQCNyR+EQzD1iQ6OLJrw3RLLJc7Ryw+KOJ/l/MCQQDCaIfcR96P4grKfBdGQcQ/TXe5FDCQrKLlu7yAYztT33rIipUxdiEuDWKVzd4Pp/uAaKHpZIjfyhLOcrw6arQBAkEAoAQPydK96DcBTEMLE5mcco3Jzy5wZ35uQZGJcByO07gWFVUd4EDxrQ9sIreQnI5RzneuRRByg2Z/BAg4YghZKQJAJMPz/Zqx4nATLlvtYuIJJReXbq78yD99xwiMC5O4opH+/HII6QO4Hqd1X3NBbaCNFam0BRl4MSpcCCL2qe2IAQJAMqBZ1HabVaRzVk8LzpGJGb2+yg9Q9bAA3kxhhdOMJgAVlow8urDyQwLNi4KadzGrSaNcb61mxtkQxDI3VONXoQ==";
            
            
            
            NSString *data = @"WWWWWW";
            NSString *hashAlg = @"sha1";
            NSString *signedDataStr =[opensslUtil signWithPrivateKey:privateKey data:data hashAlg:hashAlg];
            NSLog(@"数据 = %@",data);
            NSLog(@"签名后= %@",signedDataStr);
            if (!signedDataStr) {
                
                NSLog(@"签名为空,私钥错误");
                return;
            }

            
            NSData *dataUTF8 = [data dataUsingEncoding:NSUTF8StringEncoding];
            
            unsigned char *dataBytes = (unsigned char *)[dataUTF8 bytes];
            size_t dataLeng = strlen((char *)dataBytes);
            NSLog(@"原文长度=%d",(int)dataLeng);
            
            
            NSData *signUTF8 = [signedDataStr dataUsingEncoding:NSUTF8StringEncoding];
            unsigned char *signBytes = (unsigned char *)[signUTF8 bytes];
            size_t signLen = strlen((char *)signBytes);
            NSLog(@"签名之后的长度=%d",(int)signLen);
            
            BOOL right = NO;
            if ([hashAlg isEqualToString:@"sha1"]) {
                
                //为什么传入172定长就可以
                right = [opensslUtil verifySha1:publicKey data:dataBytes length:(int)6 signData:signBytes length:(int)172];
                
                
            }
            else if ([hashAlg isEqualToString:@"md5"])
            {
                right = [opensslUtil verifymd5:publicKey data:dataBytes length:(int)6 signData:signBytes length:(int)172];
            }
            if (right) {
                NSLog(@"签名正确");
            }else
            {
                NSLog(@"签名不正确");
            }
            
            
        }];
    }
}


@end
