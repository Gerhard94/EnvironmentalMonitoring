//
//  DetailInfoController.m
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/4/8.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import "DetailInfoController.h"
#import "DetailInfo.h"
#import <MJRefresh/MJRefreshNormalHeader.h>
#import "DataDetailController.h"

@interface DetailInfoController ()
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIView *circleView;
@property (weak, nonatomic) IBOutlet UILabel *deviceIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomTemp;
@property (weak, nonatomic) IBOutlet UILabel *updateTime;
@property (weak, nonatomic) IBOutlet UILabel *roomHumi;
@property (weak, nonatomic) IBOutlet UILabel *waterLeakage;
@property (weak, nonatomic) IBOutlet UILabel *smokeDetector;
@property (weak, nonatomic) IBOutlet UILabel *roomDoorIsClose;
@property (weak, nonatomic) IBOutlet UILabel *airTemp;
@property (weak, nonatomic) IBOutlet UILabel *funTemp;
@property (weak, nonatomic) IBOutlet UILabel *cabinetDoorIsClose;

@property (nonatomic, strong) NSMutableArray *resultArray;

@property (weak, nonatomic) IBOutlet UIView *dataDetail;

@end

static NSUInteger isRefresh = 0;

@implementation DetailInfoController

- (NSMutableArray *)resultArray {
    if (_resultArray == nil) {
        _resultArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _resultArray;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        //替换模型名称
        [DetailInfo mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
            return @{  @"idField" : @"id"
                       };
        }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:nil];
    //设置标题和ID
    self.title = _deviceName;
    self.deviceIDLabel.text = self.deviceID;
    // Do any additional setup after loading the view from its nib.
    
    //画一个圆圈
    [self setupTempAndHumi];
    
    //发送网络请求
    [self checkMoreDatastreams];
    
    //创建上拉刷新
    self.mainScrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    
    //添加点击手势
    UITapGestureRecognizer *panGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushDataDeatil)];
    [self.dataDetail addGestureRecognizer:panGesture];
}

- (void)pushDataDeatil {
    DataDetailController *dataDetailVC = [[DataDetailController alloc] init];
    dataDetailVC.updataTime = self.updateTime.text;
    dataDetailVC.deviceID = self.deviceIDLabel.text;
    [self.navigationController pushViewController:dataDetailVC animated:YES];
}

- (void)refreshData {
    //标志为刷新状态
    isRefresh = 1;
    [self checkMoreDatastreams];
}

- (void)checkMoreDatastreams {
    //设置url
    NSString *urlStr = [[base_url stringByAppendingPathComponent:self.deviceID] stringByAppendingPathComponent:@"datastreams"];
    
    //设置参数
    NSDictionary *parameters = @{@"datastream_ids" : @"room_temp,smoke_detector,room_humi,water_leakage,fun_temp,cabinet_door_isClose,air_temp,room_door_isClose"};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:Api_key forHTTPHeaderField:@"api-key"];
    [manager GET:urlStr parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *dataArray = responseObject[@"data"];
        //将数据数组转成模型数组
        _resultArray = [DetailInfo mj_objectArrayWithKeyValuesArray:dataArray];
        
        //取出数组
        for (int i = 0; i < _resultArray.count; ++i) {
            DetailInfo *detailInfo = _resultArray[i];
            NSString *state = [detailInfo.current_value isEqualToString:@"0"] ? @"正常" : @"异常";
            switch (i) {
                case 0:
                    self.roomTemp.text = [detailInfo.current_value stringByAppendingString:@"°"];
                    self.updateTime.text = detailInfo.update_at;
                    break;
                case 1:
                    self.smokeDetector.text = [NSString stringWithFormat:@"状态: %@",state];
                    break;
                case 2:
                    self.roomHumi.text = [detailInfo.current_value stringByAppendingString:@"%"];
                    break;
                case 3:
                    self.waterLeakage.text = [NSString stringWithFormat:@"状态: %@",state];
                    break;
                case 4:
                    self.funTemp.text = [NSString stringWithFormat:@"排气扇温度: %@°",detailInfo.current_value];
                    break;
                case 5:
                    self.cabinetDoorIsClose.text = [NSString stringWithFormat:@"电柜门状态: %@",state];
                    break;
                case 6:
                    self.airTemp.text = [NSString stringWithFormat:@"空调温度: %@°",detailInfo.current_value];
                    break;
                case 7:
                    self.roomDoorIsClose.text = [NSString stringWithFormat:@"状态: %@",state];
                default:
                    break;
            }
            
            if (isRefresh == 1) {
                [MBProgressHUD showSuccess:@"刷新成功"];
            } else {
                [MBProgressHUD showSuccess:@"加载成功"];
            }
            
            [self.mainScrollView.mj_header endRefreshingWithCompletionBlock:^{
                isRefresh = 0;
            }];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD showErrorForErrorCode:error.code];
    }];
}

- (void)setupTempAndHumi {
    self.circleView.layer.borderColor = [UIColor colorWithHexString:@"3399ff"].CGColor;
    self.circleView.layer.cornerRadius = self.circleView.frame.size.width / 2.0;
    self.circleView.layer.borderWidth = 5;
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
