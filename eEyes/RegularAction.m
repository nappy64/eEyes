//
//  RegularAction.m
//  eEyes
//
//  Created by Nap Chen on 2017/1/10.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "RegularAction.h"


#define DATEKEY @"date"
#define VALUEKEY @"value"
#define DBAVERAGE_VALUE_TABLE @"dbAverageValueTable"
#define DATACOUNTKEY @"dataCount"
#define DATAKEY @"data"
#define AVERAGEID10001 @"AverageID10001"
#define AVERAGEID10002 @"AverageID10002"
#define INTERNET_TIMEOUT 1

@implementation RegularAction
{
    HTTPComm *httpComm;
    ConfigManager *config;
    AllSensors *allSensors;
    Sensor *sensorToAverage;
    //Sensor *eachValue;
    NSArray *allSensorsInfo;
    NSMutableArray *objects;
    NSMutableArray *allAveragePerMinute;
    NSMutableArray *differentTypeValue;
    double valueTotal;
    int displayCount;           // http send count
    int compareDisplayCount;    // http receive count
    NSString *jsonString;
    NSString *status;
}

static RegularAction *_singletonRegularAction = nil;


+ (instancetype) sharedInstance{
    if(_singletonRegularAction == nil){
        _singletonRegularAction = [RegularAction new];
    }
    return _singletonRegularAction;
}

- (NSString*)getTheTimeOfTheLastAverage:(DoneHandler)doneHandler{
    httpComm = [HTTPComm sharedInstance];
    config = [ConfigManager sharedInstance];
    NSURL *url = [[NSURL alloc] initWithString:config.dbSensorValueAddress];
    
    [httpComm sendHTTPPost:url
                   timeout:INTERNET_TIMEOUT
                   dbTable:nil
                  sensorID:nil
                 startDate:nil
                   endDate:nil
                insertData:nil
              functionType:@"getNewestAverageTime"
                completion:^(NSData *data, NSURLResponse *response, NSError *error) {
                    if (error) {
                        NSLog(@"%@",error);
                    }else{
                        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        NSLog(@"here:%@",result);
                        _lastUpdateTime = result;
                        NSLog(@"%@",_lastUpdateTime);
                        doneHandler(data,response,error);
                    }
                }];
    while (_lastUpdateTime == nil) {
    }
    return _lastUpdateTime;
}


