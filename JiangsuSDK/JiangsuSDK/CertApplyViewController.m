//
//  CertApplyViewController.m
//  JiangsuSDK
//
//  Created by Luo on 16/12/14.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import "CertApplyViewController.h"
#import "UIView+SDAutoLayout.h"
#import "SecurityManager.h"

@interface CertApplyViewController ()
{
    UITextField *_userNameTF;
    UITextField *_pinTF;
    UITextField *_verityCodeTF;
    UITextField *_pesNameTF;//真实姓名
    UITextField *_cardTypeTF;
    UITextField *_cardNOTF;
    UITextField *_mobileNOTF;
    UITextField *_userTypeTF;
    
}
@end

@implementation CertApplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //用户名
    UILabel *userNameL = [self normalLabelWithTitle:@"用户名"];
    _userNameTF = [self normalTextF];

    //PIN
    UILabel *pinL = [self normalLabelWithTitle:@"pin"];
    _pinTF = [self normalTextF];
    
    //短息验证码
    UILabel *verifyCodeL = [self normalLabelWithTitle:@"短息验证码"];
    _verityCodeTF = [self normalTextF];
    
    //真实姓名
    UILabel *pesNameL = [self normalLabelWithTitle:@"真实姓名"];
    _pesNameTF = [self normalTextF];
    
    //证件类型
    UILabel *cardTypeL = [self normalLabelWithTitle:@"证件类型"];
    _cardTypeTF = [self normalTextF];
    _cardTypeTF.placeholder = @"1~~~7";
    
    //证件号码
    UILabel *cardNOL = [self normalLabelWithTitle:@"证件号码"];
    _cardNOTF = [self normalTextF];
    
    //手机号
    UILabel *phonL = [self normalLabelWithTitle:@"手机号码"];
    _mobileNOTF = [self normalTextF];
    
    //用户类型
    UILabel *userTypeL = [self normalLabelWithTitle:@"用户类型"];
    _userTypeTF = [self normalTextF];
    _userTypeTF.placeholder = @"1~3";
    
    NSArray *labelArray = @[userNameL,pinL,verifyCodeL,pesNameL,cardTypeL,cardNOL,phonL,userTypeL];
    NSArray *tfArray = @[_userNameTF,_pinTF,_verityCodeTF,_pesNameTF,_cardTypeTF,_cardNOTF,_mobileNOTF,_userTypeTF];
    
    
    CGFloat btnTop = 0;
    for (int i = 0; i < labelArray.count; i++) {
        //UILabel *label = []
        CGFloat labelWid = 80;
        CGFloat hei = 25;
        CGFloat tfWid = [UIScreen mainScreen].bounds.size.width - 40-10-labelWid;
        CGFloat top = 70 +  (hei + 5)*i;
        btnTop = top + hei + 5;
        
        CGFloat labelLeft = 20;
        CGFloat tfLeft = labelLeft + labelWid + 10;
        
        UILabel *label = labelArray[i];
        label.frame = CGRectMake(labelLeft, top, labelWid, hei);
        
        UITextField *tf = tfArray[i];
        tf.frame = CGRectMake(tfLeft, top, tfWid, hei);
        
        [self.view addSubview:label];
        [self.view addSubview:tf];
    }
    
    UIButton *certApplyBtn = [self normalButtonWithTitle:@"获取证书"];
    [certApplyBtn setFrame:CGRectMake(20, btnTop, 100, 30)];
    [self.view addSubview:certApplyBtn];
    [certApplyBtn addTarget:self action:@selector(certApply) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 证书申请

- (void)certApply
{
    NSString *pin = _pinTF.text;
    NSString *verifyCode = _verityCodeTF.text;
    NSString *pesName = _pesNameTF.text;
    NSString *cardNO = _cardNOTF.text;
    NSString *mobileNO = _mobileNOTF.text;
    
    //
    NSString *cardTypeStr = _cardTypeTF.text;
    CardType cardType = [cardTypeStr integerValue];
    
    //1~3
    NSString *userTypeStr = _userTypeTF.text;
    CertUserType userType = [userTypeStr integerValue];
    
    
    [SecurityManager certApplyWithPin:pin verifyCode:verifyCode pesName:pesName cardType:cardType cardNO:cardNO mobileNO:mobileNO userType:userType successBlock:^{
        
        UIAlertView *alert = [self alerWithTitle:@"成功" message:@"成功保存在本地"];
        [alert show];
        
    } errorBlock:^(ResultCode errrCode) {
        
        NSString *message = [NSString stringWithFormat:@"错误码：%ld",errrCode];
        UIAlertView *alert = [self alerWithTitle:@"失败" message:message];
        [alert show];
        
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
