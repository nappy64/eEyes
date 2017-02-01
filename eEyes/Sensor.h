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

@property float latitude;
@property float longitude;
@property (nonatomic, strong) NSString *type;
@property float rangeHi;
@property float rangeLo;
@property (nonatomic, strong) NSString *unit;
@property (nonatomic, strong) NSString *desc;

@property (nonatomic, strong) NSString *dbRealValueTable;
@property (nonatomic, strong) NSString *dbAverageValueTable;

@property bool isSelected;

@end
