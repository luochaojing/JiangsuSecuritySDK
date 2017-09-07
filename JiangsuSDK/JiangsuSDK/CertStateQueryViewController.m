//
//  CertStateQueryViewController.m
//  JiangsuSDK
//
//  Created by Luo on 16/12/14.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import "CertStateQueryViewController.h"
#import "UIView+SDAutoLayout.h"
#import "SecurityManager.h"

@interface CertStateQueryViewController ()
{
    //
    UITextField *_userNameTextF;
}
@end

@implementation CertStateQueryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *userNameLabel = [[UILabel alloc] init];
    userNameLabel.text = @"用户名";
    userNameLabel.textColor = [UIColor grayColor];
    
    _userNameTextF = [[UITextField alloc] init];
    _userNameTextF.layer.cornerRadius = 5;
    _userNameTextF.layer.borderWidth = 1;
    _userNameTextF.layer.borderColor = [UIColor grayColor].CGColor;
    
    //查询按钮
    UIButton *queryCertStateBtn = [[UIButton alloc] init];
    [queryCertStateBtn setTitle:@"查询证书" forState:UIControlStateNormal];
    [queryCertStateBtn setBackgroundColor:[UIColor grayColor]];
    [queryCertStateBtn.titleLabel setTextColor:[UIColor whiteColor]];
    
    [queryCertStateBtn addTarget:self action:@selector(queryCertState) forControlEvents:UIControlEventTouchUpInside];
    
    
    //注销按钮
    UIButton *cancelCertBtn = [self normalButtonWithTitle:@"注销"];
    [cancelCertBtn addTarget:self action:@selector(cancelCert) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    [self.view sd_addSubviews:@[userNameLabel,_userNameTextF,queryCertStateBtn,cancelCertBtn]];
    userNameLabel.hidden = YES;
    _userNameTextF.hidden = YES;
    
    userNameLabel.sd_layout
    .topSpaceToView(self.view,100)
    .leftSpaceToView(self.view,20)
    .widthIs(100)
    .heightIs(40);
    
    _userNameTextF.sd_layout
    .leftSpaceToView(userNameLabel,20)
    .rightSpaceToView(self.view,20)
    .topEqualToView(userNameLabel)
    .heightRatioToView(userNameLabel,1);
    
    queryCertStateBtn.sd_layout
    .leftEqualToView(userNameLabel)
    .topSpaceToView(userNameLabel,20)
    .widthIs(200)
    .heightIs(40);
    
    cancelCertBtn.sd_layout
    .topSpaceToView(queryCertStateBtn,10)
    .leftEqualToView(queryCertStateBtn)
    .widthRatioToView(queryCertStateBtn,1)
    .heightRatioToView(queryCertStateBtn,1);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)queryCertState
{
    [SecurityManager certStateQueryWithSuccessBlock:^(NSInteger state) {
        
        NSString *certState = [NSString stringWithFormat:@"证书状态：%ld",state];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"成功查询" message:certState delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        
    } errorBlock:^(ResultCode errorCode) {
       
        NSString *errorMessage = [NSString stringWithFormat:@"错误码：%ld",errorCode];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"失败" message:errorMessage delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }];
}

//注销
- (void)cancelCert
{
    [SecurityManager certCancelWithSuccessBlock:^{
        
        [[self alerWithTitle:@"成功吊销" message:@"成功吊销"] show];
        
    } errorBlock:^(ResultCode errorCode) {
       
        NSString *erroM = [NSString stringWithFormat:@"错误码：%ld",errorCode];
        [[self alerWithTitle:@"" message:erroM] show];
        
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
