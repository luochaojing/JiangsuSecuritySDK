//
//  GetMessageCodeViewController.m
//  JiangsuSDK
//
//  Created by Luo on 16/12/14.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import "GetMessageCodeViewController.h"
#import "UIView+SDAutoLayout.h"
#import "SecurityManager.h"
#import "CoreAPIManager.h"

@interface GetMessageCodeViewController ()
{
    UITextField *_phoneTextF;//
}
@end

@implementation GetMessageCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *phoneNumLabel = [[UILabel alloc] init];
    phoneNumLabel.textColor = [UIColor grayColor];
    phoneNumLabel.text = @"手机号码";
    
    _phoneTextF = [[UITextField alloc] init];
    _phoneTextF.layer.cornerRadius = 5;
    _phoneTextF.layer.borderWidth = 1;
    _phoneTextF.layer.borderColor = [UIColor grayColor].CGColor;
    
    UIButton *getMCodeBtn = [[UIButton alloc] init];
    [getMCodeBtn setBackgroundColor:[UIColor grayColor]];
    [getMCodeBtn setTitle:@"发送请求" forState:UIControlStateNormal];
    [getMCodeBtn.titleLabel setTextColor:[UIColor whiteColor]];
    [getMCodeBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [getMCodeBtn addTarget:self action:@selector(getMessageCode) forControlEvents:UIControlEventTouchUpInside];
    
    
    //查看验证码
    UIButton *lookVerifyCodeBtn = [self normalButtonWithTitle:@"查看验证码"];
    [lookVerifyCodeBtn addTarget:self action:@selector(lookVerifyCode) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view sd_addSubviews:@[phoneNumLabel,_phoneTextF,getMCodeBtn,lookVerifyCodeBtn]];
    
    phoneNumLabel.sd_layout
    .topSpaceToView(self.view,100)
    .leftSpaceToView(self.view,20)
    .widthIs(80)
    .heightIs(40);
    
    _phoneTextF.sd_layout
    .leftSpaceToView(phoneNumLabel,20)
    .topEqualToView(phoneNumLabel)
    .heightRatioToView(phoneNumLabel,1)
    .rightSpaceToView(self.view,20);
    
    getMCodeBtn.sd_layout
    .leftEqualToView(phoneNumLabel)
    .topSpaceToView(phoneNumLabel,20)
    .widthIs(100)
    .heightIs(40);
    
    lookVerifyCodeBtn.sd_layout
    .leftEqualToView(getMCodeBtn)
    .rightEqualToView(getMCodeBtn)
    .topSpaceToView(getMCodeBtn,20)
    .heightRatioToView(getMCodeBtn,1);
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)getMessageCode
{
    NSString *phoneNum = _phoneTextF.text;
    
    [SecurityManager applyDynamicCodeWithPhoneNum:phoneNum successBlock:^{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"后台已经发送" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
        
    } errorBlock:^(ResultCode resultCode) {
        
        NSString *errorMessage = [NSString stringWithFormat:@"错误码：%ld",resultCode];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:errorMessage delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
        
    }];
}


- (void)lookVerifyCode
{
    NSString *phoneNum = _phoneTextF.text;
    NSDictionary *paraDic = @{@"mobileNo":phoneNum};
    
    NSMutableDictionary *reqDic = [[NSMutableDictionary alloc] init];
    [reqDic setObject:@"GetVerifyCodeReq" forKey:@"messageName"];
    [reqDic setObject:paraDic forKey:@"para"];
    
    CoreAPIManager *coreAPI = [CoreAPIManager sharedCoreAPIManager];
    [coreAPI postHttpRequestWithRUL:@"http://10.1.4.74:8088/essportal/getVerifyCode" token:@"" requestDic:reqDic successBlock:^(id data) {
        
        NSDictionary *resDic = data;
        NSDictionary *para = [resDic objectForKey:@"para"];
        NSString *code = [para objectForKey:@"verifyCode"];
        
        UIAlertView *alert = [self alerWithTitle:@"查到验证码" message:code];
        [alert show];
        
    } errorBlock:^(NSError *error) {
    
        [self alerWithTitle:@"错误" message:@"错误"];
    }];
}




#pragma mark - 通用标签和输入框
- (UILabel *)normalLabelWithTitle:(NSString *)title
{
    UILabel *normalLabel = [[UILabel alloc] init];
    normalLabel.text = title;
    normalLabel.textColor = [UIColor grayColor];
    
    return normalLabel;
}

- (UITextField *)normalTextF
{
    UITextField *normalTextF = [[UITextField alloc] init];
    normalTextF.layer.cornerRadius = 5;
    normalTextF.layer.borderWidth = 1;
    normalTextF.layer.borderColor = [UIColor grayColor].CGColor;
    return normalTextF;
}

- (UIButton *)normalButtonWithTitle:(NSString *)title
{
    UIButton *normalBtn = [[UIButton alloc] init];
    [normalBtn setBackgroundColor:[UIColor grayColor]];
    [normalBtn setTitle:title forState:UIControlStateNormal];
    [normalBtn.titleLabel setTextColor:[UIColor whiteColor]];
    
    return normalBtn;
}

- (UIAlertView *)alerWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    return alert;
}



@end
