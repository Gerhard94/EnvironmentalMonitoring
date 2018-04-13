//
//  SettingController.m
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/4/10.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import "SettingController.h"
#import "JHLoginRegisterController.h"
#import <TYAlertController/UIView+TYAlertView.h>
#import "AutoRefresh.h"
#import <PGDatePicker/PGDatePickManager.h>
@interface SettingController () <PGDatePickerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *managerID;
@property (weak, nonatomic) IBOutlet UILabel *autoRefreshState;

@end

@implementation SettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"设置";
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:nil];
    
    self.managerID.text = [NSString stringWithFormat:@"管理员ID: %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"account"]];
    NSUInteger refreshSecond = [[[NSUserDefaults standardUserDefaults] valueForKey:@"autoRefresh"] integerValue];
    self.autoRefreshState.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"autoRefresh"] == 0 ? @"关闭" : [NSString stringWithFormat:@"%lu秒",(unsigned long)refreshSecond];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)changedPassword:(NSString *)value{
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    parameters[@"datastreams"] = @[@{@"id" : @"password",@"datapoints" : @[@{@"value" : value}]}];
    
    //创建manager
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    //创建request
    NSString *urlStr = [[base_url stringByAppendingPathComponent:@"28341037"] stringByAppendingPathComponent:@"datapoints"];
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST"
                                                                                 URLString:urlStr
                                                                                parameters:parameters
                                                                                     error:nil];
    
    //设置网络请求超时时间和http头部
    request.timeoutInterval = 8.f;
    [request setValue:Api_key forHTTPHeaderField:@"api-key"];
    
    //创建会话并发送网络请求
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            if ([responseObject[@"error"] isEqualToString:@"succ"]) {
                // 请求成功数据处理
                [MBProgressHUD showSuccess:@"修改密码成功"];
                [[NSUserDefaults standardUserDefaults] setObject:value forKey:@"password"];
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

- (UIAlertController *)setAlertControllerWithTitle:(NSString *)title message:(NSString *)message textFieldPlaceholder:(NSString *)textFieldPlaceholder {
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title
                                                                     message:message
                                                              preferredStyle:UIAlertControllerStyleAlert];
    
    //创建TextField
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = textFieldPlaceholder;
        textField.secureTextEntry = YES;
    }];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    return alertVC;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 2) {
            AutoRefresh *autoRefreshView = [AutoRefresh createViewFromNib];
            TYAlertController *alertC = [TYAlertController alertControllerWithAlertView:autoRefreshView preferredStyle:TYAlertControllerStyleActionSheet];
            alertC.backgoundTapDismissEnable = YES;
            
            [alertC setViewWillHideHandler:^(UIView *alertView) {
                AutoRefresh * alertV = (AutoRefresh *)alertView;
                if (alertV.refreshSwitch.on == YES && ![alertV.valueLabel.text isEqualToString:@"0秒"]) {
                    [[NSUserDefaults standardUserDefaults] setObject:alertV.valueLabel.text forKey:@"autoRefresh"];
                    self.autoRefreshState.text = [alertV.valueLabel.text isEqualToString:@"0"] ? @"关闭" : alertV.valueLabel.text;
                } else {
                    [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"autoRefresh"];
                    self.autoRefreshState.text = @"关闭";
                }
            }];
            [self presentViewController:alertC animated:YES completion:nil];
        } else if (indexPath.row == 3) {
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
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            
            UIAlertController *alertVC = [self setAlertControllerWithTitle:@"核对信息" message:@"请输入管理员密码" textFieldPlaceholder:@"请输入密码"];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                UITextField *alertTF = alertVC.textFields[0];
                if ([alertTF.text isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"password"]]) {
                    
                    UIAlertController *alertVC = [self setAlertControllerWithTitle:@"修改密码" message:@"请输入新密码" textFieldPlaceholder:@"请输入密码"];
                    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                        UITextField *alertTF = alertVC.textFields[0];
                        [self changedPassword:alertTF.text];
                        
                    }];
                    [alertVC addAction:action];
                    [self presentViewController:alertVC animated:YES completion:nil];
                    
                    
                } else {
                    [self presentViewController:alertVC animated:YES completion:nil];
                    [MBProgressHUD showError:@"输入密码有误请重新输入"];
                }
            }];
            
            [alertVC addAction:action];
            [self presentViewController:alertVC animated:YES completion:nil];

        } else if (indexPath.row == 1) {
            TYAlertView *alertView = [TYAlertView alertViewWithTitle:@"警告" message:@"确定要退出登录吗?"];
            [alertView addAction:[TYAlertAction actionWithTitle:@"确定" style:TYAlertActionStyleDestructive handler:^(TYAlertAction *action) {
                JHLoginRegisterController *loginVC = [[JHLoginRegisterController alloc] init];
                [[UIApplication sharedApplication].keyWindow setRootViewController:loginVC];
            }]];
            [alertView addAction:[TYAlertAction actionWithTitle:@"取消" style:TYAlertActionStyleCancel handler:nil]];
            TYAlertController *alertC = [TYAlertController alertControllerWithAlertView:alertView preferredStyle:TYAlertControllerStyleAlert transitionAnimation:TYAlertTransitionAnimationDropDown];
            [self presentViewController:alertC animated:YES completion:nil];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma PGDatePickerDelegate
- (void)datePicker:(PGDatePicker *)datePicker didSelectDate:(NSDateComponents *)dateComponents {
    NSCalendar * calendar = [NSCalendar autoupdatingCurrentCalendar];
    
    NSDate * date = [calendar dateFromComponents:dateComponents];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSString * str = [formatter stringFromDate:date];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@"T"];
    NSLog(@"%@",str);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSUInteger refreshSecond = [[[NSUserDefaults standardUserDefaults] valueForKey:@"autoRefresh"] integerValue];
    self.autoRefreshState.text = refreshSecond == 0 ? @"关闭" : [NSString stringWithFormat:@"%lu秒",(unsigned long)refreshSecond];
}


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
