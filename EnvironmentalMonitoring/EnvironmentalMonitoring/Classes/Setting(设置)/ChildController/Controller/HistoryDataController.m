//
//  HistoryDataController.m
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/4/17.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import "HistoryDataController.h"
#import <PGDatePicker/PGDatePickManager.h>
#import "HistoryDataCell.h"
#import "DataDetail.h"
#import "Datapoints.h"
#import <MJRefresh/MJRefreshNormalHeader.h>
#import <MJRefresh/MJRefreshBackNormalFooter.h>
#import "HistoryOfVoltageCell.h"
#import <LibXL/libxl.h>


@interface HistoryDataController () <PGDatePickerDelegate,UITableViewDelegate,UITableViewDataSource,UIDocumentInteractionControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *startTime;
@property (weak, nonatomic) IBOutlet UIButton *endTime;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@property (nonatomic, copy) NSString *startTimeStr;
@property (nonatomic, copy) NSString *endTimeStr;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *voltageArray;
@property (nonatomic, strong) NSMutableArray *room_temp;
@property (nonatomic, strong) NSMutableArray *room_humi;
@property (nonatomic, strong) NSMutableArray *fun_temp;
@property (nonatomic, strong) NSMutableArray *air_temp;
@property (nonatomic, strong) NSMutableArray *water_leakage;
@property (nonatomic, strong) NSMutableArray *cabinet_door_isClose;
@property (nonatomic, strong) NSMutableArray *room_door_isClose;
@property (nonatomic, strong) NSMutableArray *smoke_detector;

@property (weak, nonatomic) IBOutlet UIView *exportDataView;

@property (nonatomic, strong) NSMutableArray *atDate;

@end

static NSInteger tag = 1;
static NSString *cursor = @"";
static NSString *ID = @"cell";

@implementation HistoryDataController

- (instancetype)init {
    if (self = [super init]) {
        self.title = @"查看历史数据";
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
    
    [self setupBorder];
    // Do any additional setup after loading the view.
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([HistoryOfVoltageCell class]) bundle:nil] forCellReuseIdentifier:ID];
    
    UIButton *headerView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    [headerView setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
    [headerView setTitle:@"导出日志" forState:UIControlStateNormal];
    [headerView setImage:[UIImage imageNamed:@"downloadClick"] forState:UIControlStateHighlighted];
    [headerView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [headerView setTitleColor:[UIColor colorWithHexString:@"8a8a8a"] forState:UIControlStateHighlighted];
    [headerView addTarget:self action:@selector(exportData) forControlEvents:UIControlEventTouchUpInside];
    [self.exportDataView addSubview:headerView];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
}

- (void)exportData {
    
    BookHandle book = xlCreateBook(); // use xlCreateXMLBook() for working with xlsx files
    
    SheetHandle sheet = xlBookAddSheet(book, "Sheet1", NULL);
    //第一个参数代表插入哪个表，第二个是第几行（默认从0开始），第三个是第几列（默认从0开始）
    xlSheetWriteStr(sheet, 2, 0, "序号", 0);
    xlSheetWriteStr(sheet, 2, 1, "时期", 0);
    xlSheetWriteStr(sheet, 2, 3, "A1", 0);
    xlSheetWriteStr(sheet, 2, 4, "A2", 0);
    xlSheetWriteStr(sheet, 2, 5, "A3", 0);
    xlSheetWriteStr(sheet, 2, 6, "A4", 0);
    xlSheetWriteStr(sheet, 2, 7, "A5", 0);
    xlSheetWriteStr(sheet, 2, 8, "A6", 0);
    xlSheetWriteStr(sheet, 2, 9, "A7", 0);
    xlSheetWriteStr(sheet, 2, 10, "A8", 0);
    xlSheetWriteStr(sheet, 2, 11, "A9", 0);
    xlSheetWriteStr(sheet, 2, 12, "A10", 0);



    for (int i = 0; i < _voltageArray.count; i++) {
        NSString *str = [NSString stringWithFormat:@"%d",i+1];
        const char *name_c = [str cStringUsingEncoding:NSUTF8StringEncoding];  //这里是将NSString字符串转为C语言字符串
        xlSheetWriteStr(sheet, i+3, 0,name_c, 0);
        
    }
    
    for (int i = 0; i < _voltageArray.count; i++) {
        Datapoints *datapoints = self.voltageArray[i];
        datapoints.at = [datapoints.at substringWithRange:NSMakeRange(0, 19)];
        const char *name_c = [datapoints.at cStringUsingEncoding:NSUTF8StringEncoding];  //这里是将NSString字符串转为C语言字符串
        xlSheetWriteStr(sheet, i+3, 1,name_c, 0);
        
    }
    
    for (int i = 0; i < _voltageArray.count; i++) {
        Datapoints *datapoints = _voltageArray[i];
        if (datapoints.value.length != 134) {
            continue;
        }
        NSInteger role = i;
        for (int i = 0; i < 10; ++i) {
            NSString *str = [[datapoints.value substringFromIndex:14] substringWithRange:NSMakeRange(i * 12, 12)];
            const char *name_c = [str cStringUsingEncoding:NSUTF8StringEncoding];  //这里是将NSString字符串转为C语言字符串
            xlSheetWriteStr(sheet, 3 + role, i + 3,name_c, 0);
        }
        
    }
    
        NSString *infuse = @"注:该日志只保存已经加载的数据,该日志只保存已经加载的数据,该日志只保存已经加载的数据";
        const char *name_c = [infuse cStringUsingEncoding:NSUTF8StringEncoding];  //这里是将NSString字符串转为C语言字符串
        xlSheetWriteStr(sheet, 1, 0,name_c, 0);
    
    
    NSString *documentPath =
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filename = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@日志.xls",self.startTime.titleLabel.text,self.endTime.titleLabel.text]];
    
    xlBookSave(book, [filename UTF8String]);
    
    xlBookRelease(book);
    
    //导出xls文件
    UIDocumentInteractionController *docu = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filename]];
    
    docu.delegate = self;
    CGRect rect = CGRectMake(0, 0, 320, 300);  //这里感觉没什么用
    
    [docu presentOpenInMenuFromRect:rect inView:self.view animated:YES];  //不写可以直接预览
    
    [docu presentPreviewAnimated:YES];
    
    //这句比较坑爹。如果不写这句，只写上面那句会弹出选择支持xls文件的APP。但是如果没写程序就会崩了，
    //LIBXL太大不给push啊
    
}


- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController{
    [MBProgressHUD showMessage:@"请稍后"];
    return self;
    
}
 

- (void)loadNewData {
    cursor = @"";
    [self checkHistoryData];
}

- (void)loadMoreData {
    [self checkHistoryData];
}


- (IBAction)searchButtonClick:(id)sender {
    
    cursor = @"";
    NSDate *date = [NSDate date];
    NSDateFormatter *format1 = [[NSDateFormatter alloc] init];
    [format1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr;
    dateStr = [format1 stringFromDate:date];
    dateStr = [dateStr stringByReplacingOccurrencesOfString:@" " withString:@"T"];
    
    if (_startTimeStr == nil) {
        [MBProgressHUD showError:@"起始时间不能为空"];
        return;
    } else if (_endTimeStr == nil) {
        [MBProgressHUD showError:@"截止时间不能为空"];
        return;
    }

    if ([_startTimeStr compare:dateStr] == 1 ) {
        [MBProgressHUD showError:@"起始时间必须小于当前时间"];
        return;
    } else if ([_startTimeStr compare:_endTimeStr] == 1) {
        [MBProgressHUD showError:@"起始时间必须小于结束时间"];
        return;
    } else if ([_endTimeStr compare:dateStr] == 1) {
        [MBProgressHUD showError:@"结束时间必须小于当前时间"];
        return;
    }

    [self checkHistoryData];
}

- (void)checkHistoryData {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer setValue:Api_key forHTTPHeaderField:@"api-key"];
    
    NSString *urlStr = [[base_url stringByAppendingPathComponent:_IDField] stringByAppendingPathComponent:@"datapoints"];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    parameters[@"datastream_id"] = @"data";
    parameters[@"start"] = _startTimeStr;
    parameters[@"end"] = _endTimeStr;
    parameters[@"limit"] = @20;
    parameters[@"sort"] = @"DESC";
    if (![cursor isEqualToString:@""]) {
        parameters[@"cursor"] = cursor;
    }
    
    
    [manager GET:urlStr parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        cursor = [responseObject objectForKey:@"data"][@"cursor"];
        NSArray *datastreams = responseObject[@"data"][@"datastreams"];
        NSNumber *count = responseObject[@"data"][@"count"];
        self.tableView.hidden = self.exportDataView.hidden = [count isEqual:@0];
        if ([count isEqual:@0]) {
            [MBProgressHUD showError:@"暂无数据"];
            return ;
        }
        
        NSArray *array = [[datastreams objectAtIndex:0] objectForKey:@"datapoints"];
        _voltageArray = [Datapoints mj_objectArrayWithKeyValuesArray:array];
        NSLog(@"%@",array);
        
        //        _room_temp = [DataDetail mj_objectWithKeyValues:datastreams[6]];
        [self.tableView reloadData];
        [MBProgressHUD showSuccess:@"加载成功"];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD showErrorForErrorCode:error.code];
    }];
}

- (void)setupBorder {
    self.startTime.layer.borderWidth = self.endTime.layer.borderWidth =  1;
    self.startTime.layer.borderColor = self.endTime.layer.borderColor = [UIColor colorWithHexString:@"e6e6e6"].CGColor;
    
}

- (IBAction)datePickerClick:(UIButton *)sender {
    PGDatePickManager *datePickManager = [[PGDatePickManager alloc] init];
    PGDatePicker *datePicker = datePickManager.datePicker;
    datePicker.isHiddenMiddleText = NO;
    datePicker.datePickerType = PGDatePickerType3;
    datePicker.delegate = self;
    datePicker.datePickerMode = PGDatePickerModeDateHourMinute;
    datePickManager.isShadeBackgroud = true;
    datePickManager.headerViewBackgroundColor = [UIColor clearColor];
    datePicker.textColorOfOtherRow = [UIColor grayColor];
    [self presentViewController:datePickManager animated:YES completion:nil];
    tag = sender.tag;
}

#pragma PGDatePickerDelegate
- (void)datePicker:(PGDatePicker *)datePicker didSelectDate:(NSDateComponents *)dateComponents {
    NSCalendar * calendar = [NSCalendar autoupdatingCurrentCalendar];
    
    NSDate * date = [calendar dateFromComponents:dateComponents];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSString * str = [formatter stringFromDate:date];
    
    if (tag == 0) {
        str = [@"起始时间: " stringByAppendingString:str];
        [self.startTime setTitle:str forState:UIControlStateNormal];
        str = [[formatter stringFromDate:date] stringByReplacingOccurrencesOfString:@" " withString:@"T"];
        _startTimeStr = str;
    } else {
        str = [@"截止时间: " stringByAppendingString:str];
        [self.endTime setTitle:str forState:UIControlStateNormal];
        str = [[formatter stringFromDate:date] stringByReplacingOccurrencesOfString:@" " withString:@"T"];
        _endTimeStr = str;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _voltageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryOfVoltageCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    Datapoints *datapoint = _voltageArray[indexPath.row];
    cell.points = datapoint;
    /*
*/
    return cell;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 155;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
