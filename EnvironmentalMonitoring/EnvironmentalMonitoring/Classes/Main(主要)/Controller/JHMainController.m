//
//  JHMainController.m
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/4/2.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import "JHMainController.h"
#import <AFNetworking.h>

@interface JHMainController () <UITableViewDelegate,UITableViewDataSource,UISearchResultsUpdating>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, weak) UISearchController *searchController;

@property (nonatomic, strong) NSMutableArray *datas;

@property (nonatomic, strong) NSMutableArray *results;


@end

@implementation JHMainController

#pragma mark - 懒加载
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
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
    UISearchController *search = [[UISearchController alloc] initWithSearchResultsController:nil];
    search.searchResultsUpdater = self;
    search.dimsBackgroundDuringPresentation = NO;
    search.searchBar.placeholder = @"搜索";
    search.hidesNavigationBarDuringPresentation = YES;
    self.searchController = search;
    self.tableView.tableHeaderView = search.searchBar;
    
    [self getDeviceList];
    // Do any additional setup after loading the view from its nib.
}

- (void)getDeviceList {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:Api_key forHTTPHeaderField:@"api-key"];
    [manager GET:base_url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"配电房列表";
        
    }
    return self;
}

#pragma mark - tableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchController.active ? self.results.count : self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"id"];
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
    for (NSString *str in self.datas) {
        if ([str.lowercaseString rangeOfString:inputStr.lowercaseString].location != NSNotFound) {
            [self.results addObject:str];
        }
        [self.tableView reloadData];
    }
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
