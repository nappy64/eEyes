//
//  ExportCSVFile.m
//  eEyes
//
//  Created by Nap Chen on 2017/1/10.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "ExportCSVFile.h"

@implementation ExportCSVFile
{
    ExportSensorItem *sensorItem;
    Sensor *sensorInfo;
    AllSensors *allSensors;
    NSArray *allSensorsInfo;
    ConfigManager *config;
    HTTPComm *httpComm;
    NSMutableArray *objects;
    NSMutableString *csvString;
    NSInteger sensorType;
    NSString *finalFileName;
    int displayCount;           // http send count
    int compareDisplayCount;
    
}

static ExportCSVFile *_singletonExportCSVFile = nil;
+ (instancetype) sharedInstance{
    if(_singletonExportCSVFile == nil){
        _singletonExportCSVFile = [ExportCSVFile new];
    }
    return _singletonExportCSVFile;
}
- (instancetype) init{
    config = [ConfigManager sharedInstance];
    
    httpComm = [HTTPComm sharedInstance];
    allSensors = [AllSensors sharedInstance];
    allSensorsInfo = [allSensors getAllSensorsInfo];
    sensorItem = [ExportSensorItem shareInstance];
    objects = [NSMutableArray new];
    
    return self;
}


- (void) prepareDataForGenerateCSV:(NSString*) sensorID
                          fileName:(NSString*)fileName
                         startDate:(NSString*) startDate
                           endDate:(NSString*) endDate{
    csvString = [NSMutableString new];
    finalFileName = fileName;
    NSURL *url = [[NSURL alloc] initWithString:config.dbSensorValueAddress];
    sensorInfo = [Sensor new];
    compareDisplayCount = 0;
    displayCount = 0;
    // Check data type
    
    sensorInfo = allSensorsInfo[0];
    if(sensorInfo.isSelected == true){
        sensorInfo = allSensorsInfo[1];
        if (sensorInfo.isSelected == true) {
            sensorType = bothTempAndHumid;
        }else{
            sensorType = onlyTemp;
        }
    }else{
        sensorInfo = allSensorsInfo[1];
        if (sensorInfo.isSelected == true) {
            sensorType = onlyHumid;
            compareDisplayCount = 1;
            displayCount = 1;
        }else{
            sensorType = noData;
        }
        
    }
    for(int i = 0; i < allSensorsInfo.count; i++) {
        
        sensorInfo = allSensorsInfo[i];
        
        if(sensorInfo.isSelected) {
            
            displayCount += 1;
            
            [httpComm sendHTTPPost:url timeout:1 dbTable:nil sensorID:[sensorInfo.sensorID stringValue] startDate:config.startDate endDate:config.endDate insertData:nil functionType:@"getRange" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
                
                if (error) {
                    NSLog(@"!!! ERROR1 !!!");
                    NSLog(@"HTTP Get Range Data Faile : %@", error.localizedDescription);
                    
                    compareDisplayCount = displayCount;
                    
                    NSLog( @"網路傳輸失敗！");
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
                            [self dataHandler];
                        } else {
                            NSLog(@"??? no data in range %@ to %@ ???", config.startDate, config.endDate);
                            
                            compareDisplayCount = displayCount;
                            
                            NSLog( @"時間範圍內無資料！");
                        }
                    } else {
                        // fail to parse
                        NSLog(@"!!! parser range data error !!!");
                        
                        compareDisplayCount = displayCount;
                        
                        NSLog( @"資料解析錯誤！");
                    }
                }
            }];
        }
        
        // wait for data received
        while (compareDisplayCount != displayCount) {
        }
    }
    
}

- (void) dataHandler{
    for (Sensor *sensor in objects) {
        [sensorItem.sensorID addObject:sensor.id];
        if (displayCount == 1) {
            [sensorItem.temperatureValue addObject:sensor.value];
        }else if (displayCount == 2){
            [sensorItem.humidityValue addObject:sensor.value];
        }
        [sensorItem.time addObject:sensor.date];
    }
//    displayCount += 1;
    if (sensorType == bothTempAndHumid) {
        if(displayCount == 2 && sensorType != onlyHumid){
            [self lineCSVStringUp];
        }
    }else if(sensorType == onlyTemp ){
        if(displayCount == 1){
            [self lineCSVStringUp];
        }
    }else if (sensorType == onlyHumid){
        if(displayCount == 2){
            [self lineCSVStringUp];
            
        }
    }
    compareDisplayCount += 1;
}

