//
//  Config.h
//  eEyes
//
//  Created by Nap Chen on 2017/1/10.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfigManager : NSObject

@property NSString *dbMainAddress;          // DB Sensor Address
@property NSString *dbInfoAddress;          // DB Info. Address
@property NSString *dbSensorValueAddress;   // DB Sensor Value Address
@property NSString *dbRegisterAddress;      // DB Register Address
@property NSString *dbUserName;             // DB Username
@property NSString *dbPassword;             // DB Password
@property NSString *dbName;                 // DB Name
@property NSString *dbTable;                // DB Table
@property NSString *dbField;                // DB Field
@property NSString *startDate;              // Start Date
@property NSString *endDate;                // End Date
@property NSString *appUserName;            // User Name
@property NSString *appPassword;            // Password
@property bool isDisplayRealTimeChart;      // Display Ral Time Chart


+ (instancetype) sharedInstance;

- (void) initialConfigPlist;
- (void) resetAllConfig;
- (void) getAllConfig;
- (void) setAllConfig;
- (NSDictionary*) getConfigDictionary;
- (void) setDisplayRealTimeChartEnable:(bool)displayRealTimeChartEnable;
- (bool) getDisplayRealTimeChartEnable;

@end
