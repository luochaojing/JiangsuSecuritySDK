//
//  DocURL_SignVC.m
//  JiangsuSDK
//
//  Created by Luo on 16/12/14.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import "DocURL_SignVC.h"
#import "UIView+SDAutoLayout.h"
#import "SecurityManager.h"

@interface DocURL_SignVC ()
{
    //文档id输入狂
    UITextField *_docIDTF;
    
    //签名原文：
    UITextField *_oriStrTF;
    //PIN
    UITextField *_pinTF;
}
@end

@implementation DocURL_SignVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *docIDL = [self normalLabelWithTitle:@"文档ID"];
    _docIDTF = [self normalTextF];
    UIButton *getDocUrlBtn = [self normalButtonWithTitle:@"获取链接"];
    [getDocUrlBtn addTarget:self action:@selector(getDocURL) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *oriL = [self normalLabelWithTitle:@"原文"];
    _oriStrTF = [self normalTextF];
    UILabel *pinL = [self normalLabelWithTitle:@"pin"];
    _pinTF = [self normalTextF];
    
    UIButton *signBtn = [self normalButtonWithTitle:@"签名"];
    [signBtn addTarget:self action:@selector(sign) forControlEvents:UIControlEventTouchUpInside];
    
    //查看电子签章详情
    UIButton *signInfoQueryBtn = [self normalButtonWithTitle:@"查看电子签章详情"];
    [signInfoQueryBtn addTarget:self action:@selector(signInfoQuery) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view sd_addSubviews:@[docIDL,_docIDTF,getDocUrlBtn,oriL,_oriStrTF,pinL,_pinTF,signBtn,signInfoQueryBtn]];
    
    
    //布局
    docIDL.sd_layout
    .topSpaceToView(self.view,100)
    .leftSpaceToView(self.view,20)
    .widthIs(80)
    .heightIs(30);
    
    _docIDTF.sd_layout
    .leftSpaceToView(docIDL,10)
    .topEqualToView(docIDL)
    .rightSpaceToView(self.view,10)
    .heightRatioToView(docIDL,1);
    
    getDocUrlBtn.sd_layout
    .leftEqualToView(docIDL)
    .topSpaceToView(docIDL,10)
    .widthIs(100)
    .heightIs(30);
    
    //
    oriL.sd_layout
    .topSpaceToView(getDocUrlBtn,10)
    .leftEqualToView(docIDL)
    .widthRatioToView(docIDL,1)
    .heightRatioToView(docIDL,1);
    
    _oriStrTF.sd_layout
    .leftSpaceToView(oriL,10)
    .topEqualToView(oriL)
    .rightSpaceToView(self.view,10)
    .heightRatioToView(oriL,1);
    
    //pin
    pinL.sd_layout
    .leftEqualToView(oriL)
    .topSpaceToView(oriL,10)
    .widthRatioToView(oriL,1)
    .heightRatioToView(oriL,1);
    
    _pinTF.sd_layout
    .leftEqualToView(_oriStrTF)
    .rightEqualToView(_oriStrTF)
    .heightRatioToView(_oriStrTF,1)
    .topEqualToView(pinL);
    
    
    signBtn.sd_layout
    .leftEqualToView(pinL)
    .topSpaceToView(pinL,10)
    .widthIs(100)
    .heightIs(30);
    
    signInfoQueryBtn.sd_layout
    .leftEqualToView(signBtn)
    .topSpaceToView(signBtn,10)
    .widthRatioToView(signBtn,2)
    .heightRatioToView(signBtn,1);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 按钮事件

- (void)getDocURL
{
    NSString *docID = _docIDTF.text;
    [SecurityManager getDocURLWithDocID:docID SuccessBlock:^(NSString *docURL) {
        
        UIAlertView *alert = [self alerWithTitle:@"成功" message:docURL];
        [alert show];
        
    } errorBlock:^(ResultCode errorCode) {
        
        NSString *errorMessage = [NSString stringWithFormat:@"错误代码：%ld",errorCode];
        [[self alerWithTitle:@"错误" message:errorMessage] show];
    }];
}

- (void)signInfoQuery
{
    
    NSString *docID = _docIDTF.text;
    [SecurityManager querySignInfoWithDocID:docID successBlock:^(NSArray<SignInfoModel *> *array) {
        
        [[self alerWithTitle:@"成功" message:@"返回数据已经以日记的形式输出"] show];
        
        for (int i = 0; i < array.count; i++) {
            SignInfoModel *signInfoModel = array[i];
           // NSLog(@"签名域 = %@",signInfoModel.signArea);
           // NSLog(@"证书= %@",signInfoModel.certificate);
            
            [SecurityManager signInfoVerifyWithDocID:docID signArea:signInfoModel.signArea successBlock:^{
                NSLog(@"签章验证成功");
            } errorBlock:^(ResultCode errorCode) {
                NSLog(@"签章认证失败！");
            }];
        }
        //NSLog(@"电子签章详情查询数据：%@",array);
        
    } errorBlock:^(ResultCode errorCode) {
       
        NSString *errorM = [NSString stringWithFormat:@"错误码：%ld",errorCode];
        [[self alerWithTitle:@"错误" message:errorM] show];
        
    }];
    
}

- (void)sign
{
    NSString *ori = _oriStrTF.text;
    NSString *pin = _pinTF.text;
    
    [SecurityManager digitalSignatrueWithPin:pin orignal:ori ifNeedBase64Decoding:NO successBlock:^(NSString *cipherText) {
        
        [[self alerWithTitle:@"成功加密" message:cipherText] show];
        
    } errorBlock:^(ResultCode erroCode) {
       
        NSString *mess = [NSString stringWithFormat:@"错误码：%ld",erroCode];
        [[self alerWithTitle:@"错误" message:mess] show];
        
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
