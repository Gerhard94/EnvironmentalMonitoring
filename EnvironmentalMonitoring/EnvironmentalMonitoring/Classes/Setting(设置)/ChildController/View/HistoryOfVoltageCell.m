//
//  HistoryOfVoltageCell.m
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/5/19.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import "HistoryOfVoltageCell.h"

@interface HistoryOfVoltageCell()

@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *v1;
@property (weak, nonatomic) IBOutlet UILabel *v2;
@property (weak, nonatomic) IBOutlet UILabel *v3;
@property (weak, nonatomic) IBOutlet UILabel *v4;
@property (weak, nonatomic) IBOutlet UILabel *v5;
@property (weak, nonatomic) IBOutlet UILabel *v6;
@property (weak, nonatomic) IBOutlet UILabel *v7;
@property (weak, nonatomic) IBOutlet UILabel *v8;
@property (weak, nonatomic) IBOutlet UILabel *v9;
@property (weak, nonatomic) IBOutlet UILabel *v10;

@property (nonatomic, strong) NSMutableArray *arrayData;

@end

@implementation HistoryOfVoltageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _arrayData = [NSMutableArray arrayWithCapacity:10];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPoints:(Datapoints *)points {
    _points = points;
    _time.text = points.at;
    if (points.value.length != 134) {
        return;
    }
    NSString *subStr = [points.value substringFromIndex:14];
    for (int i = 0; i < 10; ++i) {
        NSString *Str = [subStr substringWithRange:NSMakeRange(i * 12, 12)];
        NSString *valueStr = [NSString stringWithFormat:@"A%d:%@",i+1,Str];
        [_arrayData addObject:valueStr];
    }
    _v1.text = _arrayData[0];
    _v2.text = _arrayData[1];
    _v3.text = _arrayData[2];
    _v4.text = _arrayData[3];
    _v5.text = _arrayData[4];
    _v6.text = _arrayData[5];
    _v7.text = _arrayData[6];
    _v8.text = _arrayData[7];
    _v9.text = _arrayData[8];
    _v10.text = _arrayData[9];
    
}

@end
