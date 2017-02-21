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
#import "AllSensors.h"
#import "ExportSensorItem.h"

@interface ExportCSVFile : NSObject
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

}
@property NSString *fileNameSelected;
+ (instancetype) sharedInstance;
- (void) prepareDataForGenerateCSV:(NSString*) sensorID
                          fileName:(NSString*)fileName
                         startDate:(NSString*) startDate
                           endDate:(NSString*) endDate;

- (BOOL) createCSVFile:(NSString*) fileName dataOfContent:(NSData*) data;

- (NSMutableArray*) transferCSVToArray:(NSString*)fileName;



@end
