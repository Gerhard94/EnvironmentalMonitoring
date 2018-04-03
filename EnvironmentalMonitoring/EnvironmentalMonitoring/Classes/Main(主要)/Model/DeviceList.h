//
//  DeviceList.h
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/4/3.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceList : NSObject

//是否公开
@property (nonatomic, assign) BOOL privateField;

//创建时间
@property (nonatomic, copy) NSString *create_time;

//是否在线
@property (nonatomic, copy) NSString *online;

//设备标题
@property (nonatomic, copy) NSString *title;

//设备ID
@property (nonatomic, strong) NSString * idField;

//设备编号
@property (nonatomic, strong) NSString * auth_info;


@end
