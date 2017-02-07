//
//  HistoryChartViewController.m
//  eEyes
//
//  Created by Nap Chen on 2017/1/20.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "HistoryChartViewController.h"
#import "DVLineChartView.h"
#import "UIView+Extension.h"
#import "UIColor+Hex.h"
#import "HTTPComm.h"
#import "ConfigManager.h"
#import "XMLParserDelegate.h"
#import "Sensor.h"
#import "HistoryChartValues.h"
#import "AllSensors.h"

@interface HistoryChartViewController () <DVLineChartViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *historyChartView;
@property (weak, nonatomic) IBOutlet UIButton *isDisplayRemarkButton;

@end

@implementation HistoryChartViewController
{
    HTTPComm *httpComm;
    ConfigManager *config;
    AllSensors *allSensors;
    DVLineChartView *ccc;
    
    NSArray *allSensorsInfo;
    
    NSMutableArray *objects;
    
    NSMutableArray *chartList;
    
    int displayCount;           // http send count
    int compareDisplayCount;    // http receive count
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    httpComm = [HTTPComm sharedInstance];
    config = [ConfigManager sharedInstance];
    allSensors = [AllSensors sharedInstance];
    
    allSensorsInfo = [allSensors getAllSensorsInfo];
    
    chartList = [NSMutableArray array];
    
    displayCount = 0;
    compareDisplayCount = 0;
    
    if(config.isDisplayValueInHistoryChart) {
        _isDisplayRemarkButton.backgroundColor = [UIColor greenColor];
    } else {
        _isDisplayRemarkButton.backgroundColor = [UIColor grayColor];
    }
    
    [self sendHTTPPostGetData];
    
    [self drawHistoryChart];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [config setAllConfig];
}

- (void) sendHTTPPostGetData {
    
    NSURL *url = [[NSURL alloc] initWithString:config.dbSensorValueAddress];
    Sensor *sensor = [Sensor new];
    
    for(int i = 0; i < allSensorsInfo.count; i++) {
        
        sensor = allSensorsInfo[i];
        
        if(sensor.isSelected) {
            
            displayCount += 1;
            
            [httpComm sendHTTPPost:url timeout:1 dbTable:nil sensorID:[sensor.sensorID stringValue] startDate:config.startDate endDate:config.endDate functionType:@"getRange" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
                
                if (error) {
                    NSLog(@"!!! ERROR1 !!!");
                    NSLog(@"HTTP Get Range Data Faile : %@", error.localizedDescription);
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
                                [self setupData];
                        } else {
                            NSLog(@"??? no data in range %@ to %@ ???", config.startDate, config.endDate);
                        }
                    } else {
                        // fail to parse
                        NSLog(@"!!! parser range data error !!!");
                    }
                }
            }];
        }
        
        // wait for data received
        while (compareDisplayCount != displayCount) {
        }
    }
}


- (void) setupData {
    
    HistoryChartValues *hcv = [HistoryChartValues new];
    hcv.values = [NSMutableArray array];
    hcv.date = [NSMutableArray array];
    
    for(Sensor *sensor in objects) {
        [hcv.values addObject:[NSNumber numberWithDouble:[sensor.value doubleValue]]];
        [hcv.date addObject:sensor.date];
    }
    
    [chartList addObject:hcv];
    
    compareDisplayCount += 1;
}

- (void) drawHistoryChart {
    
    _historyChartView.backgroundColor = [UIColor colorWithHexString:@"3e4a59"];
    
    ccc = [[DVLineChartView alloc] initWithFrame:_historyChartView.bounds];

    [_historyChartView addSubview:ccc];
    
    ccc.width = _historyChartView.width;
    
    // Y 座標刻度與左方的間距
    ccc.yAxisViewWidth = 52;
    
    // Y 軸分成幾格
    ccc.numberOfYAxisElements = 20;
    
    ccc.delegate = self;
    ccc.pointUserInteractionEnabled = YES;
    
    // Y 軸最大值
    ccc.yAxisMaxValue = 100;
    
    // 兩點間的 X 軸間距
    ccc.pointGap = 30;
    
    ccc.showSeparate = YES;
    ccc.separateColor = [UIColor colorWithHexString:@"67707c"];
    
    ccc.textColor = [UIColor colorWithHexString:@"9aafc1"];
    ccc.backColor = [UIColor colorWithHexString:@"3e4a59"];
    ccc.axisColor = [UIColor colorWithHexString:@"67707c"];
    
    ccc.x = 0;
    ccc.y = 100;
    ccc.width = _historyChartView.width;
    ccc.height = 300;

    DVPlot *plot = [[DVPlot alloc] init];
    DVPlot *plot1 = [[DVPlot alloc] init];
    HistoryChartValues *hcv = [HistoryChartValues new];
    
    for(int i = 0; i < chartList.count; i++) {
        hcv = chartList[i];
        
        if(i == 0) {
            plot.pointArray = hcv.values;
            plot.lineColor = [UIColor colorWithHexString:@"2f7184"];
            plot.pointColor = [UIColor colorWithHexString:@"14b9d6"];
            plot.chartViewFill = YES;
            plot.withPoint = YES;
            [ccc addPlot:plot];
        } else {
            plot1.pointArray = hcv.values;
            plot1.lineColor = [[UIColor blueColor] colorWithAlphaComponent:0.3];
            plot1.pointColor = [UIColor whiteColor];
            plot1.chartViewFill = YES;
            plot1.withPoint = YES;
            [ccc addPlot:plot1];
        }
        
        NSLog(@"plat data %@",hcv.values[0]);
    }
    
    ccc.xAxisTitleArray = hcv.date;
    
    [ccc draw];
    
}

- (IBAction)xIncrementButtonTapped:(UIButton *)sender {
    
}

- (IBAction)xDecrementButtonTapped:(UIButton *)sender {
    
}

- (IBAction)yIncrementButtonTapped:(UIButton *)sender {
    
}

- (IBAction)yDecrementButtonTapped:(UIButton *)sender {
    
}

- (IBAction)displayRemarkButtonTapped:(UIButton *)sender {
    
    if(config.isDisplayValueInHistoryChart) {
        [config setIsDisplayValueInHistoryChart:false];
        _isDisplayRemarkButton.backgroundColor = [UIColor grayColor];

    } else {
        [config setIsDisplayValueInHistoryChart:true];
        _isDisplayRemarkButton.backgroundColor = [UIColor greenColor];
    }

    [ccc removeFromSuperview];
    
    [self drawHistoryChart];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)lineChartView:(DVLineChartView *)lineChartView DidClickPointAtIndex:(NSInteger)index {
    
    NSLog(@"%ld", index);
    
}

@end