- (void)getDataToAverage:(NSString*)startDate withEndDate:(NSString*)endDate{
    sensorToAverage = [Sensor new];
    httpComm = [HTTPComm sharedInstance];
    config = [ConfigManager sharedInstance];
    allSensors = [AllSensors sharedInstance];
    allSensorsInfo = [allSensors getAllSensorsInfo];
    allAveragePerMinute = [NSMutableArray new];
    differentTypeValue = [NSMutableArray new];
    displayCount = 0;
    compareDisplayCount = 0;
    
    // Get the time and add an hour
    NSDateFormatter *updateTimeFormatter = [NSDateFormatter new];
    //[updateTime setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Taipei"]];
    [updateTimeFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *newestTime = [NSDate date];
    newestTime = [updateTimeFormatter dateFromString:_lastUpdateTime];
    newestTime = [newestTime dateByAddingTimeInterval:1800];
    NSString *timeString = [updateTimeFormatter stringFromDate:newestTime];
    
    NSLog(@"TIME FROM %@ TO %@",_lastUpdateTime,timeString);
    
    NSURL *url = [[NSURL alloc] initWithString:config.dbSensorValueAddress];
    //NSURL *url = [NSURL URLWithString:CONNECT_FOR_MOBILE];
    Sensor *sensor = [Sensor new];
    
    for(int i = 0;i < allSensorsInfo.count;i++){
        
        sensor = allSensorsInfo[i];
        
        displayCount += 1;
        
        [httpComm sendHTTPPost:url
                       timeout:INTERNET_TIMEOUT
                       dbTable:nil
                      sensorID:[sensor.sensorID stringValue]
                     startDate:_lastUpdateTime
                       endDate:timeString
                    insertData:nil
                  functionType:@"getRange"
                    completion:^(NSData *data, NSURLResponse *response, NSError *error) {
                        if (error) {
                            NSLog(@"!!! ERROR1 !!!");
                            NSLog(@"HTTP Get Range Data Failed : %@", error.localizedDescription);
                        }else {
                            
                            //                    NSString *xmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                            //                    NSLog(@"XML : %@", xmlString);
                            
                            // assign delegate to parse the XML data
                            NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
                            XMLParserDelegate *parserDelegate = [XMLParserDelegate new];
                            
                            parser.delegate = parserDelegate;
                            
                            if([parser parse]) {
                                objects = [parserDelegate getParserResults];
                                
                                NSLog(@"get XML count : %lu", (unsigned long)objects.count);
                                
                                if(objects.count > 0) {
                                    //NSLog(@"HERE: %@",objects);
                                    [self allDataToAverage:startDate WithEndDate:endDate];
                                } else {
                                    NSLog(@"??? no data in range %@ to %@ ???", _lastUpdateTime, timeString);
                                }
                            } else {
                                // fail to parse
                                NSLog(@"!!! parser range data error !!!");
                            }
                        }
                    }];
        // wait for data received
        while (compareDisplayCount != displayCount) {
        }
    }
}
- (void) allDataToAverage:(NSString*)startDate WithEndDate:(NSString*)endDate{
    // Take up all data
    // judge the time is in the interval or not.
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDateFormatter *minuteFormatter = [NSDateFormatter new];
    [minuteFormatter setDateFormat:@"yyyy-MM-dd HH:mm:00"];
    
    // Cut Time point after second
    startDate = [startDate substringToIndex:startDate.length - 4];
    endDate = [endDate substringToIndex:endDate.length - 4];
    
    Sensor *firstObj = objects[0];
    NSString *firstObjTime = firstObj.date;
    firstObjTime = [firstObjTime substringToIndex:firstObjTime.length - 4];
    
    // Setup Time
    NSLog(@"%@%@",startDate,endDate);
    NSDate *minuteTime = [dateFormatter dateFromString:firstObjTime];
    
    // Setup per min time interval
    int piece = 1;
    NSString *minuteStart = [minuteFormatter stringFromDate:minuteTime];
    minuteTime = [minuteTime dateByAddingTimeInterval:60];
    NSString *minuteEnd = [minuteFormatter stringFromDate:minuteTime];
    
    
    for (sensorToAverage in objects) {
        //NSLog(@"%@",sensorToAverage.value);
        
        // Per minute
        NSString *clearTime = [sensorToAverage.date substringToIndex:sensorToAverage.date.length - 4];
        if([self compareTimeInterval:clearTime
                           WithStart:minuteStart
                             WithEnd:minuteEnd]){
            valueTotal += sensorToAverage.value.doubleValue;
            // Caculate total count of data
            piece ++;
        } else {
            valueTotal = valueTotal / (piece-1);
            Sensor *sensorPerMinute = [Sensor new];
            if(compareDisplayCount == 0){
                sensorPerMinute.type = @"溫度";
            }else if (compareDisplayCount == 1){
                sensorPerMinute.type = @"濕度";
            }
            
            NSString *valueTotalString = [NSString stringWithFormat:@"%.1f",valueTotal];
            sensorPerMinute.value = @(valueTotalString.doubleValue);
            sensorPerMinute.date = minuteEnd;
            [allAveragePerMinute addObject:sensorPerMinute];
            
            // Reset valueTotal and piece
            valueTotal = 0.0;
            piece = 1;
            
            // Setup per min time interval
            minuteStart = [minuteFormatter stringFromDate:minuteTime];
            minuteTime = [minuteTime dateByAddingTimeInterval:60];
            minuteEnd = [minuteFormatter stringFromDate:minuteTime];
        }
    }
    NSLog(@"%@",allAveragePerMinute);
    // Reset valueTotal and piece
    valueTotal = 0.0;
    piece = 1;
    [differentTypeValue addObject:allAveragePerMinute];
    allAveragePerMinute = [NSMutableArray new];
    compareDisplayCount += 1;
}


-(BOOL)compareTimeInterval:(NSString*)comparedTime WithStart:(NSString*)intervalStartTime WithEnd:(NSString*)intervalEndTime{
    
    // Setup dateformatter
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    // Check the date if it is in the time interval
    NSDate *beComparedTime = [dateFormatter dateFromString:comparedTime];
    NSDate *startTime = [dateFormatter dateFromString:intervalStartTime];
    NSDate *endTime = [dateFormatter dateFromString:intervalEndTime];
    
    
    NSDate *result = [beComparedTime earlierDate:startTime];
    if([result isEqualToDate:beComparedTime]){
        return false;
    }else{
        result = [beComparedTime earlierDate:endTime];
        if([result isEqualToDate:beComparedTime]){
            return true;
        }
        return false;
    }
    
}



-(void) dataToJSON{
    //differentTypeValue
    NSMutableArray *toJsonArray = [NSMutableArray new];
    //NSMutableArray *allValueToDataArray = [NSMutableArray new];
    NSMutableDictionary *allValueToDictionary = [NSMutableDictionary new];
    //NSMutableArray *jsonArray = [NSMutableArray new];
    NSDictionary *header;
    
    // For loop to make data into JSON
    for (NSArray *eachValues in differentTypeValue) {
        
        for (Sensor *eachValue in eachValues) {
            if([eachValue.type isEqualToString:@"溫度"]){
                status = @"溫度",
                header = @{DBAVERAGE_VALUE_TABLE:AVERAGEID10001,
                           DATACOUNTKEY:@(eachValues.count)};
            } else if([eachValue.type isEqualToString:@"濕度"]){
                status = @"濕度";
                header = @{DBAVERAGE_VALUE_TABLE:AVERAGEID10002,
                           DATACOUNTKEY:@(eachValues.count)};
            }
            NSArray *everyValue = @[@{DATEKEY:eachValue.date,
                                      VALUEKEY:eachValue.value}];
            [toJsonArray addObjectsFromArray:everyValue];
        }
        [allValueToDictionary addEntriesFromDictionary:header];
        [allValueToDictionary setObject:toJsonArray forKey:DATAKEY];
        
        
        NSError *error;
        // Encode JSON
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:allValueToDictionary options:NSJSONWritingPrettyPrinted error:&error];
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",jsonString);
        NSLog(@"First time over!!!");
        if ([status isEqualToString:@"溫度"]) {
            [self uploadAverageValue:@"temperatureAverage"];
        }else if([status isEqualToString:@"濕度"]){
            [self uploadAverageValue:@"humidAverage"];
        }
        // reset JSON array in order to clear data
        toJsonArray = [NSMutableArray new];
        
    }
}





