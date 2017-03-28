//
//  AllSensors.m
//  eEyes
//
//  Created by Nap Chen on 2017/1/27.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "AllSensors.h"
#import "Sensor.h"

@implementation AllSensors
{
    NSMutableArray *allSensorsInfo;
}

static AllSensors *_singletonAllSensors = nil;

+ (instancetype) sharedInstance {
    
    if(_singletonAllSensors == nil){
        _singletonAllSensors = [AllSensors new];
    }
    return _singletonAllSensors;
}

- (void) transferJSONToSensorsInfo:(NSDictionary*) jsonData {
    
    allSensorsInfo = [NSMutableArray new];
    NSMutableArray *allSensors = jsonData[@"sensors"];
    
    for (int i = 0; i < (int)allSensors.count; i++) {
        
        NSMutableDictionary *sensorInfo = jsonData[@"sensors"][i];
        Sensor *currentSensor = [Sensor new];
        
        // createa FriendsItem for the following need
        currentSensor.sensorID = sensorInfo[@"sensorID"];
        currentSensor.name = sensorInfo[@"sensorName"];
        
        currentSensor.hiAlarm = [sensorInfo[@"hiAlarm"] floatValue];
        currentSensor.loAlarm = [sensorInfo[@"loAlarm"] floatValue];
        
        currentSensor.latitude = [sensorInfo[@"latitude"] floatValue];
        currentSensor.longitude = [sensorInfo[@"longitude"] floatValue];
        currentSensor.type = sensorInfo[@"sensorType"];
        currentSensor.rangeHi = [sensorInfo[@"rangeHi"] floatValue];
        currentSensor.rangeLo = [sensorInfo[@"rangeLo"] floatValue];
        currentSensor.unit = sensorInfo[@"unit"];
        currentSensor.desc = sensorInfo[@"description"];
        currentSensor.dbRealValueTable = sensorInfo[@"dbRealValueTable"];
        currentSensor.dbAverageValueTable = sensorInfo[@"dbAverageValueTable"];
        currentSensor.isSelected = true;
        
        [allSensorsInfo addObject:currentSensor];
    }
}

- (NSArray*) getAllSensorsInfo {
    
    return allSensorsInfo;
}

- (NSMutableArray*) getAllSensorsInfoMutable {
    
    return allSensorsInfo;
}

- (void) setAllSensorsInfo:(NSMutableArray*) allSensors {
    
    allSensorsInfo = allSensors;
}

- (NSUInteger) getSensorsCount {
    
    return allSensorsInfo.count;
}

@end
