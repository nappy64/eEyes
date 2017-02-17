//
//  ExportSensorItem.m
//  eEyes
//
//  Created by Denny on 2017/2/17.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "ExportSensorItem.h"

@implementation ExportSensorItem

static ExportSensorItem *_singletonExportSensorItem = nil;

+ (instancetype) shareInstance{
    if(_singletonExportSensorItem == nil){
        _singletonExportSensorItem = [ExportSensorItem new];
    }
    return _singletonExportSensorItem;
}

- (instancetype) init{
    
    _no = [NSMutableArray new];
    _sensorID = [NSMutableArray new];
    _temperatureValue = [NSMutableArray new];
    _humidityValue = [NSMutableArray new];
    _time = [NSMutableArray new];
    return self;
}

- (void) reset{
    [_no removeAllObjects];
    [_sensorID removeAllObjects];
    [_temperatureValue removeAllObjects];
    [_humidityValue removeAllObjects];
    [_time removeAllObjects];
}
@end
