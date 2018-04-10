//
//  DataDetailCell.h
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/4/10.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AAChartView.h"

@interface DataDetailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet AAChartView *aaChartView;

@end
