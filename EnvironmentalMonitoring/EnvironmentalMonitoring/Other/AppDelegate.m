//
//  AppDelegate.m
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/3/31.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import "AppDelegate.h"
#import "JHLoginRegisterController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //创建UI窗口
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    //创建登录控制器
    JHLoginRegisterController *loginVC = [[JHLoginRegisterController alloc] init];
    loginVC.view.backgroundColor = [UIColor grayColor];
    
    //设置根控制器
    [_window setRootViewController:loginVC];
    
    //显示UI窗口
    [_window makeKeyAndVisible];
    
    UINavigationBar *bar = [UINavigationBar appearance];
    
    [bar setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Bold" size:18.0]}];
    
    //或者用这个都行
    
    
    //    [bar setTitleTextAttributes:@{UITextAttributeTextColor : [UIColor whiteColor]}];
    
    
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
