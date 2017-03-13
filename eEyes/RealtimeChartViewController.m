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
@property (weak, nonatomic) IBOutlet UIButton *isDisplayRemarkButton;

@property (nonatomic, strong)   dispatch_source_t timer;
@property (weak, nonatomic) IBOutlet UIView *realChartView;
@property (weak, nonatomic) IBOutlet UIButton *isAutoYAxisButton;
@property (weak, nonatomic) IBOutlet UILabel *sensor1ValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *sensor2ValueLabel;
@property (weak, nonatomic) IBOutlet UITextField *yMaxRangeTextField;

@end

@implementation RealtimeChartViewController
{
    HTTPComm *httpComm;
    ConfigManager *config;
    AllSensors *allSensors;
    
    RealChartView *ccc;
    
    NSArray *allSensorsInfo;
    
    bool isWaitingResponse;
    NSMutableArray *objects;
    NSString *requestCurrentDate;
    bool isNeedToUpdateRequestDate;
    bool isBypassThisTimeRequest;
    bool isDisplayValue;
    bool isYAxisAutoDetecting;
    NSMutableArray *values;
    NSMutableArray *values1;
    
    NSMutableArray *chartList;
    
    int selectedSensorCount;
    int displayCount;           // http send count
    int compareDisplayCount;    // http receive count
    int systemCounter;
    
    CGFloat xScale;
    
    CGFloat yMaxValue;
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
    isYAxisAutoDetecting = true;
    
    values = [NSMutableArray array];
    values1 = [NSMutableArray array];
    
    chartList = [NSMutableArray array];
    
    [self getSelectedSensorCount];
    
    displayCount = 0;
    compareDisplayCount = 0;
    
    xScale = 25;
    yMaxValue = [_yMaxRangeTextField.text doubleValue];
    
    isDisplayValue = true;
    
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
    
//    [_isAutoYAxisButton setHidden:true];
}

- (void)viewDidAppear:(BOOL)animated {
    
    CGRect chartRect = CGRectMake(0, 0, _realChartView.bounds.size.width, _realChartView.bounds.size.height);
    
    ccc = [[RealChartView alloc] initWithFrame:chartRect];
    
    ccc.xScale = xScale;
    
//    if(isYAxisAutoDetecting == false) {
//        ccc.yScale = 3;
//    }
    
    [_realChartView addSubview:ccc];
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
    
    NSURL *url = [[NSURL alloc] initWithString:config.dbSensorValueAddress];
    
    if(isNeedToUpdateRequestDate == true) {
        isNeedToUpdateRequestDate = false;
        
        // get current time to get newest data
        NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
        [DateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];               // 24 hours
        requestCurrentDate = [DateFormatter stringFromDate:[NSDate date]];
    }
    
    Sensor *sensor = [Sensor new];
    
    for(int i = 0; i < allSensorsInfo.count; i++) {
        
//        NSLog(@"111 HTTP reuest...%d", i);
        
        NSString *dbTableName = @"";
        sensor = allSensorsInfo[i];
        
        if(sensor.isSelected) {
        
            if(isBypassThisTimeRequest == false) {
                
//                NSLog(@"222 start date : %@", requestCurrentDate);
                
                displayCount += 1;
                
                dbTableName = sensor.dbRealValueTable;
                
                NSLog(@"~ send HTTP Get Newest Data : %@, start date : %@", [sensor.sensorID stringValue], requestCurrentDate);
                
                [httpComm sendHTTPPost:url timeout:1 dbTable:dbTableName sensorID:[sensor.sensorID stringValue] startDate:requestCurrentDate endDate:config.endDate insertData:nil functionType:@"getNew" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
                    
                    if (error) {
//                        NSLog(@"!!! ERROR1 !!!");
                        NSLog(@"!!! HTTP Get Newest Data Faile : %@ !!!", error.localizedDescription);
                        
                        compareDisplayCount += 1;
                        
                        isBypassThisTimeRequest = true;
                        
                        [self popoutWarningMessage:@"網路傳輸失敗！"];
                        
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
                                
//                                NSLog(@"!!! no data received !!! #1:%d #2:%d", compareDisplayCount, displayCount );
                                
                                isBypassThisTimeRequest = true;
                                
                                return;
                            }
                        } else {
                            // fail to parse
                            [self popoutWarningMessage:@"資料解析錯誤！"];
                        }
                        
                        isWaitingResponse = false;
                    }
                }];
//                NSLog(@"counter #1:%d #2:%d", compareDisplayCount, displayCount);
                while (compareDisplayCount != displayCount) {
//                    NSLog(@"000 counter #1:%d #2:%d", compareDisplayCount, displayCount);
                }
            } else {
                NSLog(@"!!! has bypass HTTP request !!!");
            }
        }
    }
    
