//
//  DocSignViewController.m
//  JiangsuSDK
//
//  Created by Luo on 16/12/15.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import "DocSignViewController.h"
#import "UIView+SDAutoLayout.h"
#import "SecurityManager.h"

@interface DocSignViewController ()
{
    UITextField *_pinTF;
    UITextField *_docIDTF;
    UITextField *_keyWordTF;
    
    //签名域
    UITextField *_signAreaTF;
}

@end

@implementation DocSignViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    

    UILabel *pinL = [self normalLabelWithTitle:@"PIN"];
    _pinTF = [self normalTextF];
    
    UILabel *docIDL = [self normalLabelWithTitle:@"docID"];
    _docIDTF = [self normalTextF];
    
    UILabel *keyWL = [self normalLabelWithTitle:@"关键词"];
    _keyWordTF = [self normalTextF];
    
    UIButton *docSignBtn = [self normalButtonWithTitle:@"电子签章"];
    [docSignBtn addTarget:self action:@selector(docSignWithKeyW) forControlEvents:UIControlEventTouchUpInside];
    
    //签名域+验证
    UILabel *areaL = [self normalLabelWithTitle:@"签名域"];
    _signAreaTF = [self normalTextF];
    UIButton *verSignBtn = [self normalButtonWithTitle:@"验证电子签章"];
    [verSignBtn addTarget:self action:@selector(verSign) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view sd_addSubviews:@[pinL,_pinTF,docIDL,_docIDTF,keyWL,_keyWordTF,docSignBtn,areaL,_signAreaTF,verSignBtn]];
    
    
    pinL.sd_layout
    .topSpaceToView(self.view,100)
    .leftSpaceToView(self.view,10)
    .widthIs(80)
    .heightIs(30);
    
    _pinTF.sd_layout
    .leftSpaceToView(pinL,10)
    .topEqualToView(pinL)
    .rightSpaceToView(self.view,10)
    .heightRatioToView(pinL,1);
    
    docIDL.sd_layout
    .leftEqualToView(pinL)
    .topSpaceToView(pinL,10)
    .widthRatioToView(pinL,1)
    .heightRatioToView(pinL,1);
    
    _docIDTF.sd_layout
    .leftEqualToView(_pinTF)
    .topEqualToView(docIDL)
    .heightRatioToView(_pinTF,1)
    .widthRatioToView(_pinTF,1);
    
    keyWL.sd_layout
    .leftEqualToView(pinL)
    .topSpaceToView(docIDL,10)
    .widthRatioToView(pinL,1)
    .heightRatioToView(pinL,1);
    
    _keyWordTF.sd_layout
    .leftEqualToView(_pinTF)
    .topEqualToView(keyWL)
    .heightRatioToView(_pinTF,1)
    .widthRatioToView(_pinTF,1);
    
    docSignBtn.sd_layout
    .leftEqualToView(keyWL)
    .topSpaceToView(keyWL,10)
    .widthIs(200)
    .heightIs(30);
    
    //验证
    areaL.sd_layout
    .leftEqualToView(docSignBtn)
    .topSpaceToView(docSignBtn,20)
    .widthRatioToView(keyWL,1)
    .heightRatioToView(keyWL,1);
    
    _signAreaTF.sd_layout
    .leftEqualToView(_docIDTF)
    .topEqualToView(areaL)
    .heightRatioToView(_docIDTF,1)
    .widthRatioToView(_docIDTF,1);
    
    verSignBtn.sd_layout
    .leftEqualToView(areaL)
    .topSpaceToView(areaL,10)
    .heightIs(30)
    .widthIs(200);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



#pragma mark - 按钮事件

- (void)docSignWithKeyW
{
    NSString *pin     = _pinTF.text;
    NSString *docID   = _docIDTF.text;
    NSString *keyWord = _keyWordTF.text;
    
    [SecurityManager docSignWithPin:pin docID:docID keyWord:keyWord todoID:@"todoID" successBlock:^{
        [[self alerWithTitle:@"成功" message:@"成功签章"] show];
        
        
    } failBlock:^(ResultCode errorCode) {
       
        [[self alerWithTitle:@"失败" message:[NSString stringWithFormat:@"错误码%ld",errorCode]] show];
        
    }];
}


- (void)verSign
{
    NSString *docID = _docIDTF.text;
    NSString *area = _signAreaTF.text;
    
    [SecurityManager signInfoVerifyWithDocID:docID signArea:area successBlock:^{
        
        [[self alerWithTitle:@"验证成功" message:@"成功验证"] show];
        
    } errorBlock:^(ResultCode errorCode) {
       
        [[self alerWithTitle:@"失败" message:[NSString stringWithFormat:@"错误码：%ld",errorCode]] show];
        
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
