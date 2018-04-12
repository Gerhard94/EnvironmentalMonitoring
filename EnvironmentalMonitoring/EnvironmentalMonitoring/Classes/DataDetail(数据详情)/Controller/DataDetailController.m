//
//  DataDetailController.m
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/4/9.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import "DataDetailController.h"
#import "AAChartKit.h"
#import "DataDetail.h"
#import "DataDetailCell.h"
@interface DataDetailController ()

@property (nonatomic, strong) AAChartView *aaChartView;

@property (nonatomic, copy) NSString *updataTimeStr;

@property (nonatomic, copy) NSString *beforeHourTimeStr;

@property (nonatomic, strong) DataDetail *airTempArray;

@property (nonatomic, strong) DataDetail *funTempArray;

@property (nonatomic, strong) DataDetail *roomTempArray;

@property (nonatomic, strong) DataDetail *roomHumiArray;

@property (nonatomic, strong) NSMutableArray *airTempX;

@property (nonatomic, strong) NSMutableArray *airTempY;

@property (nonatomic, strong) NSMutableArray *roomTempY;

@property (nonatomic, strong) NSMutableArray *roomHumiY;

@property (nonatomic, strong) NSMutableArray *funTempY;

@property (nonatomic, assign) BOOL isOpen;

@property (nonatomic, strong)NSIndexPath * selectedIndex;



@end

static NSString *ID = @"cell";

@implementation DataDetailController

#pragma mark - 懒加载

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"数据详情";
        //替换模型名称
        [DataDetail mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
            return @{  @"idField" : @"id"
                       };
        }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _airTempX = [NSMutableArray arrayWithCapacity:0];
    _airTempY = [NSMutableArray arrayWithCapacity:0];
    _funTempY = [NSMutableArray arrayWithCapacity:0];
    _roomTempY = [NSMutableArray arrayWithCapacity:0];
    _roomHumiY = [NSMutableArray arrayWithCapacity:0];
    
    [self getOneHourSpace];
    [self checkDataByDate];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DataDetailCell class]) bundle:nil] forCellReuseIdentifier:ID];
    
    _isOpen = YES;
}

- (void)getOneHourSpace {
    //初始化NSDateFormatter 对象
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    //设置时间格式
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    //设置时区
    [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:+8]];
    
    //将字符串转换成时期
    NSDate *date = [dateFormat dateFromString:self.updataTime];
    
    //获得前一个小时的日期
    NSDate *dateBeforeHour = [date dateByAddingTimeInterval:-1800];
    
    //转成成字符串
    NSString *strDateBeforeHour = [dateFormat stringFromDate:dateBeforeHour];
    
    //转成服务器参数格式
    _beforeHourTimeStr = [strDateBeforeHour stringByReplacingOccurrencesOfString:@" " withString:@"T"];
    _updataTime = [self.updataTime stringByReplacingOccurrencesOfString:@" " withString:@"T"];
    
}

- (void)checkDataByDate {
    NSString *urlStr = [[base_url stringByAppendingPathComponent:self.deviceID] stringByAppendingPathComponent:@"datapoints"];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    parameters[@"datastream_id"] = @"room_temp,room_humi,fun_temp,air_temp";
    parameters[@"start"] = _beforeHourTimeStr;
    parameters[@"end"] = _updataTime;
    parameters[@"limit"] = @720;
    parameters[@"sort"] = @"DESC";
    
    
    //emmmm 写过很多次不洗了 就夹心我爱你
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:Api_key forHTTPHeaderField:@"api-key"];
    
    [manager GET:urlStr parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *datastreams = responseObject[@"data"][@"datastreams"];
        for (int i = 0; i < datastreams.count; ++i) {
            NSArray *array = datastreams[i];
            switch (i) {
                case 0:
                    _airTempArray = [DataDetail mj_objectWithKeyValues:array];
                    break;
                case 1:
                    _funTempArray = [DataDetail mj_objectWithKeyValues:array];
                    break;
                case 2:
                    _roomHumiArray = [DataDetail mj_objectWithKeyValues:array];
                    break;
                case 3:
                    _roomTempArray = [DataDetail mj_objectWithKeyValues:array];
                    break;
                default:
                    break;
            }
        }
    
        for (NSDictionary *dict in _airTempArray.datapoints) {
            NSString *dateStr = dict[@"at"];
            dateStr = [dateStr substringWithRange:NSMakeRange(11, 8)];
            [_airTempX addObject:dateStr];
            [_airTempY addObject:dict[@"value"]];
        }
        
        for (NSDictionary *dict in _funTempArray.datapoints) {
             [_funTempY addObject:dict[@"value"]];
        }
        
        for (NSDictionary *dict in _roomTempArray.datapoints) {
            [_roomTempY addObject:dict[@"value"]];
        }
        
        for (NSDictionary *dict in _roomHumiArray.datapoints) {
             [_roomHumiY addObject:dict[@"value"]];
        }
        
//        [self setupChartView];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD showErrorForErrorCode:error.code];
    }];
}

- (AAChartModel *)setupAAChartModel {
    
    NSString *dateStr = [_updataTime substringToIndex:10];
    AAChartModel *aaChartModal = AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeSpline)
    .titleSet([NSString stringWithFormat:@"温度统计图——%@",dateStr])
    .zoomTypeSet(AAChartZoomTypeX)
    .animationTypeSet(AAChartAnimationEaseInSine)
    .categoriesSet(_airTempX)
    .yAxisTitleSet(@"摄氏度")
    .seriesSet(@[
                 AAObject(AASeriesElement).nameSet(@"房间温度").dataSet(_roomTempY).colorSet(@"#ff6699"),
                 AAObject(AASeriesElement).nameSet(@"空调温度").dataSet(_airTempY).colorSet(@"#3366ff"),
                 AAObject(AASeriesElement).nameSet(@"排气扇温度").dataSet(_funTempY).colorSet(@"#FFFF00")
                             
                             ]
                           );
    return aaChartModal;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DataDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    AAChartModel *chartModel = [self setupAAChartModel];
    NSString *dateStr = [_updataTime substringToIndex:10];
    if (indexPath.row == 0) {
        cell.titleLabel.text = @"温度统计图";
    } else {
        cell.titleLabel.text = @"湿度统计图";
        chartModel.chartTypeSet(AAChartTypeAreaspline);
        chartModel.titleSet([NSString stringWithFormat:@"湿度统计图——%@",dateStr]);
        chartModel.seriesSet(@[
                               AAObject(AASeriesElement).nameSet(@"房间湿度%").dataSet(_roomHumiY).colorSet(@"#FF0000")
                                ]
                              );
        
    }
    [cell.aaChartView aa_drawChartWithChartModel:chartModel];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    //判断选中不同row状态时候
    //    if (self.selectedIndex != nil && indexPath.row != selectedIndex.row) {
    if (self.selectedIndex != nil && indexPath.row == _selectedIndex.row) {
        //将选中的和所有索引都加进数组中
        //        indexPaths = [NSArray arrayWithObjects:indexPath,selectedIndex, nil];
        _isOpen = !_isOpen;
        
    }else if (self.selectedIndex != nil && indexPath.row != _selectedIndex.row) {
        indexPaths = [NSArray arrayWithObjects:indexPath,_selectedIndex, nil];
        _isOpen = YES;
        
    }
    
    //记下选中的索引
    self.selectedIndex = indexPath;
    
    //刷新
    [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _selectedIndex.row && _selectedIndex != nil ) {
        if (_isOpen == YES) {
            return 461;
            
        }else{
            return 44;
        }
    }
    return 44;
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
