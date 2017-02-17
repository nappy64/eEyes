//
//  ExportSensorItem.h
//  eEyes
//
//  Created by Denny on 2017/2/17.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum:NSInteger{
    
    noData = 0,
    onlyTemp,
    onlyHumid,
    bothTempAndHumid
    
} sensorTypes;




@interface ExportSensorItem : NSObject
@property(nonatomic,strong) NSMutableArray *no;
@property(nonatomic,strong) NSMutableArray *sensorID;
@property(nonatomic,strong) NSMutableArray *temperatureValue;
@property(nonatomic,strong) NSMutableArray *humidityValue;
@property(nonatomic,strong) NSMutableArray *time;
@property(nonatomic,assign) ExportSensorItem *sensorTypes;
+ (instancetype) shareInstance;

- (instancetype) init;

- (void) reset;

@end