//    NSLog(@"888 setup data...%lu", (unsigned long)chartList.count);
    
    if(chartList.count == selectedSensorCount) {
        
        if(isYAxisAutoDetecting == true) {
            double maxValue = 0;
            
            // check the max value in values
            for(NSNumber *value in values) {
                double val = [value doubleValue];
                if(val > maxValue) {
                    maxValue = val;
                    ccc.yScale = _realChartView.bounds.size.height / maxValue * 0.9;
                }
            }
            
            for(NSNumber *value in values1) {
                double val = [value doubleValue];
                if(val > maxValue) {
                    maxValue = val;
                    ccc.yScale = _realChartView.bounds.size.height / maxValue * 0.9;
                }
            }
            ccc.maxValue = maxValue / 0.9;
        } else {
            ccc.yScale = _realChartView.bounds.size.height / yMaxValue;
            ccc.maxValue = yMaxValue;
        }
        
        
        ccc.isDisplayValue = isDisplayValue;
        [ccc updateValues:chartList];
    }
    
    displayCount = 0;
    compareDisplayCount = 0;
    isBypassThisTimeRequest = false;
    
//    chartList = nil;
    chartList = [NSMutableArray array];
}


- (void) popoutWarningMessage:(NSString*)message {
    
    // alert title
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"注意" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    // confirm button
    UIAlertAction* confirm = [UIAlertAction actionWithTitle:@"確認" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:confirm];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) setupData {
    
    for(Sensor *sensor in objects) {
        
//        NSLog(@"555 setup data...%@", sensor.value);
        double value = [sensor.value doubleValue];
        
        if(displayCount == 1) {
            [values addObject:[NSNumber numberWithDouble:value]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _sensor1ValueLabel.text = [sensor.value stringValue];
            });
            
            NSLog(@"666 sensor#1 count:%lu", (unsigned long)values.count);
            
            if (values.count > (int)_realChartView.bounds.size.width) {
                // over max display points
                [values removeObjectsInRange:NSMakeRange(0, values.count - (int)_realChartView.bounds.size.width)];
                NSLog(@"667 sensor#1 exceed...");
            }
            
        } else if(displayCount == 2) {
            if(values1.count < values.count) {
                [values1 addObject:[NSNumber numberWithDouble:value]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    _sensor2ValueLabel.text = [sensor.value stringValue];
                });
                
                requestCurrentDate = sensor.date;
                
                NSLog(@"777 sensor#2 count:%lu", (unsigned long)values1.count);
                
                if (values1.count > (int)_realChartView.bounds.size.width) {
                    // over max display points
                    [values1 removeObjectsInRange:NSMakeRange(0, values1.count - (int)_realChartView.bounds.size.width)];
                    NSLog(@"778 sensor#1 exceed...");
                }
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    [ccc removeFromSuperview];
    
    CGRect chartRect = CGRectMake(0, 0, _realChartView.bounds.size.width, _realChartView.bounds.size.height);
    
    ccc = [[RealChartView alloc] initWithFrame:chartRect];
    
    ccc.xScale = xScale;
    
    [_realChartView addSubview:ccc];
}

- (IBAction)xIncrementButtonTapped:(UIButton *)sender {
    
    if(xScale >= 50) {
        xScale = 50;
    } else {
        xScale += 1;
    }
    
    ccc.xScale = xScale;
    
    NSLog(@"X Up : %lf",xScale);
}

- (IBAction)xDecrementButtonTapped:(UIButton *)sender {
    
    if(xScale <= 1) {
        xScale = 1;
    } else {
        xScale -= 1;
    }
    
    ccc.xScale = xScale;
    NSLog(@"X Down : %lf",xScale);
}

- (IBAction)displayRemarkButtonTapped:(UIButton *)sender {
    
    if(isDisplayValue == true) {
        isDisplayValue = false;
        ccc.isDisplayValue = false;
        _isDisplayRemarkButton.backgroundColor = [UIColor grayColor];

    } else {
        isDisplayValue = true;
        ccc.isDisplayValue = true;
        _isDisplayRemarkButton.backgroundColor = [UIColor greenColor];
    }
}

- (IBAction)autoYAxisSizingButtonTapped:(UIButton *)sender {
    
    if(isYAxisAutoDetecting == true) {
        isYAxisAutoDetecting = false;
        _isAutoYAxisButton.backgroundColor = [UIColor grayColor];    } else {
        isYAxisAutoDetecting = true;
        _isAutoYAxisButton.backgroundColor = [UIColor greenColor];
    }
}

- (IBAction)yMaxRangeModified:(id)sender {
    
    yMaxValue = [_yMaxRangeTextField.text doubleValue];
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
