//
//  HistoryDataController.m
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/4/17.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import "HistoryDataController.h"
#import <PGDatePicker/PGDatePickManager.h>

@interface HistoryDataController () <PGDatePickerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *startTime;
@property (weak, nonatomic) IBOutlet UIButton *endTime;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@end

@implementation HistoryDataController

- (instancetype)init {
    if (self = [super init]) {
        self.title = @"查看历史数据";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupBorder];
    // Do any additional setup after loading the view.
}

- (void)setupBorder {
    self.startTime.layer.borderWidth = self.endTime.layer.borderWidth =  1;
    self.startTime.layer.borderColor = self.endTime.layer.borderColor = [UIColor colorWithHexString:@"e6e6e6"].CGColor;
    
}

- (IBAction)datePickerClick:(UIButton *)sender {
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
