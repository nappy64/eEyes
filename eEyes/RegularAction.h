//
//  RegularAction.h
//  eEyes
//
//  Created by Nap Chen on 2017/1/10.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPComm.h"
#import "AllSensors.h"
#import "ConfigManager.h"
#import "XMLParserDelegate.h"
#import "Sensor.h"

@interface RegularAction : NSObject
@property (nonatomic,strong) NSString *lastUpdateTime;

+ (instancetype) sharedInstance;

- (NSString*)getTheTimeOfTheLastAverage:(DoneHandler)doneHandler;

- (void)getDataToAverage:(NSString*)startDate withEndDate:(NSString*)endDate;

- (void)uploadAverageValue:(NSString*)identifier;

-(void) dataToJSON;


@end
