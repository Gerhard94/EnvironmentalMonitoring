//
//  AutoRefresh.m
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/4/11.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import "AutoRefresh.h"

@interface AutoRefresh ()

@property (weak, nonatomic) IBOutlet UIView *setRefreshView;
@property (weak, nonatomic) IBOutlet UISlider *refreshSlider;

@end

@implementation AutoRefresh

- (void)awakeFromNib {
    [super awakeFromNib];
    
    NSUInteger refreshSecond = [[[NSUserDefaults standardUserDefaults] valueForKey:@"autoRefresh"] integerValue];
    
    self.refreshSwitch.on = refreshSecond != 0;
    [self.refreshSwitch addTarget:self action:@selector(autoRefreshSwitch) forControlEvents:UIControlEventTouchUpInside];
    [self autoRefreshSwitch];
    
    [self.refreshSlider addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
    self.refreshSlider.value = (float)refreshSecond;
    [self.refreshSlider addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
    
    self.valueLabel.text = [NSString stringWithFormat:@"%lu秒",refreshSecond];
    
}

- (void)autoRefreshSwitch {
    self.setRefreshView.hidden = !self.refreshSwitch.on;
}

- (void)valueChanged {
    self.valueLabel.text = [@(@(self.refreshSlider.value).integerValue).stringValue stringByAppendingString:@"秒"];
}

@end
