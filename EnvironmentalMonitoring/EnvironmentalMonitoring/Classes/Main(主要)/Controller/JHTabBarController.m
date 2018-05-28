//
//  JHTabBarController.m
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/4/8.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import "JHTabBarController.h"
#import "JHMainController.h"
#import "JHNavigationController.h"
#import "SettingController.h"
#import "VoltageController.h"

@interface JHTabBarController ()

@end

@implementation JHTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupAllController];
    
}

- (void)setupAllController {
    /*
    JHMainController *mainVC = [[JHMainController alloc] init];
    JHNavigationController *mainNAV = [[JHNavigationController alloc] initWithRootViewController:mainVC];
    mainNAV.tabBarItem.title = @"列表";
    mainNAV.tabBarItem.image = [UIImage imageNamed:@"list"];
    mainNAV.tabBarItem.selectedImage = [UIImage imageNamed:@"list_click"];
    */
    
    VoltageController *voltageVC = [[VoltageController alloc] init];
    voltageVC.deviceID = @"31019772";
    voltageVC.deviceName = @"设备";
//    JHNavigationController *voltageNVC = [[JHNavigationController alloc] initWithRootViewController:voltageVC];
    voltageVC.tabBarItem.image = [UIImage imageNamed:@"list"];
    voltageVC.tabBarItem.selectedImage = [UIImage imageNamed:@"list_click"];

    
    UIStoryboard *settingSB = [UIStoryboard storyboardWithName:NSStringFromClass([SettingController class]) bundle:nil];
    SettingController *settingVC = [settingSB instantiateInitialViewController];
    JHNavigationController *settingNAV = [[JHNavigationController alloc] initWithRootViewController:settingVC];
    settingNAV.tabBarItem.title = @"设置";
    settingNAV.tabBarItem.image = [UIImage imageNamed:@"setting"];
    settingNAV.tabBarItem.selectedImage = [UIImage imageNamed:@"setting_click"];
    
//    [self addChildViewController:mainNAV];
    [self addChildViewController:voltageVC];
    [self addChildViewController:settingNAV];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
