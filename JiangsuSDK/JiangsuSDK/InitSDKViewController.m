//
//  InitSDKViewController.m
//  JiangsuSDK
//
//  Created by Luo on 16/12/14.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import "InitSDKViewController.h"
#import "UIView+SDAutoLayout.h"
#import "JSSCommon.h"
#import "CoreAPIManager.h"
#import "SecurityManager.h"
#import "ServerAddressManager.h"


@implementation InitSDKViewController
{

    
    UITextField *_tokenValueTextF;
    
    UITextField *_userNameTextF;//d
    //UITextField *_tokenTextF;//token
    
    
}
- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor whiteColor];
    

    //用户名标签
    UILabel *userNameLabel = [[UILabel alloc] init];
    userNameLabel.text = @"用户名：";
    userNameLabel.textColor = [UIColor grayColor];
    //输入框
    _userNameTextF = [[UITextField alloc] init];
    _userNameTextF.layer.cornerRadius = 5;
    _userNameTextF.layer.borderWidth = 1;
    _userNameTextF.layer.borderColor = [UIColor grayColor].CGColor;
    
    //发起token请求
    UIButton *getTokenBtn = [[UIButton alloc] init];
    [getTokenBtn setTitle:@"获取token" forState:UIControlStateNormal];
    [getTokenBtn setBackgroundColor:[UIColor grayColor]];
    [getTokenBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [getTokenBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [getTokenBtn addTarget:self action:@selector(getToken) forControlEvents:UIControlEventTouchUpInside];
    
    
    //token的值
    _tokenValueTextF = [[UITextField alloc] init];
    _tokenValueTextF.layer.cornerRadius = 5;
    _tokenValueTextF.layer.borderWidth = 1;
    _tokenValueTextF.layer.borderColor = [UIColor grayColor].CGColor;
    
    //初始化按钮
    UIButton *initSDKBtn = [[UIButton alloc] init];
    [initSDKBtn setBackgroundColor:[UIColor grayColor]];
    [initSDKBtn setTitle:@"初始化SDK" forState:UIControlStateNormal];
    [initSDKBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [initSDKBtn addTarget:self action:@selector(initSDK) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view sd_addSubviews:@[userNameLabel,_userNameTextF,getTokenBtn,_tokenValueTextF,initSDKBtn]];
    
    
    userNameLabel.sd_layout
    .leftSpaceToView(self.view,20)
    .topSpaceToView(self.view,100)
    .heightIs(40)
    .widthIs(80);
    
    _userNameTextF.sd_layout
    .leftSpaceToView(userNameLabel,20)
    .rightSpaceToView(self.view,20)
    .topEqualToView(userNameLabel)
    .heightRatioToView(userNameLabel,1);
    
    getTokenBtn.sd_layout
    .leftEqualToView(userNameLabel)
    .topSpaceToView(userNameLabel,10)
    .heightRatioToView(userNameLabel,1)
    .widthRatioToView(userNameLabel,1);
    
    _tokenValueTextF.sd_layout
    .leftEqualToView(_userNameTextF)
    .topEqualToView(getTokenBtn)
    .widthRatioToView(_userNameTextF,1)
    .heightRatioToView(_userNameTextF,1);
    
    initSDKBtn.sd_layout
    .topSpaceToView(getTokenBtn,20)
    .leftEqualToView(getTokenBtn)
    .widthIs(100)
    .heightIs(40);

}


//获取token
- (void)getToken
{
    NSString *ip = [JSSCommon getIPAdress];
    NSLog(@"ip = %@",ip);
    //ip = @"10.1.112.232";
    //ip = @"10.1.114.95";//12.05早上
    CoreAPIManager *manager = [CoreAPIManager sharedCoreAPIManager];
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    
    NSString *transactionID = [JSSCommon getTransactionID];
    NSString *userName = @"aspire";
    
    NSString *clearText = [NSString stringWithFormat:@"%@%@%@",transactionID,userName,ip];
    NSString *hmac = [JSSCommon HMACMD5WithClearText:clearText];
    
    
    [requestDic setObject:transactionID forKey:@"transactionID"];
    [requestDic setObject:userName forKey:@"userName"];
    [requestDic setObject:@"" forKey:@"userIP"];
    [requestDic setObject:hmac forKey:@"hmac"];
    
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@"GetTokenReq" forKey:@"messageName"];
    [dic setObject:requestDic forKey:@"para"];
    
    
    [manager postHttpRequestWithRUL:@"http://10.1.4.74:8088/essportal/getToken" token:@"" requestDic:dic successBlock:^(id data) {
        NSLog(@"成功数据 = %@",data);
      
        
        //由于ip鉴权失败,所以指定token
        _tokenValueTextF.text = @"YXNwaXJlIzEwLjEuMTE2LjE1NyNMYUs2VUYjMTQ4MTA5OTg0ODExNiMxNDk5MDk5ODQ4MTE2I0ZYVS9aUUFKY3dCMmRFRzc3SjAyM2c9PQ==";
        
    } errorBlock:^(NSError *error) {
        NSLog(@"错误：= %@",error);
    }];
    
}


#pragma mark - 初始化
- (void)initSDK
{
    NSString *userName = _userNameTextF.text;
    if (!userName || [userName isEqualToString:@""]) {
        //userName = @"aspire";
    }
    NSString *token = _tokenValueTextF.text;
    if (!token || [token isEqualToString:@""]) {
        token = @"YXNwaXJlIzEwLjEuMTE2LjE1NyNMYUs2VUYjMTQ4MTA5OTg0ODExNiMxNDk5MDk5ODQ4MTE2I0ZYVS9aUUFKY3dCMmRFRzc3SjAyM2c9PQ==";
    }
    
    [SecurityManager initSDKWithToken:token userName:userName serverAddress:@"http://10.1.4.74:8088/essportal/" successBlock:^{
    
        //成功初始化
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"成功初始化" message:@"成功初始化" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
        
    } errorBlock:^(ResultCode resultCode) {
        
        NSString *errorMessage = [NSString stringWithFormat:@"失败错误码:%ld",resultCode];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"初始化失败" message:errorMessage delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
        
    }];
    
}

@end
