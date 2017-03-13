//
//  Config.m
//  eEyes
//
//  Created by Nap Chen on 2017/1/10.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "ConfigManager.h"

@implementation ConfigManager
{
    NSMutableDictionary *allConfigDictionary;
    NSMutableDictionary *allConfigText;
    NSMutableArray *allConfigKeys;
}

static ConfigManager *_singletonConfigManager = nil;

+ (instancetype) sharedInstance {
    
    if(_singletonConfigManager == nil){
        _singletonConfigManager = [ConfigManager new];
    }
    return _singletonConfigManager;
}

- (void) initialConfigPlist {
    
    // load file Config.plist
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"Config.plist"];
    
    // create if no Config.plist existed
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath])
    {
        plistPath = [[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"];
    }
    
    // transfer plist to dictionary
    allConfigDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    [self setAllConfigTextKeys];
}

- (void) resetAllConfig{
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Setting" ofType:@"plist"];
    allConfigDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    [self getAllConfig];
}

- (void) getAllConfig {
    
    _dbMainAddress = [allConfigDictionary objectForKey:@"dbMainAddress"];
    _dbInfoAddress = [allConfigDictionary objectForKey:@"dbInfoAddress"];
    _dbSensorValueAddress = [allConfigDictionary objectForKey:@"dbSensorValueAddress"];
    _dbRegisterAddress = [allConfigDictionary objectForKey:@"dbRegisterAddress"];
    _dbAlarmAddress = [allConfigDictionary objectForKey:@"dbAlarmAddress"];
    _dbUserName = [allConfigDictionary objectForKey:@"dbUserName"];
    _dbPassword = [allConfigDictionary objectForKey:@"dbPassword"];
    _dbName = [allConfigDictionary objectForKey:@"dbName"];
    _dbTable = [allConfigDictionary objectForKey:@"dbTable"];
    _dbField = [allConfigDictionary objectForKey:@"dbField"];
    _startDate = [allConfigDictionary objectForKey:@"startDate"];
    _endDate = [allConfigDictionary objectForKey:@"endDate"];
    _appUserName = [allConfigDictionary objectForKey:@"appUserName"];
    _appPassword = [allConfigDictionary objectForKey:@"appPassword"];
    _realChartSensorID = [allConfigDictionary objectForKey:@"realChartSensorID"];
    _isDisplayRealTimeChart = [[allConfigDictionary objectForKey:@"isDisplayRealTimeChart"] boolValue];
    _isDisplayValueInHistoryChart = [[allConfigDictionary objectForKey:@"isDisplayValueInHistoryChart"] boolValue];
}

- (void) setAllConfig {
    
    [allConfigDictionary setObject:_dbMainAddress forKey:@"dbMainAddress"];
    [allConfigDictionary setObject:_dbInfoAddress forKey:@"dbInfoAddress"];
    [allConfigDictionary setObject:_dbSensorValueAddress forKey:@"dbSensorValueAddress"];
    [allConfigDictionary setObject:_dbRegisterAddress forKey:@"dbRegisterAddress"];
    [allConfigDictionary setObject:_dbAlarmAddress forKey:@"dbAlarmAddress"];
    [allConfigDictionary setObject:_dbUserName forKey:@"dbUserName"];
    [allConfigDictionary setObject:_dbPassword forKey:@"dbPassword"];
    [allConfigDictionary setObject:_dbName forKey:@"dbName"];
    [allConfigDictionary setObject:_dbTable forKey:@"dbTable"];
    [allConfigDictionary setObject:_dbField forKey:@"dbField"];
    [allConfigDictionary setObject:_startDate forKey:@"startDate"];
    [allConfigDictionary setObject:_endDate forKey:@"endDate"];
    [allConfigDictionary setObject:_appUserName forKey:@"appUserName"];
    [allConfigDictionary setObject:_appPassword forKey:@"appPassword"];
    [allConfigDictionary setObject:_realChartSensorID forKey:@"realChartSensorID"];
    [allConfigDictionary setObject:[NSNumber numberWithBool:_isDisplayRealTimeChart] forKey:@"isDisplayRealTimeChart"];
    [allConfigDictionary setObject:[NSNumber numberWithBool:_isDisplayValueInHistoryChart] forKey:@"isDisplayValueInHistoryChart"];
    
    [self savePlist];
}

- (void) savePlist {
    
    // save file Setting.plist
    NSString *SaveRootPath = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    NSString *SavePath = [SaveRootPath stringByAppendingPathComponent:@"Config.plist"];
    
    [allConfigDictionary writeToFile:SavePath atomically:YES];
}

- (void) setAllConfigTextKeys {
    
    allConfigText = [NSMutableDictionary new];
    allConfigKeys = [NSMutableArray new];
    
    [allConfigText setObject:@"DB Main Address" forKey:@"dbMainAddress"];
    [allConfigText setObject:@"DB Info Address" forKey:@"dbInfoAddress"];
    [allConfigText setObject:@"DB Sensor Value Address" forKey:@"dbSensorValueAddress"];
    [allConfigText setObject:@"DB Register Address" forKey:@"dbRegisterAddress"];
    [allConfigText setObject:@"DB Alarm Address" forKey:@"dbAlarmAddress"];
    [allConfigText setObject:@"DB User Name" forKey:@"dbUserName"];
    [allConfigText setObject:@"DB Password" forKey:@"dbPassword"];
    [allConfigText setObject:@"DB Name" forKey:@"dbName"];
    [allConfigText setObject:@"DB Table" forKey:@"dbTable"];
    [allConfigText setObject:@"DB Field" forKey:@"dbField"];
    [allConfigText setObject:@"Start Date" forKey:@"startDate"];
    [allConfigText setObject:@"End Date" forKey:@"endDate"];
    [allConfigText setObject:@"User Name" forKey:@"appUserName"];
    [allConfigText setObject:@"Password" forKey:@"appPassword"];
    [allConfigText setObject:@"Realtime Chart Sensor ID" forKey:@"realChartSensorID"];
//    [allConfigText setObject:@"Enable Realtime Chart" forKey:@"isDisplayRealTimeChart"];
//    [allConfigText setObject:@"Disable Historical Chart" forKey:@"isDisplayValueInHistoryChart"];
    
    [allConfigKeys addObject:@"dbMainAddress"];
    [allConfigKeys addObject:@"dbInfoAddress"];
    [allConfigKeys addObject:@"dbSensorValueAddress"];
    [allConfigKeys addObject:@"dbRegisterAddress"];
    [allConfigKeys addObject:@"dbAlarmAddress"];
    [allConfigKeys addObject:@"dbUserName"];
    [allConfigKeys addObject:@"dbPassword"];
    [allConfigKeys addObject:@"dbName"];
//    [allConfigKeys addObject:@"dbTable"];
//    [allConfigKeys addObject:@"dbField"];
//    [allConfigKeys addObject:@"startDate"];
//    [allConfigKeys addObject:@"endDate"];
    [allConfigKeys addObject:@"appUserName"];
    [allConfigKeys addObject:@"appPassword"];
//    [allConfigKeys addObject:@"realChartSensorID"];
//    [allConfigKeys addObject:@"isDisplayRealTimeChart"];
//    [allConfigKeys addObject:@"isDisplayValueInHistoryChart"];
}

- (NSDictionary*) getConfigDictionary {
    
    return allConfigDictionary;
}

- (NSDictionary*) getConfigText {
    
    return allConfigText;
}

- (NSArray*) getConfigKeys {
    
    return allConfigKeys;
}

- (void) setValueByKey:(NSString*)key value:(NSString*)value {
    
    [allConfigDictionary setObject:value forKey:key];
}
//- (void) setDisplayRealTimeChartEnable:(bool)displayRealTimeChartEnable {
//    
//    _isDisplayRealTimeChart = displayRealTimeChartEnable;
//    [allConfigDictionary setObject:[NSNumber numberWithBool:_isDisplayRealTimeChart] forKey:@"displayRealTimeChart"];
//    [self setAllConfig];
//}
//
//- (bool) getDisplayRealTimeChartEnable {
//    
//    return _isDisplayRealTimeChart;
//}

@end
