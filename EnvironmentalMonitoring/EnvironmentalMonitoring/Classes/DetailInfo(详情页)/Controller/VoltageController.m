//
//  VoltageController.m
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/5/16.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import "VoltageController.h"
#import "VoltageCell.h"
#import <MJRefresh/MJRefreshNormalHeader.h>

@interface VoltageController () <UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *CollectionView;
@property (weak, nonatomic) IBOutlet UILabel *deviceIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *DataLabel;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UILabel *refreshMode;
@property (nonatomic, strong) NSTimer *timer;

@end

static NSString *ID = @"cell";
static NSUInteger isRefresh = 0;


@implementation VoltageController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //创建UICollectionViewFlowLayout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake(100, 100);
    _CollectionView.collectionViewLayout = layout;
    
    //注册Cell
    [_CollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([VoltageCell class]) bundle:nil] forCellWithReuseIdentifier:ID];
    
    //创建上拉刷新
    self.mainScrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self  refreshingAction:@selector(refreshData)];
    
    //设置数据和发送网络请求
    _dataArray = [NSMutableArray arrayWithArray:@[@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0"]];
    [self getAllVoltage];
    _deviceIDLabel.text = [NSString stringWithFormat:@"设备ID:%@", _deviceID];
    self.title = _deviceName;
    // Do any additional setup after loading the view from its nib.
    
    //定时器组
    [self setupTimer];
    
    //数据详情
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"数据详情" style:UIBarButtonItemStylePlain target:self action:@selector(dataDetail)];
    
}

- (void)dataDetail {
    NSLog(@"111");
}

- (void)setupTimer {
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


//刷新数据
- (void)refreshData {
    //标志为刷新状态
    isRefresh = 1;
    [self getAllVoltage];
}



- (void)getAllVoltage {
    //设置url
    NSString *urlStr = [[base_url stringByAppendingPathComponent:self.deviceID] stringByAppendingPathComponent:@"datastreams"];
    
    //设置参数
    NSDictionary *parameters = @{@"datastream_ids" : @"data"};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:Api_key forHTTPHeaderField:@"api-key"];
    
    [manager GET:urlStr parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //取出data数据
        if ([responseObject[@"error"] isEqualToString:@"succ"]) {
        NSArray *data = responseObject[@"data"];
        NSString *current_value = [[data objectAtIndex:0] objectForKey:@"current_value"];
        _DataLabel.text = [NSString stringWithFormat:@"更新时间:%@",[[data objectAtIndex:0] objectForKey:@"update_at"]];
        [_dataArray removeAllObjects];
            if (current_value.length != 134) {
                return;
            }
        for (int i = 0; i < 10; ++i) {
            NSString *subStr = [current_value substringFromIndex:14];
            NSString *str = [subStr substringWithRange:NSMakeRange(i * 12, 12)];
            [_dataArray addObject:str];
        }
        [self.CollectionView reloadData];
            //选择提示语
        if (isRefresh == 1) {
            [MBProgressHUD showSuccess:@"刷新成功"];
        } else {
            [MBProgressHUD showSuccess:@"加载成功"];
        }
            [self.mainScrollView.mj_header endRefreshingWithCompletionBlock:^{
            isRefresh = 0;
        }];
            
        } else {
            [MBProgressHUD showError:@"数据出错"];
            [self.mainScrollView.mj_header endRefreshing];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD showErrorForErrorCode:error.code];
    }];
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VoltageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    cell.titleLabel.text = @(indexPath.row + 1).stringValue;
    cell.voltageValue.text = _dataArray[indexPath.row];
    return cell;
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
