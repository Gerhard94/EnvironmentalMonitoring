//
//  AddDeviceController.m
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/4/3.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import "AddDeviceController.h"
#import "DeviceList.h"
#import "Location.h"
@interface AddDeviceController ()

@property (weak, nonatomic) IBOutlet UITextField *titleTF;

@property (weak, nonatomic) IBOutlet UITextField *auth_infoTF;

@property (weak, nonatomic) IBOutlet UITextField *tagsTF;

@property (weak, nonatomic) IBOutlet UISegmentedControl *privateSegment;

@property (weak, nonatomic) IBOutlet UITextField *descTF;

@property (weak, nonatomic) IBOutlet UITextField *lonTF;

@property (weak, nonatomic) IBOutlet UITextField *latTF;


@end

static NSString *originAuthInfo;

@implementation AddDeviceController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.title = _deviceList == nil ? @"添加设备" : @"更新设备信息";
    
    if (_deviceList != nil) {
        [self displayDeviceInfo];
    }
    
}

- (void)displayDeviceInfo {
    _titleTF.text = _deviceList.title;
    _auth_infoTF.text = _deviceList.auth_info;
    _tagsTF.text = _deviceList.tags;
    _privateSegment.selectedSegmentIndex = _deviceList.privateField ? 0 : 1;
    _descTF.text = _deviceList.desc;
    _lonTF.text = _deviceList.location.lon;
    _latTF.text = _deviceList.location.lat;
    originAuthInfo = _deviceList.auth_info;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setDeviceList:(DeviceList *)deviceList {
    _deviceList = deviceList;

}


/**
 点击确认按钮
 */
- (IBAction)confirmButtonClick:(id)sender {
    if (self.titleTF.text.length == 0 || self.auth_infoTF.text.length == 0) {
        [MBProgressHUD showError:@"带*的必填项不能为空"];
        return;
    }
    if (_deviceList == nil) {
        [self addDevice];
    } else {
        [self updateDeviceInfo:_deviceList.idField];
    }
}


#pragma mark - 发送网络请求
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

    if ([self.lonTF.text integerValue] > 180) {
        [MBProgressHUD showError:@"经度不能大于180°"];
        return;
    }

    if ([self.latTF.text integerValue] > 90) {
        [MBProgressHUD showError:@"纬度不能大于90°"];
        return;
    }
    
    if (self.lonTF.text.length != 0 && self.latTF.text != 0) {
        parameters[@"location"] = @{@"lon" : self.lonTF.text ,@"lat" : self.latTF.text};
    } else if (self.lonTF.text.length > 0) {
        parameters[@"location"] = @{@"lon" : self.lonTF.text};
    } else if (self.latTF.text.length > 0) {
        parameters[@"location"] = @{@"lat" : self.latTF.text};
    }
    

    
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
                [[NSNotificationCenter defaultCenter] postNotificationName:@"isChange" object:nil];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [MBProgressHUD showError:responseObject[@"error"]];
            }
        } else {
            //根据错误码显示错误提示语
            [MBProgressHUD showErrorForErrorCode:error.code];
        }
    }];
    
    [task resume];

}

- (void)updateDeviceInfo:(NSString *)deviceID {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    parameters[@"title"] = self.titleTF.text;
    if (![self.auth_infoTF.text isEqualToString:originAuthInfo]) {
        parameters[@"auth_info"] = self.auth_infoTF.text;
    }
    parameters[@"desc"] = self.descTF.text.length > 0 ? self.descTF.text : nil;
    parameters[@"tags"] = self.tagsTF.text.length > 0 ? @[[NSString stringWithFormat:@"%@",self.tagsTF.text]] : nil;
    parameters[@"private"] = self.privateSegment.selectedSegmentIndex == 0 ? @"true" : @"false";
    
    if ([self.lonTF.text integerValue] > 180) {
        [MBProgressHUD showError:@"经度不能大于180°"];
        return;
    }
    
    if ([self.latTF.text integerValue] > 90) {
        [MBProgressHUD showError:@"纬度不能大于90°"];
        return;
    }
    
    if (self.lonTF.text.length != 0 && self.latTF.text != 0) {
        parameters[@"location"] = @{@"lon" : self.lonTF.text ,@"lat" : self.latTF.text};
    } else if (self.lonTF.text.length > 0) {
        parameters[@"location"] = @{@"lon" : self.lonTF.text};
    } else if (self.latTF.text.length > 0) {
        parameters[@"location"] = @{@"lat" : self.latTF.text};
    }
    
    
    NSString *urlStr = [base_url stringByAppendingPathComponent:deviceID];
    
    //创建manager
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    //创建request
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"PUT" URLString:urlStr parameters:parameters error:nil];
    
    //设置网络请求超时时间和http头部
    request.timeoutInterval = 8.f;
    [request setValue:Api_key forHTTPHeaderField:@"api-key"];

    //创建会话并发送网络请求
    
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            if ([responseObject[@"error"] isEqualToString:@"succ"]) {
                // 请求成功数据处理
                [[NSUserDefaults standardUserDefaults] setObject:@"pop" forKey:@"isPop"];
                [MBProgressHUD showSuccess:@"更新设备成功"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"isChange" object:nil];
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
