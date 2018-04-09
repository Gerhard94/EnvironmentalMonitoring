//
//  JHView.m
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/4/9.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import "JHView.h"

@implementation JHView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor colorWithHexString:@"e6e6e6"].CGColor;
}

@end
