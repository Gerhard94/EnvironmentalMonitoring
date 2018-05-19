//
//  VoltageCell.h
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/5/16.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VoltageCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *voltageValue;

@end
