//
//  JHMainController.m
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/4/2.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import "JHMainController.h"

@interface JHMainController ()

@property (weak, nonatomic) IBOutlet UIView *addDeviceView;

@end

@implementation JHMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.addDeviceView.layer.borderColor = [UIColor colorWithRed:201.0/255.0 green:201.0/255.0 blue:206.0/255.0 alpha:1].CGColor;
    // Do any additional setup after loading the view from its nib.
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"配电房列表";
        
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
