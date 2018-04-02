//
//  JHLoginRegisterController.m
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/1/10.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import "JHLoginRegisterController.h"
#import "JHLoginRegister.h"
#import "JHMainController.h"
#import <AFNetworking.h>

@interface JHLoginRegisterController ()

//背景视图
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImageView;

//中部视图
@property (weak, nonatomic) IBOutlet UIView *middleView;

//中部视图左边约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingConstraints;

//切换按钮
@property (weak, nonatomic) IBOutlet UIButton *changeViewButton;

//注册登录视图
@property (nonatomic, strong) JHLoginRegister *loginView;
@end

@implementation JHLoginRegisterController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackGroundImage];
    [self setupMiddleView];
    [self getUsernamePassword];
}


- (void)getUsernamePassword{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:Api_key forHTTPHeaderField:@"api-key"];
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 8.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    

    NSString *urlStr = [base_url stringByAppendingPathComponent:@"28167645/datastreams/password"];
    
    [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
    
}

/**
进入主界面
 */
- (IBAction)testBtnClick:(id)sender {
    JHMainController *mainVC = [[JHMainController alloc] init];
    [[UIApplication sharedApplication].keyWindow setRootViewController:mainVC];
}

/**
 点击切换登录注册
 */
- (IBAction)changeViewBtnClick:(id)sender {
    self.changeViewButton.selected = !self.changeViewButton.selected;
    self.leadingConstraints.constant = self.leadingConstraints.constant == 0 ? -self.middleView.bounds.size.width * 0.5 : 0;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    NSLog(@"%@",self.loginView.accountTextField.text);
    
}

/**
 初始化中间板块界面
 */
- (void)setupMiddleView {
    //创建登录界面
    JHLoginRegister *loginView = [JHLoginRegister initWithLogin];
    [_middleView addSubview:loginView];
    _loginView = loginView;
    
    //创建注册界面
    JHLoginRegister *registerView = [JHLoginRegister initWithRegister];
    [_middleView addSubview:registerView];
}

/**
 初始化背景图片
 */
- (void)setBackGroundImage {
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:Screenbounds];
    toolBar.barStyle = UIBarStyleBlack;
    [self.backGroundImageView addSubview:toolBar];
}


/**
 设置子控件尺寸
 */
- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    //登录
    JHLoginRegister *loginView = self.middleView.subviews[0];
    loginView.frame = CGRectMake(0, 0, self.middleView.frame.size.width * 0.5, self.middleView.frame.size.height);
    
    //注册
    JHLoginRegister *registerView = self.middleView.subviews[1];
    registerView.frame = CGRectMake(self.middleView.frame.size.width * 0.5, 0, self.middleView.frame.size.width * 0.5, self.middleView.frame.size.height);
    
}


/**
 点击屏幕空白处
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //停止输入
    [self.view endEditing:YES];
}



@end
