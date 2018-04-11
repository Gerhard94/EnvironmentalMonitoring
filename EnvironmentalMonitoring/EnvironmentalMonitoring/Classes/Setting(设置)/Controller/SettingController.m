//
//  SettingController.m
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/4/10.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import "SettingController.h"
#import "JHLoginRegisterController.h"
@interface SettingController ()

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            JHLoginRegisterController *loginVC = [[JHLoginRegisterController alloc] init];
            [[UIApplication sharedApplication].keyWindow setRootViewController:loginVC];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
