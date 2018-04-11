//
//  AutoRefrshController.m
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/4/11.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import "AutoRefrshController.h"
#import "JHView.h"
@interface AutoRefrshController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *autoRefreshSwitch;
@property (weak, nonatomic) IBOutlet JHView *setRefreshSecond;
@property (weak, nonatomic) IBOutlet UISlider *Slider;
@property (weak, nonatomic) IBOutlet UITextField *secondField;

@end

@implementation AutoRefrshController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"自动刷新设置";
    NSUInteger refreshSecond = [[[NSUserDefaults standardUserDefaults] valueForKey:@"autoRefresh"] integerValue];

    self.autoRefreshSwitch.on = refreshSecond != 0;
    [self.autoRefreshSwitch addTarget:self action:@selector(hiddenSetFreshView) forControlEvents:UIControlEventTouchUpInside];
    [self hiddenSetFreshView];
    
    self.Slider.continuous = YES;
    self.Slider.value = (float)refreshSecond;
    [self.Slider addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];

    self.secondField.delegate = self;
    self.secondField.text = [NSString stringWithFormat:@"%lu",(unsigned long)refreshSecond];
    
}

-(void)hiddenSetFreshView {
    self.setRefreshSecond.hidden = !self.autoRefreshSwitch.on;
    if (self.autoRefreshSwitch.on == NO) {
            [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"autoRefresh"];
    }
}

- (void)valueChanged {
    self.secondField.text = @(@(self.Slider.value).integerValue).stringValue;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)comfirmButtonClick:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:self.secondField.text forKey:@"autoRefresh"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newInput = [textField.text stringByReplacingCharactersInRange:range withString:string];
    float value = [newInput floatValue];
    if (value >= 0 && value <= 60) {
        self.Slider.value = value;
        return YES;
    } else
        return NO;
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
