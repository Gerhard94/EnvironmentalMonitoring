//
//  JHMainController.m
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/4/2.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import "JHMainController.h"
#import "DeviceList.h"
#import "JHMainCell.h"
#import "AddDeviceController.h"
#import <MJRefresh/MJRefreshNormalHeader.h>
#import <MJRefresh/MJRefreshBackNormalFooter.h>
#import "DetailInfoController.h"


@interface JHMainController () <UITableViewDelegate,UITableViewDataSource,UISearchResultsUpdating,UISearchBarDelegate,UIViewControllerPreviewingDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UISearchController *searchController;

@property (nonatomic, strong) NSMutableArray *datas;

@property (nonatomic, strong) NSMutableArray *results;

@property (nonatomic, assign) BOOL isDelete;

@property (nonatomic, strong) NSMutableArray *arrayID;
@property (nonatomic, strong) NSMutableArray *arrayTitle;

@end

static NSString *ReuseId = @"ReuseId";
static NSUInteger page = 2;


@implementation JHMainController

#pragma mark - 懒加载
- (UITableView *)tableView {
    if (_tableView == nil) {
        CGFloat height = IS_iPhoneX ? ScreenH - 83 : ScreenH - 49;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenW, height) style:UITableViewStylePlain];
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



#pragma mark - 控制器生命周期

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.tableView.backgroundColor = [UIColor colorWithHexString:@"ebebeb"];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:nil];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"push" forKey:@"isPop"];
    
    //设置右边按钮
    UIImage *image = [UIImage imageNamed:@"plus"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(addDevice)];

    //创建SearchController
    [self setupSearchController];
    
    //获取设备信息
    [self loadNewData];
    
    //注册cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([JHMainCell class]) bundle:nil] forCellReuseIdentifier:ReuseId];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //判断是否pop进来的
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listShouldRefresh) name:@"isChange" object:nil];
}

- (void)listShouldRefresh {
    [self loadNewData];
}


#pragma mark - 初始化视图控制器
- (void)addDevice {
    AddDeviceController *addDeviceVC = [[AddDeviceController alloc] init];
    addDeviceVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addDeviceVC animated:YES];
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
    self.definesPresentationContext = YES;
    
    search.searchBar.delegate = self;
    self.searchController = search;
    
    //searchBar作为tableView的头部视图
    self.tableView.tableHeaderView = search.searchBar;
}


#pragma mark - 发送网络请求
- (void)loadNewData {
    
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
        
        if (_arrayTitle == nil) {
            _arrayTitle = [NSMutableArray arrayWithCapacity:0];
        }
        
        if (_arrayID == nil) {
            _arrayID = [NSMutableArray arrayWithCapacity:0];
        }
        
        [_arrayID removeAllObjects];
        [_arrayTitle removeAllObjects];
        
        //数组转模型
        _datas = [DeviceList mj_objectArrayWithKeyValuesArray:arrayTemp];
        for (DeviceList *list in _datas) {
            [_arrayID addObject:list.idField];
            [_arrayTitle addObject:list.title];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:_arrayID forKey:@"IDArray"];
        [[NSUserDefaults standardUserDefaults] setObject:_arrayTitle forKey:@"titleArray"];
        
        //刷新表格
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        
        if (_isDelete == YES) {}
        else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isPop"] isEqualToString:@"pop"]) {}
        else {
            [MBProgressHUD showSuccess:@"加载成功"];
}
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD showErrorForErrorCode:error.code];        
    }];
}

- (void)loadMoreData {
    {
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager.requestSerializer setValue:Api_key forHTTPHeaderField:@"api-key"];
        
        NSDictionary *parameters = @{@"page" : @(page)};

        [manager GET:base_url parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            //获取设备信息数组
            NSDictionary *data = [responseObject objectForKey:@"data"];
            NSArray *devices = [data objectForKey:@"devices"];
            NSMutableArray *arrayTemp = [NSMutableArray array];
            
            //如果没有页面没有值
            if (devices.count == 0) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
                return ;
            }
            
            //隐藏管理账号密码的设备
            for (NSDictionary *dict in devices) {
                if (![dict[@"title"]  isEqual: @"admin"]) {
                    [arrayTemp addObject:dict];
                }
            }
            
            //添加更新的数据
            [_datas addObjectsFromArray:[DeviceList mj_objectArrayWithKeyValuesArray:arrayTemp]];
            
            //刷新表格
            [self.tableView reloadData];
            [self.tableView.mj_footer endRefreshing];
            [MBProgressHUD showSuccess:@"加载成功"];
            page++;
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            //根据错误码显示错误提示语
            [MBProgressHUD showErrorForErrorCode:error.code];

            
        }];
    }
}

- (void)deleteDataWithDevice:(NSString *)deviceID {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:Api_key forHTTPHeaderField:@"api-key"];
    NSString *url = [base_url stringByAppendingPathComponent:deviceID];
    [manager DELETE:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MBProgressHUD showSuccess:@"删除成功"];
        [self loadNewData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        //根据错误码显示错误提示语
        [MBProgressHUD showErrorForErrorCode:error.code];
    }];
}

