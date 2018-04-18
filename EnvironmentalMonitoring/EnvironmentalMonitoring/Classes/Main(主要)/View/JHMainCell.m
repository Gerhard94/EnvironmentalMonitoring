//
//  JHMainCell.m
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/1/10.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import "JHMainCell.h"
#import "DeviceList.h"
@interface JHMainCell()

@property (weak, nonatomic) IBOutlet UILabel *title;

@property (weak, nonatomic) IBOutlet UILabel *idField;

@property (weak, nonatomic) IBOutlet UILabel *authInfo;

@property (weak, nonatomic) IBOutlet UILabel *createTime;

@property (weak, nonatomic) IBOutlet UIImageView *online;

@end

static NSMutableArray *IDArray;
static NSMutableArray *titleArray;


@implementation JHMainCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setDeviceList:(DeviceList *)deviceList {
    _deviceList = deviceList;
    self.title.text = deviceList.title;
    self.idField.text = deviceList.idField;
    self.authInfo.text = deviceList.auth_info;
    self.createTime.text = deviceList.create_time;
    UIImage *online = [UIImage imageNamed:@"online"];
    UIImage *offline = [UIImage imageNamed:@"offline"];
    self.online.image = [deviceList.online isEqualToString:@"0"] ? offline : online;
    if (IDArray == nil) {
        IDArray = [NSMutableArray arrayWithCapacity:0];
    }
    [IDArray addObject:deviceList.idField];
    [[NSUserDefaults standardUserDefaults] setObject:IDArray forKey:@"IDArray"];
    
    if (titleArray == nil) {
        titleArray = [NSMutableArray arrayWithCapacity:0];
    }
    [titleArray addObject:deviceList.title];
    [[NSUserDefaults standardUserDefaults] setObject:titleArray forKey:@"titleArray"];

}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
