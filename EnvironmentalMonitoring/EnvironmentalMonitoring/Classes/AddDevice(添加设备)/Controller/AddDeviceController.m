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


/**
 点击确认按钮
 */
- (IBAction)confirmButtonClick:(id)sender {
    if (self.titleTF.text.length == 0 || self.auth_infoTF.text.length == 0) {
        [MBProgressHUD showError:@"带*的必填项不能为空"];
        return;
    }
    
    [self addDevice];
}


/**
 发送添加设备的网络请求
 */
- (void)addDevice {

    //请求字典参数
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    parameters[@"title"] = self.titleTF.text;
    parameters[@"auth_info"] = self.auth_infoTF.text;
    parameters[@"desc"] = self.descTF.text.length > 0 ? self.descTF.text : nil;
    parameters[@"tags"] = self.tagsTF.text.length > 0 ? @[[NSString stringWithFormat:@"%@",self.tagsTF.text]] : nil;
    parameters[@"private"] = self.privateSegment.selectedSegmentIndex == 0 ? @"true" : @"false";
    parameters[@"location"] = @{@"lon" : self.lonTF.text ,@"lat" : self.latTF.text};
    
    //创建manager
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    //创建request
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:base_url parameters:parameters error:nil];
    
    //设置网络请求超时时间和http头部
    request.timeoutInterval = 8.f;
    [request setValue:Api_key forHTTPHeaderField:@"api-key"];
    
    //创建会话并发送网络请求
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            if ([responseObject[@"error"] isEqualToString:@"succ"]) {
                // 请求成功数据处理
                [[NSUserDefaults standardUserDefaults] setObject:@"pop" forKey:@"isPop"];
                [MBProgressHUD showSuccess:@"创建设备成功"];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [MBProgressHUD showError:responseObject[@"error"]];
            }
        } else {
            NSString *errorStr;
            //根据错误码显示错误提示语
            switch (error.code) {
                case -1001:
                    errorStr = @"网络请求超时";
                    break;
                case -1009:
                    errorStr = @"没有网络连接";
                    break;
                default:
                    errorStr = @"网络错误";
                    break;
            }
            [MBProgressHUD showError:errorStr];
        }
    }];
    
    [task resume];

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
