//
//  AddDeviceController.m
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/4/3.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import "AddDeviceController.h"


@interface AddDeviceController ()

@property (weak, nonatomic) IBOutlet UITextField *titleTF;

@property (weak, nonatomic) IBOutlet UITextField *auth_infoTF;

@property (weak, nonatomic) IBOutlet UITextField *tagsTF;

@property (weak, nonatomic) IBOutlet UISegmentedControl *privateSegment;

@property (weak, nonatomic) IBOutlet UITextField *descTF;

@property (weak, nonatomic) IBOutlet UITextField *lonTF;

@property (weak, nonatomic) IBOutlet UITextField *latTF;
@end

@implementation AddDeviceController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)confirmButtonClick:(id)sender {
    if (self.titleTF.text.length == 0 || self.auth_infoTF.text.length == 0) {
        [MBProgressHUD showError:@"带*的必填项不能为空"];
        return;
    }
    
    
    
    
    [MBProgressHUD showSuccess:@"创建设备成功"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addDevice {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:Api_key forHTTPHeaderField:@"api-key"];
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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
