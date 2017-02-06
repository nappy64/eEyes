//
//  ExportCSVFile.h
//  eEyes
//
//  Created by Nap Chen on 2017/1/10.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPComm.h"
#import "ConfigManager.h"
#import "XMLParserDelegate.h"
#import "Sensor.h"
#import "HistoryChartValues.h"
@interface ExportCSVFile : NSObject
{
    Sensor *sensorInfo;
    ConfigManager *config;
    HTTPComm *httpComm;
    NSMutableArray *objects;
    NSMutableArray *values;
    NSMutableArray *date;
    NSMutableString *csvString;
}
@property NSString *fileNameSelected;
+ (instancetype) sharedInstance;
- (void) prepareDataForGenerateCSV:(NSString*) sensorID
                         startDate:(NSString*) startDate
                           endDate:(NSString*) endDate;

- (BOOL) createCSVFile:(NSString*) fileName dataOfContent:(NSData*) data;

- (NSMutableArray*) transferCSVToArray:(NSString*)fileName;



@end
