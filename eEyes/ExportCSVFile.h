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

@property NSString *fileNameSelected;
+ (instancetype) sharedInstance;
- (instancetype) init;
- (void) prepareDataForGenerateCSV:(NSString*) sensorID
                          fileName:(NSString*)fileName
                         startDate:(NSString*) startDate
                           endDate:(NSString*) endDate;

- (BOOL) createCSVFile:(NSString*) fileName dataOfContent:(NSData*) data;

- (NSMutableArray*) transferCSVToArray:(NSString*)fileName;



@end
