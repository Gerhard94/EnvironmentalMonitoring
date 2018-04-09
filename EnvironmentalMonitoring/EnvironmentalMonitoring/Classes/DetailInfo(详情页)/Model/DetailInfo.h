//
//  DetailInfo.h
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/4/9.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DetailInfo : NSObject
//更新时间
@property (nonatomic, copy) NSString *update_at;

@property (nonatomic, copy) NSString *idField;

@property (nonatomic, copy) NSString *current_value;


@end
