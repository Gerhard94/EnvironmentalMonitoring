//
//  JHLoginRegister.h
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/1/10.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JHLoginRegisterField.h"
@class JHLoginRegister;

@protocol JHLoginRegisterDelegate <NSObject>

- (void)loginButtonClick:(JHLoginRegister *)view;

@end

@interface JHLoginRegister : UIView

//初始化登录界面
+ (instancetype)initWithLogin;

//初始化注册界面
+ (instancetype)initWithRegister;

@property (weak, nonatomic) IBOutlet JHLoginRegisterField *accountTextField;
@property (weak, nonatomic) IBOutlet JHLoginRegisterField *passwordTextField;
@property (nonatomic, weak) id<JHLoginRegisterDelegate> delegate;

@end
