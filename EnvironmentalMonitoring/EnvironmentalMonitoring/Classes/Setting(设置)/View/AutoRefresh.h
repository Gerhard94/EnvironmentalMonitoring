//
//  AutoRefresh.h
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/4/11.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoRefresh : UIView

@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UISwitch *refreshSwitch;
@end
