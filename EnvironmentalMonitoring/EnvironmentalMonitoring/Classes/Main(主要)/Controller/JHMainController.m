//
//  JHMainController.m
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/4/2.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import "JHMainController.h"
#import <MJExtension/MJExtension.h>
#import "DeviceList.h"
#import "JHMainCell.h"
#import "AddDeviceController.h"

@interface JHMainController () <UITableViewDelegate,UITableViewDataSource,UISearchResultsUpdating,UISearchBarDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UISearchController *searchController;

@property (nonatomic, strong) NSMutableArray *datas;

@property (nonatomic, strong) NSMutableArray *results;


@end

static NSString *ReuseId = @"ReuseId";

@implementation JHMainController

#pragma mark - 懒加载
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (NSMutableArray *)datas {
    if (_datas == nil) {
        _datas = [NSMutableArray arrayWithCapacity:0];
    }
    return _datas;
}

- (NSMutableArray *)results {
    if (_results == nil) {
        _results = [NSMutableArray arrayWithCapacity:0];
    }
    return _results;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置右边按钮
    UIImage *image = [UIImage imageNamed:@"plus"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(addDevice)];

    //创建SearchController
    [self setupSearchController];
    
    //获取设备信息
    [self getDeviceList];
    
    //注册cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([JHMainCell class]) bundle:nil] forCellReuseIdentifier:ReuseId];
}

- (void)addDevice {
    AddDeviceController *addDeviceVC = [[AddDeviceController alloc] init];
    [self.navigationController pushViewController:addDeviceVC animated:YES];
}


- (void)getDeviceList {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:Api_key forHTTPHeaderField:@"api-key"];
    [manager GET:base_url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //获取设备信息数组
        NSDictionary *data = [responseObject objectForKey:@"data"];
        NSArray *devices = [data objectForKey:@"devices"];
        NSMutableArray *arrayTemp = [NSMutableArray array];
        
        //隐藏管理账号密码的设备
        for (NSDictionary *dict in devices) {
            if (![dict[@"title"]  isEqual: @"admin"]) {
                [arrayTemp addObject:dict];
            }
        }
        
        //数组转模型
        _datas = [DeviceList mj_objectArrayWithKeyValuesArray:arrayTemp];
        
        //刷新表格
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
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
        
    }];
}




- (void)setupSearchController {
    //初始化
    UISearchController *search = [[UISearchController alloc] initWithSearchResultsController:nil];
    
    //设置代理
    search.searchResultsUpdater = self;
    
    //窗口透明化
    search.dimsBackgroundDuringPresentation = NO;
    
    search.searchBar.placeholder = @"快速搜索";
    
    //编辑搜索时隐藏导航栏
    search.hidesNavigationBarDuringPresentation = YES;
    
    search.searchBar.delegate = self;
    self.searchController = search;
    
    //searchBar作为tableView的头部视图
    self.tableView.tableHeaderView = search.searchBar;
    
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"配电房列表";
        //替换模型名称
        [DeviceList mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
            return @{  @"idField" : @"id",
                       @"privateField" : @"private"
                    };
        }];
            
    }
    return self;
}

#pragma mark - tableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchController.active ? self.results.count : self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JHMainCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseId];
    
    if (self.searchController.active) {
        DeviceList *deviceList = self.results[indexPath.row];
        cell.deviceList = deviceList;
    } else {
        DeviceList *deviceList = self.datas[indexPath.row];
        cell.deviceList = deviceList;
    }
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *inputStr = searchController.searchBar.text;
    if (self.results.count > 0) {
        [self.results removeAllObjects];
    }
    for (DeviceList *deviceList in self.datas) {
        if ([deviceList.title.lowercaseString rangeOfString:inputStr.lowercaseString].location != NSNotFound ||
            [deviceList.idField.lowercaseString rangeOfString:inputStr.lowercaseString].location != NSNotFound ||
            [deviceList.auth_info.lowercaseString rangeOfString:inputStr.lowercaseString].location != NSNotFound
            ) {
                [self.results addObject:deviceList];
        }
        [self.tableView reloadData];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"点击了删除");
    }];
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"编辑" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"点击了编辑");
    }];
    editAction.backgroundColor = [UIColor grayColor];
    return @[deleteAction,editAction];

}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 130;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    
    return YES;
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
