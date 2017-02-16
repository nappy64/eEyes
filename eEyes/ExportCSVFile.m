//
//  ExportCSVFile.m
//  eEyes
//
//  Created by Nap Chen on 2017/1/10.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "ExportCSVFile.h"

@implementation ExportCSVFile

static ExportCSVFile *_singletonExportCSVFile = nil;
+ (instancetype) sharedInstance{
    if(_singletonExportCSVFile == nil){
        _singletonExportCSVFile = [ExportCSVFile new];
    }
    return _singletonExportCSVFile;
}

- (void) prepareDataForGenerateCSV:(NSString*) sensorID
                          fileName:(NSString*)fileName
                         startDate:(NSString*) startDate
                           endDate:(NSString*) endDate{
    httpComm = [HTTPComm sharedInstance];
    NSURL *url = [[NSURL alloc] initWithString:@"http://127.0.0.1/dbSensorValue.php"];
    
    [httpComm sendHTTPPost:url timeout:1 dbTable:nil sensorID:sensorID startDate:startDate endDate:endDate insertData:nil functionType:@"getRange" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"!!! ERROR1 !!!");
            NSLog(@"HTTP Get Range Data Fail : %@", error.localizedDescription);
        }else {
            
            //NSString *xmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //NSLog(@"XML : %@", xmlString);
            
            // parse the XML data
            // 创建解析器
            NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
            XMLParserDelegate *parserDelegate = [XMLParserDelegate new];
            // 设置代理
            parser.delegate = parserDelegate;
            
            // called to start the event-driven parse.
            // 開始使用 delegate 的 parse 動作
            if([parser parse]) {
                // success
                objects = [parserDelegate getParserResults];
                //NSLog(@"A: %@",objects);
                NSLog(@"get XML count : %lu", (unsigned long)objects.count);
                csvString = [[NSMutableString alloc]initWithString:@"No,ID,Value,Time\n"];
                if(objects.count > 0) {
                    for(int i = 0;i < objects.count;i++){
                        sensorInfo = objects[i];
                        [csvString appendFormat:@"%d,%@,%@,%@\n",i+1,sensorInfo.id,sensorInfo.value,sensorInfo.date];
                    }
                    //NSLog(@"%@",csvString);
                } else {
                    NSLog(@"??? no data in range %@ to %@ ???", startDate, endDate);
                }
            } else {
                // fail to parse
                NSLog(@"!!! parser range data error !!!");
            }
            [self generateCSVData:startDate fileName:fileName];
        }
    }];
    
}


- (void) generateCSVData:(NSString*)startDate
                fileName:(NSString*) fileName{
    NSData *contentData = [csvString dataUsingEncoding:NSUTF8StringEncoding];
    BOOL pass = [self createCSVFile:fileName dataOfContent:contentData];
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
    
    NSMutableArray *valueColumn = [NSMutableArray array];
    NSMutableArray *timeColumn = [NSMutableArray array];
    // Remove Title
    NSString *csvCutTitle = [csvToString substringFromIndex:18];
    // Remove the last \n
    NSString *csvCut = [csvCutTitle substringToIndex:csvCutTitle.length-2];
    //NSLog(@"%@",csvCutTitle);
    for (NSString *line in [csvCut componentsSeparatedByString:@"\n"]){
        NSArray *row = [line componentsSeparatedByString:@","];
        
        [valueColumn addObject:row[2]];
        //NSLog(@"%@",row[3]);
        [timeColumn addObject:row[3]];
    }
    NSMutableArray *result = [NSMutableArray new];
    [result insertObject:valueColumn atIndex:0];
    [result insertObject:timeColumn atIndex:1];
    
    //NSMutableArray *result = [[valueColumn arrayByAddingObjectsFromArray:timeColumn] mutableCopy];
//    NSArray* rows = [csvToString componentsSeparatedByString:@"\n"];
//    for (NSString *row in rows){
//        NSArray* columns = [row componentsSeparatedByString:@","];
//        
//        [valueColumn addObject:columns[2]];
//        [timeColumn addObject:columns[3]];
//    }

return result;

}




@end
