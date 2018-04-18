//
//  HistoryDataCell.h
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/4/17.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryDataCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *atDate;
@property (weak, nonatomic) IBOutlet UILabel *room_temp;
@property (weak, nonatomic) IBOutlet UILabel *room_humi;
@property (weak, nonatomic) IBOutlet UILabel *air_temp;
@property (weak, nonatomic) IBOutlet UILabel *fun_temp;
@property (weak, nonatomic) IBOutlet UILabel *water_leakage;
@property (weak, nonatomic) IBOutlet UILabel *smoke_detector;
@property (weak, nonatomic) IBOutlet UILabel *cabinet_door_isClose;
@property (weak, nonatomic) IBOutlet UILabel *room_door_isClose;

@end
