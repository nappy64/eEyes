//
//  Sensor.h
//  eEyes
//
//  Created by Nap Chen on 2017/1/11.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sensor : NSObject

@property (nonatomic, strong) NSNumber *sensorID;
@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *value;
@property (nonatomic, strong) NSString *date;

@end
