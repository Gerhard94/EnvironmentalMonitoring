//
//  JHLoginRegister.m
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/1/10.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import "JHLoginRegister.h"

@interface JHLoginRegister () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@end

@implementation JHLoginRegister

//初始化登录视图
+ (instancetype)initWithLogin {
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].firstObject;
}

//初始化注册视图
+ (instancetype)initWithRegister {
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    //设置两个输入框的代理
    self.accountTextField.delegate = self;
    self.passwordTextField.delegate = self;
}

//监听输入框的字符变化
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    //拼接最新输入的字符
    NSString *newInput = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *account;
    NSString *password;
    
    //如果输入框是账号输入框
    if (textField == self.accountTextField) {
        password = self.passwordTextField.text;
        account = newInput;
    } else {
        account = self.accountTextField.text;
        password = newInput;
    }
    
    //输入框都有值登录按钮才能使用
    self.loginButton.enabled = account.length > 0 && password.length > 0;
    return YES;
}



- (IBAction)loginButton:(UIButton *)sender {
    //如果代理执行了这个方法
    if ([self.delegate respondsToSelector:@selector(loginButtonClick:)] ) {
        [self.delegate loginButtonClick:self];
    }
}

- (IBAction)pwdTextSwitch:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        NSString *tempPwdStr = self.passwordTextField.text;
        self.passwordTextField.text = @"";
        [self.passwordTextField setSecureTextEntry:NO];
        self.passwordTextField.text = tempPwdStr;
    } else {
        NSString *tempPwdStr = self.passwordTextField.text;
        self.passwordTextField.text = @"";
        [self.passwordTextField setSecureTextEntry:YES];
        self.passwordTextField.text = tempPwdStr;
        
    }
}

@end
