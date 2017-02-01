//
//  AllSensors.h
//  eEyes
//
//  Created by Nap Chen on 2017/1/27.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sensor.h"

@interface AllSensors : NSObject

+ (instancetype) sharedInstance;

- (void) transferJSONToSensorsInfo:(NSDictionary*) jsonData;
- (NSArray*) getAllSensorsInfo;
- (NSUInteger) getSensorsCount;
    
@end
