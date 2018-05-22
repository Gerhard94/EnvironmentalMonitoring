//
//  HistoryOfVoltageCell.h
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/5/19.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Datapoints.h"

@interface HistoryOfVoltageCell : UITableViewCell

@property (nonatomic, strong) Datapoints *points;

@end
