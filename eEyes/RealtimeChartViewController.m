//
//  RealtimeChartViewController.m
//  eEyes
//
//  Created by Nap Chen on 2017/1/17.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "RealtimeChartViewController.h"
#import "HTTPComm.h"
#import "ConfigManager.h"
#import "XMLParserDelegate.h"
#import "Sensor.h"
#import "RealChartView.h"
#import "AllSensors.h"
#import "HistoryChartValues.h"

@interface RealtimeChartViewController ()

@property (nonatomic, strong)   dispatch_source_t timer;
@property (weak, nonatomic) IBOutlet UIView *realChartView;

@end

@implementation RealtimeChartViewController
{
    HTTPComm *httpComm;
    ConfigManager *config;
    AllSensors *allSensors;
    
    RealChartView *ccc;
    
    NSArray *allSensorsInfo;
    
    double drawValue;
    bool isWaitingResponse;
    NSMutableArray *objects;
    NSString *requestCurrentDate;
    bool isNeedToUpdateRequestDate;
    bool isBypassThisTimeRequest;
    NSMutableArray *values;
    NSMutableArray *values1;
    
    NSMutableArray *chartList;
    
    int selectedSensorCount;
    int displayCount;           // http send count
    int compareDisplayCount;    // http receive count
    int systemCounter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    httpComm = [HTTPComm sharedInstance];
    config = [ConfigManager sharedInstance];
    allSensors = [AllSensors sharedInstance];
    
    allSensorsInfo = [allSensors getAllSensorsInfo];
    
    isWaitingResponse = false;
    isNeedToUpdateRequestDate = true;
    isBypassThisTimeRequest = false;
    
    values = [NSMutableArray array];
    values1 = [NSMutableArray array];
    
    chartList = [NSMutableArray array];
    
    [self getSelectedSensorCount];
    
    displayCount = 0;
    compareDisplayCount = 0;

    CGRect chartRect = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-48);
    
    ccc = [[RealChartView alloc] initWithFrame:chartRect];
    
    [self.view addSubview:ccc];
    
    // create timer
    double delayInSeconds = 1.0;  // 1 秒畫一點
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), (unsigned)(delayInSeconds * NSEC_PER_SEC), 0);
    
    // regular task
    dispatch_source_set_event_handler(_timer, ^{
        systemCounter += 1;
        
        [self sendHTTPPostGetData];
    });
    
    // start timer
    dispatch_resume(_timer);
    
}

- (void) getSelectedSensorCount {
    
    selectedSensorCount = 0;
    
    for (Sensor *sensor in allSensorsInfo) {
        if(sensor.isSelected) {
            selectedSensorCount += 1;
        }
    }
}

- (void) sendHTTPPostGetData {
    
    if(compareDisplayCount != 0 && displayCount != 0) {
        return;
    }
    
    isWaitingResponse = true;
    
    NSURL *url = [[NSURL alloc] initWithString:config.dbMainAddress];
    
    if(isNeedToUpdateRequestDate == true) {
        isNeedToUpdateRequestDate = false;
        
        // get current time to get newest data
        NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
        [DateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];               // 24 hours
        requestCurrentDate = [DateFormatter stringFromDate:[NSDate date]];
    }
    
    Sensor *sensor = [Sensor new];
    
    for(int i = 0; i < allSensorsInfo.count; i++) {
        
        NSLog(@"111 HTTP reuest...%d", i);
        
        NSString *dbTableName = @"";
        sensor = allSensorsInfo[i];
        
        if(sensor.isSelected) {
        
            if(isBypassThisTimeRequest == false) {
                
                NSLog(@"222 start date : %@", requestCurrentDate);
                
                displayCount += 1;
                
                dbTableName = sensor.dbRealValueTable;
                
                [httpComm sendHTTPPost:url timeout:1 dbTable:dbTableName sensorID:[sensor.sensorID stringValue] startDate:requestCurrentDate endDate:config.endDate insertData:nil functionType:@"getNew" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
                    
                    if (error) {
                        NSLog(@"!!! ERROR1 !!!");
                        NSLog(@"HTTP Get Newest Data Faile : %@", error.localizedDescription);
                        
                        compareDisplayCount += 1;
                        
                        isBypassThisTimeRequest = true;
                    }else {
                        
                        NSString *xmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        NSLog(@"333 XML : %@", xmlString);
                        
                        // parse the XML data
                        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
                        XMLParserDelegate *parserDelegate = [XMLParserDelegate new];
                        
                        parser.delegate = parserDelegate;
                        
                        if([parser parse]) {
                            // success
                            objects = [parserDelegate getParserResults];
                            
                            NSLog(@"444 get XML count : %lu", (unsigned long)objects.count);
                            
                            if(objects.count > 0) {
                                [self setupData];
                            } else {
                                compareDisplayCount += 1;
                                
                                NSLog(@"!!! no data received !!! #1:%d #2:%d", compareDisplayCount, displayCount );
                                
                                isBypassThisTimeRequest = true;
                                
                                return;
                            }
                        } else {
                            // fail to parse
                        }
                        
                        isWaitingResponse = false;
                    }
                }];
                NSLog(@"counter #1:%d #2:%d", compareDisplayCount, displayCount);
                while (compareDisplayCount != displayCount) {
//                    NSLog(@"000 counter #1:%d #2:%d", compareDisplayCount, displayCount);
                }
            } else {
                NSLog(@"!!! has bypass HTTP request !!!");
            }
            
            
        }
    }
    
    NSLog(@"888 setup data...%lu", (unsigned long)chartList.count);
    
    if(chartList.count > 0) {
    
        if(chartList.count == 1) {
            NSArray *value = chartList[0];
            NSLog(@"997 array count:%lu, value #0:%@", (unsigned long)value.count, value[0]);
        } else if(chartList.count == 2) {
            NSArray *value = chartList[0];
            NSLog(@"997 array count:%lu, value #0:%@", (unsigned long)value.count, value[0]);
            NSArray *value1 = chartList[1];
            NSLog(@"998 array count:%lu, value #1:%@", (unsigned long)value1.count, value1[0]);
        }
        
        NSLog(@"999 chartList %lu update values", chartList.count);
    }
    
    if(chartList.count == selectedSensorCount) {
        [ccc updateValues:chartList];
    }
    
    displayCount = 0;
    compareDisplayCount = 0;
    isBypassThisTimeRequest = false;
    
//    chartList = nil;
    chartList = [NSMutableArray array];
}

- (void) setupData {
    
    for(Sensor *sensor in objects) {
        
        NSLog(@"555 setup data...%@", sensor.value);
        
        if(displayCount == 1) {
            [values addObject:[NSNumber numberWithDouble:[sensor.value doubleValue]]];
            NSLog(@"666 sensor#1 data:%@, count:%lu", sensor.value, (unsigned long)values.count);
        } else if(displayCount == 2) {
            if(values1.count < values.count) {
                [values1 addObject:[NSNumber numberWithDouble:[sensor.value doubleValue]]];
                requestCurrentDate = sensor.date;
                NSLog(@"777 sensor#2 data:%@, count:%lu", sensor.value, (unsigned long)values1.count);
            } else {
                NSLog(@"!!! sensor#2 values array larger than sensor#1 !!!");
            }
            
        }
    }
    
    if(displayCount == 1) {
        [chartList addObject:values];
    } else if(displayCount == 2) {
        [chartList addObject:values1];
        
        isBypassThisTimeRequest = false;
    }
    
    compareDisplayCount += 1;
}

-(void)viewDidDisappear:(BOOL)animated {
    
    dispatch_source_cancel(_timer);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
