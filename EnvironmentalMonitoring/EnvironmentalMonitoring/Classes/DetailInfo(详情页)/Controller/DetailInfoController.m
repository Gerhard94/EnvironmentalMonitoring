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

//是个ScrollView
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

//画了个圆
@property (weak, nonatomic) IBOutlet UIView *circleView;

//设备ID
@property (weak, nonatomic) IBOutlet UILabel *deviceIDLabel;

//房间温湿度 空调和风扇的温度
@property (weak, nonatomic) IBOutlet UILabel *roomTemp;
@property (weak, nonatomic) IBOutlet UILabel *roomHumi;
@property (weak, nonatomic) IBOutlet UILabel *airTemp;
@property (weak, nonatomic) IBOutlet UILabel *funTemp;

//漏水报警器 烟雾探测器 房门柜门闭合检测器
@property (weak, nonatomic) IBOutlet UILabel *waterLeakage;
@property (weak, nonatomic) IBOutlet UILabel *smokeDetector;
@property (weak, nonatomic) IBOutlet UILabel *roomDoorIsClose;
@property (weak, nonatomic) IBOutlet UILabel *cabinetDoorIsClose;

//更新时间 刷新模型
@property (weak, nonatomic) IBOutlet UILabel *updateTime;
@property (weak, nonatomic) IBOutlet UILabel *refreshMode;

//数据详情
@property (weak, nonatomic) IBOutlet UIView *dataDetail;

//模型数组
@property (nonatomic, strong) NSMutableArray *resultArray;

//定时器
@property (nonatomic, strong) NSTimer *timer;
@end

static NSUInteger isRefresh = 0;

@implementation DetailInfoController

- (NSMutableArray *)resultArray {
    if (_resultArray == nil) {
        _resultArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _resultArray;
}

#pragma mark - 控制器生命周期
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_timer setFireDate:[NSDate distantPast]];
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
    
    NSUInteger refreshSecond = [[[NSUserDefaults standardUserDefaults] valueForKey:@"autoRefresh"] integerValue];
    self.refreshMode.text = refreshSecond == 0 ? @"手动刷新" : [NSString stringWithFormat:@"自动刷新: %lu秒",(unsigned long)refreshSecond];
    if (refreshSecond != 0) {
        _timer = [NSTimer timerWithTimeInterval:refreshSecond target:self selector:@selector(refreshData) userInfo:nil repeats:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(refreshSecond * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
        });
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_timer setFireDate:[NSDate distantFuture]];
    
    //解决关闭定时器后进来提示语错误bug
    isRefresh = 0;
}

//点击数据详情
- (void)pushDataDeatil {
    DataDetailController *dataDetailVC = [[DataDetailController alloc] init];
    dataDetailVC.updataTime = self.updateTime.text;
    dataDetailVC.deviceID = self.deviceIDLabel.text;
    [self.navigationController pushViewController:dataDetailVC animated:YES];
}

//刷新数据
- (void)refreshData {
    //标志为刷新状态
    isRefresh = 1;
    [self checkMoreDatastreams];
}

//发送网络请求
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
            
            //展示数据
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
            
            //选择提示语
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
