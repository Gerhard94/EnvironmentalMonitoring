//
//  JHLoginRegisterController.m
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/1/10.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import "JHLoginRegisterController.h"
#import "JHLoginRegister.h"
#import "JHTabBarController.h"

@interface JHLoginRegisterController () <JHLoginRegisterDelegate>

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
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IDArray"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"titleArray"];
}

- (IBAction)testButtonClick:(id)sender {
    JHTabBarController *tabBarVC = [[JHTabBarController alloc] init];
    [[UIApplication sharedApplication].keyWindow setRootViewController:tabBarVC];
}

- (void)getUsernamePassword{
    //创建manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //设置http报头信息
    [manager.requestSerializer setValue:Api_key forHTTPHeaderField:@"api-key"];
    
    //设置请求超时的时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 8.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    //设置Url和url元素
    NSString *urlStr = [base_url stringByAppendingPathComponent:@"28341037/datastreams"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"datastream_ids"] = @"account,password";
    
    //发送网络请求
    [manager GET:urlStr parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //取出账号和密码
        NSArray *tempArray = [responseObject objectForKey:@"data"];
        NSDictionary *accountInfo = [tempArray objectAtIndex:0];
        NSDictionary *passwordInfo = [tempArray objectAtIndex:1];
        [[NSUserDefaults standardUserDefaults] setValue:accountInfo[@"current_value"] forKey:@"account"];
        [[NSUserDefaults standardUserDefaults] setValue:passwordInfo[@"current_value"] forKey:@"password"];
//        NSLog(@"%@---%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"account"],[[NSUserDefaults standardUserDefaults] objectForKey:@"password"]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        //根据错误码显示错误提示语
        [MBProgressHUD showErrorForErrorCode:error.code];

        
    }];
    
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
    loginView.delegate = self;
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

#pragma mark - JHLoginRegisterDelegate
- (void)loginButtonClick:(JHLoginRegister *)view {
    
    //取出本地化存储中的账号和密码并比对用户输入的账号和密码
    NSUserDefaults *userInfo = [NSUserDefaults standardUserDefaults];
    if ([userInfo objectForKey:@"account"] == view.accountTextField.text) {
        if ([userInfo objectForKey:@"password"] == view.passwordTextField.text) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLogined"];
            JHTabBarController *tabBarVC = [[JHTabBarController alloc] init];
            [[UIApplication sharedApplication].keyWindow setRootViewController:tabBarVC];

    
        } else {
            [MBProgressHUD showError:@"密码错误"];
        }
    } else {
        [MBProgressHUD showError:@"账号不存在"];
    }
}



@end
