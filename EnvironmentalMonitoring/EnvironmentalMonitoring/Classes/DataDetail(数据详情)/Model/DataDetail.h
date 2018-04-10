//
//  DataDetail.h
//  EnvironmentalMonitoring
//
//  Created by Gerhard Z on 2018/4/10.
//  Copyright © 2018年 lakers JH. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Datapoints;

@interface DataDetail : NSObject

@property (nonatomic, copy) NSString *idField;
@property (nonatomic, copy) NSArray *datapoints;


@end
