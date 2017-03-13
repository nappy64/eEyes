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

#define X_AXIS_GAP_STEP 5
#define X_AXIS_MAX_GAP  100
#define X_AXIS_MID_GAP  1.0
#define X_AXIS_MIN_GAP  0.1

#define Y_AXIS_GAP_STEP 5
#define Y_AXIS_MAX_GAP  500
#define Y_AXIS_MIN_GAP  1

@interface HistoryChartViewController () <DVLineChartViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *historyChartView;
@property (weak, nonatomic) IBOutlet UIButton *isDisplayRemarkButton;
@property (weak, nonatomic) IBOutlet UILabel *sensor1ValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *sensor2ValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *sensorDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalPointsLabel;


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
    int dataCount;
    
    CGFloat xAxisGap;
    CGFloat yAxisGap;
}

- (void)viewWillLayoutSubviews {
    
    // debug
//    CGRect frame = CGRectMake(_historyChartView.x, _historyChartView.y, _historyChartView.size.width, _historyChartView.size.height);
//    NSLog(@"viewWillLayoutSubviews origin X : %f1, Y : %f1, W : %f1, H : %f1", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
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
    
    xAxisGap = 30;
    yAxisGap = 100;
    
    CGSize viewSize = [[UIScreen mainScreen] bounds].size;
    
    CGFloat STATUS_BAR_HEIGHT = 20;
    UIInterfaceOrientation CURRENT_ORIENTATION = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(UIInterfaceOrientationIsLandscape(CURRENT_ORIENTATION)){
        viewSize = CGSizeMake(_historyChartView.height, _historyChartView.width - STATUS_BAR_HEIGHT);
        
    } else {
        viewSize = CGSizeMake(_historyChartView.width, _historyChartView.height - STATUS_BAR_HEIGHT);
    }
    
    // debug
//    NSLog(@"initial origin W : %f1, H : %f1", viewSize.width, viewSize.height);
    
    if(config.isDisplayValueInHistoryChart) {
        _isDisplayRemarkButton.backgroundColor = [UIColor greenColor];
    } else {
        _isDisplayRemarkButton.backgroundColor = [UIColor grayColor];
    }
    
    [self sendHTTPPostGetData];
    
    // move to viewDidAppear
//    [self drawHistoryChart];
    
    
    // debug
//    [self listSubviewsOfView:self.view];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
//    NSLog(@"viewWillAppear H : %f1, H : %f1",_historyChartView.size.width, _historyChartView.size.height);
}

- (void)viewDidAppear:(BOOL)animated {
    
//    NSLog(@"viewDidAppear H : %f1, H : %f1",_historyChartView.size.width, _historyChartView.size.height);
    
    [self drawHistoryChart];
}