#pragma mark - tableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchController.active ? self.results.count : self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //创建了一个UITableViewCell的实例
    JHMainCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseId];
    
    //判定是否在搜索情况下 并取出相应的数组模型将cell赋值
    if (self.searchController.active) {
        DeviceList *deviceList = self.results[indexPath.row];
        cell.deviceList = deviceList;
    } else {
        DeviceList *deviceList = self.datas[indexPath.row];
        cell.deviceList = deviceList;
    }
    
    [self registerForPreviewingWithDelegate:self sourceView:cell];
    
    //返回一个UITableViewCellL类型
    return cell;
}

#pragma mark - UIViewControllerPreviewingDelegate
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    // 获取tableview点击的位置
    NSIndexPath *indexPath = [_tableView indexPathForCell:(UITableViewCell* )[previewingContext sourceView]];
    DeviceList *list = _datas[indexPath.row];
    
    DetailInfoController *detailInfoVC = [[DetailInfoController alloc] init];
    detailInfoVC.deviceName = list.title;
    detailInfoVC.deviceID = list.idField;
    return detailInfoVC;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    NSIndexPath *indexPath = [_tableView indexPathForCell:(UITableViewCell* )[previewingContext sourceView]];
    DeviceList *list = _datas[indexPath.row];
    DetailInfoController *detailInfoVC = [[DetailInfoController alloc] init];
    detailInfoVC.deviceName = list.title;
    detailInfoVC.deviceID = list.idField;
    [self.navigationController pushViewController:detailInfoVC animated:YES];
}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *inputStr = searchController.searchBar.text;
    if (self.results.count > 0) {
        [self.results removeAllObjects];
    }
    for (DeviceList *deviceList in self.datas) {
        if ([deviceList.title.lowercaseString rangeOfString:inputStr.lowercaseString].location != NSNotFound || //搜索对应设备
            [deviceList.idField.lowercaseString rangeOfString:inputStr.lowercaseString].location != NSNotFound || //搜索对应id
            [deviceList.auth_info.lowercaseString rangeOfString:inputStr.lowercaseString].location != NSNotFound //搜索对应设备编号
            ) {
                [self.results addObject:deviceList];
        }
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceList *list;
    if (self.searchController.active) {
        list = _results[indexPath.row];
    } else {
        list = _datas[indexPath.row];
    }
    DetailInfoController *detailInfoVC = [[DetailInfoController alloc] init];
    detailInfoVC.deviceName = list.title;
    detailInfoVC.deviceID = list.idField;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:detailInfoVC animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //左滑出现删除
    UITableViewRowAction *deleteAction = [UITableViewRowAction
                                          rowActionWithStyle:UITableViewRowActionStyleDestructive
                                          title:@"删除"
                                          handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                                              //创建警报控制器
                                              UIAlertController *alertVC = [UIAlertController
                                                                            alertControllerWithTitle:@"核对信息"
                                                                            message:@"请输入管理员密码"
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                                                    //创建TextField
                                              [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                                                                                  textField.placeholder = @"请输入管理员密码";
                                                                                  textField.secureTextEntry = YES;
                                                                              }];
                                              //创建确定和取消按钮
                                              [alertVC
                                               addAction:[UIAlertAction
                                                          actionWithTitle:@"确定"
                                                          style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              UITextField *alertTF = alertVC.textFields[0];
                                                              if ([alertTF.text
                                                                   isEqualToString:[[NSUserDefaults standardUserDefaults]
                                                                                    objectForKey:@"password"]]) {
                                                                       if (self.searchController.active) {
                                                                           self.isDelete = YES;
                                                                           DeviceList *list = _results[indexPath.row];
                                                                           [self deleteDataWithDevice:list.idField];
                                                                       } else {
                                                                           self.isDelete = YES;
                                                                           DeviceList *list = _datas[indexPath.row];
                                                                           [self deleteDataWithDevice:list.idField];
                                                                       }
                                                                       
                                                                   } else {
                                                                       [self presentViewController:alertVC animated:YES completion:nil];
                                                                       [MBProgressHUD showError:@"输入密码有误请重新输入"];
                                                                       
                                                                   }
                                                              
                                                          }]];
                                              [alertVC
                                               addAction:[UIAlertAction
                                                          actionWithTitle:@"取消"
                                                          style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                          }]];
                                              [self presentViewController:alertVC animated:YES completion:nil];
                                          }];
    
    //左滑出现编辑
    UITableViewRowAction *editAction = [UITableViewRowAction
                                        rowActionWithStyle:UITableViewRowActionStyleNormal
                                        title:@"编辑"
                                        handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                                            DeviceList *list;
                                            if (self.searchController.active) {
                                                list = _results[indexPath.row];
                                            } else {
                                                list = _datas[indexPath.row];
                                            }
                                            AddDeviceController *addDeviceVC = [[AddDeviceController alloc] init];
                                            addDeviceVC.deviceList = list;
                                            [self.navigationController pushViewController:addDeviceVC animated:YES];
                                        }];
    editAction.backgroundColor = [UIColor grayColor];
    return @[deleteAction,editAction];
    
}

#pragma mark - UISearchBarDelegate

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