- (void) lineCSVStringUp{
    if (sensorItem.temperatureValue.count != 0 && sensorItem.humidityValue.count == 0) {
        csvString = [[NSMutableString alloc]initWithString:@"No,ID,Temperature,Time\n"];
        for(int j = 0;j < objects.count;j++){
            //sensorInfo = objects[j];
            [csvString appendFormat:@"%d,%@,%@,%@\n",j+1,sensorItem.sensorID[j],sensorItem.temperatureValue[j],sensorItem.time[j]];
        }
    }else if(sensorItem.temperatureValue.count == 0 && sensorItem.humidityValue.count != 0){
        csvString = [[NSMutableString alloc]initWithString:@"No,ID,Humidity,Time\n"];
        for(int j = 0;j < objects.count;j++){
            //sensorInfo = objects[j];
            [csvString appendFormat:@"%d,%@,%@,%@\n",j+1,sensorItem.sensorID[j],sensorItem.humidityValue[j],sensorItem.time[j]];
        }
        
    }else if(sensorItem.temperatureValue.count != 0 && sensorItem.humidityValue.count != 0){
        csvString = [[NSMutableString alloc]initWithString:@"No,ID,Temperature,Humidity,Time\n"];
        for(int j = 0;j < sensorItem.temperatureValue.count;j++){
            //sensorInfo = objects[j];
            [csvString appendFormat:@"%d,%@,%@,%@,%@\n",j+1,sensorItem.sensorID[j],sensorItem.temperatureValue[j],sensorItem.humidityValue[j],sensorItem.time[j]];
        }
        
    }else{
        // No selected data
    }
    
    NSString *result = [csvString substringToIndex:csvString.length - 1];
    csvString = [NSMutableString stringWithString:result];
    [self generateCSVData:nil fileName:@"zzz"];
    NSLog(@"%@",csvString);
    [sensorItem reset];
}




- (void) generateCSVData:(NSString*)startDate
                fileName:(NSString*) fileName{
    NSData *contentData = [csvString dataUsingEncoding:NSUTF8StringEncoding];
    BOOL pass = [self createCSVFile:finalFileName dataOfContent:contentData];
    NSLog(@"%d",pass);
    
}

- (BOOL) createCSVFile:(NSString*) fileName dataOfContent:(NSData*) data{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Create NSString object, that holds our exact path to the documents directory
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.csv", fileName]];
    NSLog(@"CSVFilePath:  %@",fullPath);
    
    BOOL result = [[NSFileManager defaultManager] createFileAtPath:fullPath contents:data attributes:nil];
    NSLog(@"CreateOrNot:  %d",result);
    return result;
}



-(NSMutableArray *)transferCSVToArray:(NSString *)fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    //NSLog(@"%@",fullPath);
    NSData *csvData = [[NSFileManager defaultManager]contentsAtPath:fullPath];
    NSString *csvToString = [[NSString alloc]initWithData:csvData encoding:NSUTF8StringEncoding];
    //NSLog(@"data轉換回字串:%@",csvToString);
    NSMutableArray *humidValueColumn = [NSMutableArray array];
    NSMutableArray *valueColumn = [NSMutableArray array];
    NSMutableArray *timeColumn = [NSMutableArray array];
    
    // CSV Type Check.
    
    // Use Title to check type.
    
    NSString *csvTitle = [csvToString substringToIndex:33];
    if ([csvTitle containsString:@"Temperature"]) {
        if ([csvTitle containsString:@"Humidity"]) {
            sensorType = bothTempAndHumid;
        }else{
            sensorType = onlyTemp;
        }
    }else{
        if ([csvTitle containsString:@"Humidity"]){
            sensorType = onlyHumid;
        }else{
            sensorType = noData;
        }
    }
    
    if(sensorType == bothTempAndHumid){
        
        NSString *csvCutTitle = [csvToString substringFromIndex:33];
        for (NSString *line in [csvCutTitle componentsSeparatedByString:@"\n"]){
            NSArray *row = [line componentsSeparatedByString:@","];
            [valueColumn addObject:row[2]];
            //NSLog(@"%@",row[3]);
            [timeColumn addObject:row[4]];
            [humidValueColumn addObject:row[3]];
        }
        
        
        
    }else if (sensorType == onlyTemp){
        NSString *csvCutTitle = [csvToString substringFromIndex:24];
        
        for (NSString *line in [csvCutTitle componentsSeparatedByString:@"\n"]){
            NSArray *row = [line componentsSeparatedByString:@","];
            
            [valueColumn addObject:row[2]];
            NSLog(@"%@",row[3]);
            [timeColumn addObject:row[3]];
        }
        
    }else if (sensorType == onlyHumid){
        NSString *csvCutTitle = [csvToString substringFromIndex:21];
        for (NSString *line in [csvCutTitle componentsSeparatedByString:@"\n"]){
            NSArray *row = [line componentsSeparatedByString:@","];
            
            [valueColumn addObject:row[2]];
            NSLog(@"%@",row[3]);
            [timeColumn addObject:row[3]];
        }
        
    }
    
    NSMutableArray *result = [NSMutableArray new];
    [result insertObject:valueColumn atIndex:0];
    [result insertObject:timeColumn atIndex:1];
    if(sensorType == bothTempAndHumid){
        [result insertObject:humidValueColumn atIndex:2];
    }
    
    return result;
    
    
    
    /*
     // Remove Title
     NSString *csvCutTitle = [csvToString substringFromIndex:18];
     // Remove the last \n
     //NSString *csvCut = [csvCutTitle substringToIndex:csvCutTitle.length-2];
     //NSLog(@"%@",csvCutTitle);
     for (NSString *line in [csvCutTitle componentsSeparatedByString:@"\n"]){
     NSArray *row = [line componentsSeparatedByString:@","];
     
     [valueColumn addObject:row[2]];
     //NSLog(@"%@",row[3]);
     [timeColumn addObject:row[3]];
     }
     */
    
    
}




@end
