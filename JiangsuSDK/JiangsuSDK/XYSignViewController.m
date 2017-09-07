//
//  XYSignViewController.m
//  JiangsuSDK
//
//  Created by Luo on 16/12/22.
//  Copyright © 2016年 com.aspire. All rights reserved.
//

#import "XYSignViewController.h"
#import "UIView+SDAutoLayout.h"
#import "SecurityManager.h"

@interface XYSignViewController ()
{
    UITextField *_xTextF;
    UITextField *_yTextF;
    UITextField *_pageNumTextF;
    UITextField *_pinTextF;
    UITextField *_docIDTF;
}
@end

@implementation XYSignViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UILabel *xL = [self normalLabelWithTitle:@"x"];
    _xTextF = [self normalTextF];
    
    UILabel *yL = [self normalLabelWithTitle:@"y"];
    _yTextF = [self normalTextF];
    
    UILabel *pageL = [self normalLabelWithTitle:@"页数"];
    _pageNumTextF = [self normalTextF];
    
    UILabel *pinL = [self normalLabelWithTitle:@"pin"];
    _pinTextF = [self normalTextF];
    
    UILabel *docIDL = [self normalLabelWithTitle:@"docID"];
    _docIDTF = [self normalTextF];
    
    UIButton *signBtn = [self normalButtonWithTitle:@"签章"];
    [signBtn addTarget:self action:@selector(signXY) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view sd_addSubviews:@[xL,_xTextF,yL,_yTextF,pageL,_pageNumTextF,pinL,_pinTextF,docIDL,_docIDTF,signBtn]];
    
    
    //布局
    xL.sd_layout
    .topSpaceToView(self.view,100)
    .leftSpaceToView(self.view,10)
    .widthIs(80)
    .heightIs(30);
    
    _xTextF.sd_layout
    .leftSpaceToView(xL,10)
    .topEqualToView(xL)
    .rightSpaceToView(self.view,10)
    .heightRatioToView(xL,1);
    
    yL.sd_layout
    .leftEqualToView(xL)
    .topSpaceToView(xL,10)
    .widthRatioToView(xL,1)
    .heightRatioToView(xL,1);
    
    _yTextF.sd_layout
    .leftEqualToView(_xTextF)
    .topEqualToView(yL)
    .heightRatioToView(_xTextF,1)
    .widthRatioToView(_xTextF,1);
    
    pageL.sd_layout
    .leftEqualToView(xL)
    .topSpaceToView(yL,10)
    .widthRatioToView(yL,1)
    .heightRatioToView(yL,1);
    
    _pageNumTextF.sd_layout
    .leftEqualToView(_xTextF)
    .topEqualToView(pageL)
    .heightRatioToView(_xTextF,1)
    .widthRatioToView(_xTextF,1);
    

    pinL.sd_layout
    .leftEqualToView(pageL)
    .topSpaceToView(pageL,10)
    .widthRatioToView(yL,1)
    .heightRatioToView(yL,1);
    
    _pinTextF.sd_layout
    .leftEqualToView(_xTextF)
    .topEqualToView(pinL)
    .heightRatioToView(_xTextF,1)
    .widthRatioToView(_xTextF,1);
    
    docIDL.sd_layout
    .leftEqualToView(pinL)
    .topSpaceToView(pinL,10)
    .widthRatioToView(yL,1)
    .heightRatioToView(yL,1);
    
    _docIDTF.sd_layout
    .leftEqualToView(_pinTextF)
    .topEqualToView(docIDL)
    .heightRatioToView(_xTextF,1)
    .widthRatioToView(_xTextF,1);
    
    
    signBtn.sd_layout
    .leftEqualToView(docIDL)
    .topSpaceToView(docIDL,10)
    .widthIs(200)
    .heightIs(40);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)signXY
{
    NSString *xStr = _xTextF.text;
    CGFloat x = [xStr floatValue];
    
    NSString *yStr = _yTextF.text;
    CGFloat y = [yStr floatValue];
    
    NSString *pageStr = _pageNumTextF.text;
    CGFloat pageNum = [pageStr floatValue];
    
    NSString *pin = _pinTextF.text;
    
    NSString *docID = _docIDTF.text;
    
    [SecurityManager docSignWithPin:pin docID:docID x:x y:y pageValue:pageNum todoID:@"todoID" successBlock:^{
        
        [[self alerWithTitle:@"成功" message:@"成功签章"] show];
    } failBlock:^(ResultCode errorCode) {
        
        [[self alerWithTitle:@"失败" message:[NSString stringWithFormat:@"失败码%ld",errorCode]] show];
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