- (void)listSubviewsOfView:(UIView *)view {
    
    // Get the subviews of the view
    NSArray *subviews = [view subviews];
    
    // Return if there are no subviews
    if ([subviews count] == 0) return; // COUNT CHECK LINE
    
    for (UIView *subview in subviews) {
        
        // Do what you want to do with the subview
        NSLog(@"%@", subview);
        
        // List the subviews of subview
        [self listSubviewsOfView:subview];
    }
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
            
            [httpComm sendHTTPPost:url timeout:1 dbTable:nil sensorID:[sensor.sensorID stringValue] startDate:config.startDate endDate:config.endDate insertData:nil functionType:@"getRange" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
                
                if (error) {
                    NSLog(@"!!! ERROR1 !!!");
                    NSLog(@"HTTP Get Range Data Faile : %@", error.localizedDescription);
                    
                    compareDisplayCount = displayCount;
                    
                    [self popoutWarningMessage:@"網路傳輸失敗！"];
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
                            dataCount = (int)objects.count;
                            [self setupData];
                        } else {
                            NSLog(@"??? no data in range %@ to %@ ???", config.startDate, config.endDate);
                            
                            compareDisplayCount = displayCount;
                            
                            [self popoutWarningMessage:@"時間範圍內無資料！"];
                        }
                    } else {
                        // fail to parse
                        NSLog(@"!!! parser range data error !!!");
                        
                        compareDisplayCount = displayCount;
                        
                        [self popoutWarningMessage:@"資料解析錯誤！"];
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
    
    _historyChartView.backgroundColor = [UIColor whiteColor];
    
    CGRect chartRect = CGRectMake(0, 0, _historyChartView.bounds.size.width, _historyChartView.bounds.size.height);

    ccc = [[DVLineChartView alloc] initWithFrame:chartRect];

    [_historyChartView addSubview:ccc];
    
    ccc.width = self.view.bounds.size.width;
    
    // Y 座標刻度與左方的間距
    ccc.yAxisViewWidth = 52;
    
    // Y 軸分成幾格
    ccc.numberOfYAxisElements = 10;
    
    ccc.delegate = self;
    ccc.pointUserInteractionEnabled = YES;
    
    // Y 軸最大值
    ccc.yAxisMaxValue = yAxisGap;
    
    // 兩點間的 X 軸間距
    ccc.pointGap = xAxisGap;
    
    ccc.showSeparate = YES;
    ccc.separateColor = [UIColor colorWithHexString:@"67707c"];
    
    ccc.textColor = [UIColor colorWithHexString:@"9aafc1"];
    ccc.backColor = [UIColor whiteColor];
    ccc.axisColor = [UIColor colorWithHexString:@"67707c"];
    
    ccc.x = 0;
    ccc.y = 0;
    ccc.width = _historyChartView.width;
    ccc.height = _historyChartView.height;

    DVPlot *plot = [[DVPlot alloc] init];
    DVPlot *plot1 = [[DVPlot alloc] init];
    HistoryChartValues *hcv = [HistoryChartValues new];
    
    for(int i = 0; i < chartList.count; i++) {
        hcv = chartList[i];
        
        if(i == 0) {
            plot.pointArray = hcv.values;
            plot.lineColor = [UIColor orangeColor];
            plot.pointColor = [UIColor orangeColor];
//            plot.chartViewFill = YES;
            plot.withPoint = YES;
            [ccc addPlot:plot];
        } else {
            plot1.pointArray = hcv.values;
            plot1.lineColor = [UIColor blueColor];
            plot1.pointColor = [UIColor blueColor];
//            plot1.chartViewFill = YES;
            plot1.withPoint = YES;
            [ccc addPlot:plot1];
        }
        
        NSLog(@"plat data %@",hcv.values[0]);
    }
    
    ccc.xAxisTitleArray = hcv.date;
    
    _totalPointsLabel.text = [NSString stringWithFormat:@"%lu Points",(unsigned long)hcv.date.count];
    
    ccc.xAxisViewX = 0;
    ccc.xAxisViewY = 0;
    ccc.xAxisViewW = dataCount * ccc.pointGap + 200;
    ccc.xAxisViewH = ccc.height;
    
    ccc.yAxisViewX = 0;
    ccc.yAxisViewY = 0;
    ccc.yAxisViewW = ccc.yAxisViewWidth;
    ccc.yAxisViewH = ccc.height;
    
    ccc.scrollViewX = ccc.yAxisViewWidth;
    ccc.scrollViewY = 0;
    ccc.scrollViewW = _historyChartView.width - ccc.yAxisViewW;
    ccc.scrollViewH = ccc.height;
    
    [ccc draw];
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

- (IBAction)xIncrementButtonTapped:(UIButton *)sender {
    
    [ccc removeFromSuperview];
    
    if(xAxisGap >= X_AXIS_MAX_GAP) {
        xAxisGap = X_AXIS_MAX_GAP;
    } else if(xAxisGap < X_AXIS_MID_GAP && xAxisGap >= X_AXIS_MIN_GAP) {
        xAxisGap += X_AXIS_MIN_GAP;
    } else {
        xAxisGap += X_AXIS_GAP_STEP;
        
        if(xAxisGap > X_AXIS_MAX_GAP) {
            xAxisGap = X_AXIS_MAX_GAP;
        }
    }
    
    NSLog(@"xAxisGap : %f",xAxisGap);
    
    [self drawHistoryChart];
}

- (IBAction)xDecrementButtonTapped:(UIButton *)sender {
    
    [ccc removeFromSuperview];
    
    if(xAxisGap <= X_AXIS_MIN_GAP) {
        xAxisGap = X_AXIS_MIN_GAP;
    } else if (xAxisGap > X_AXIS_MIN_GAP && xAxisGap <= X_AXIS_MID_GAP) {
        xAxisGap -= X_AXIS_MIN_GAP;
        if(xAxisGap <= X_AXIS_MIN_GAP) {
            xAxisGap = X_AXIS_MIN_GAP;
        }
    } else {
        xAxisGap -= X_AXIS_GAP_STEP;
        
        if(xAxisGap < X_AXIS_MIN_GAP) {
            xAxisGap = X_AXIS_MID_GAP;
        }
    }
    
    NSLog(@"xAxisGap : %f",xAxisGap);
    
    [self drawHistoryChart];
}

- (IBAction)yIncrementButtonTapped:(UIButton *)sender {
    
    [ccc removeFromSuperview];
    
    if(yAxisGap >= Y_AXIS_MAX_GAP) {
        yAxisGap = Y_AXIS_MAX_GAP;
    } else {
        yAxisGap += Y_AXIS_GAP_STEP;
        
        if(yAxisGap > Y_AXIS_MAX_GAP) {
            yAxisGap = Y_AXIS_MAX_GAP;
        }
    }
    
    NSLog(@"yAxisGap : %f",yAxisGap);
    
    [self drawHistoryChart];
}

- (IBAction)yDecrementButtonTapped:(UIButton *)sender {
    
    [ccc removeFromSuperview];
    
    if(yAxisGap <= Y_AXIS_MIN_GAP) {
        yAxisGap = Y_AXIS_MIN_GAP;
    } else {
        yAxisGap -= Y_AXIS_GAP_STEP;
        
        if(yAxisGap < Y_AXIS_MIN_GAP) {
            yAxisGap = Y_AXIS_MIN_GAP;
        }
    }
    
    NSLog(@"yAxisGap : %f",yAxisGap);
    
    [self drawHistoryChart];
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
    
    NSLog(@"press at index : %ld", index);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        HistoryChartValues *hcv = chartList[0];
        double value = [hcv.values[index] doubleValue];
        _sensor1ValueLabel.text = [NSString stringWithFormat : @"%.1f", value];

        hcv = chartList[1];
        value = [hcv.values[index] doubleValue];
        _sensor2ValueLabel.text = [NSString stringWithFormat : @"%.1f", value];

        _sensorDateLabel.text = hcv.date[index];
    });
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    [ccc removeFromSuperview];
    
    [self drawHistoryChart];
}

@end
