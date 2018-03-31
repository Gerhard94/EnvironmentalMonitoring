//
//  JHLoginRegisterField.m
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/1/10.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import "JHLoginRegisterField.h"

@implementation JHLoginRegisterField

- (void)awakeFromNib {
    [super awakeFromNib];
    self.tintColor = [UIColor whiteColor];
    [self setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    self.textColor = [UIColor blackColor];
}

@end
