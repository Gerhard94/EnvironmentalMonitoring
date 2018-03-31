//
//  JHLoginRegister.h
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/1/10.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JHLoginRegister : UIView

//初始化登录界面
+ (instancetype)initWithLogin;

//初始化注册界面
+ (instancetype)initWithRegister;

@property (weak, nonatomic) IBOutlet UITextField *accountTextField;


@end