#pragma mark - Upload Average Value
- (void)uploadAverageValue:(NSString*)identifier{
    
    NSURL *url = [[NSURL alloc] initWithString:config.dbSensorValueAddress];
    
    //int SensorIndex = 0;
    
    //Sensor *sensor = allSensorsInfo[SensorIndex];
    //NSString *averageDBName = sensor.dbAverageValueTable;
    // Upload Average
    [httpComm uploadAverageToServer:url
                            timeout:INTERNET_TIMEOUT
                         insertData:jsonString
                         identifier:identifier
                       functionType:@"insertAverage"];
                         //completion:nil];
    _lastUpdateTime = nil;
    /*
    [httpComm sendHTTPPost:url
                   timeout:INTERNET_TIMEOUT
                   dbTable:averageDBName
                  sensorID:@"1"
                 startDate:nil
                   endDate:nil
                insertData:jsonString
              functionType:@"insertAverage"
                completion:^(NSData *data, NSURLResponse *response, NSError *error) {
                    if (error) {
                        NSLog(@"!!! ERROR1 !!!");
                        NSLog(@"HTTP Get Sensor Info. Failed : %@", error.localizedDescription);
                    }else {
                        NSLog(@"%@",response);
                        NSLog(@"insert Average pass~");
                    } 
                }];
     ^(NSData *data, NSURLResponse *response, NSError *error) {
     if (error) {
     NSLog(@"!!! ERROR1 !!!");
     NSLog(@"HTTP Get Sensor Info. Failed : %@", error.localizedDescription);
     }else {
     NSLog(@"%@",response);
     NSLog(@"insert Average pass~");
     }
     }
     */
}
-(void)wait{
    //...
}







@end
