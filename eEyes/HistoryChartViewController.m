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

@interface HistoryChartViewController () <DVLineChartViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *historyChartView;

@end

@implementation HistoryChartViewController
{
    HTTPComm *httpComm;
    ConfigManager *config;
    
    NSMutableArray *objects;
    NSMutableArray *values;
    NSMutableArray *date;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    httpComm = [HTTPComm sharedInstance];
    config = [ConfigManager sharedInstance];
    values = [NSMutableArray array];
    date = [NSMutableArray array];
    
    NSURL *url = [[NSURL alloc] initWithString:config.dbSensorValueAddress];
    
    [httpComm sendHTTPPost:url timeout:1 sensorID:@"1" startDate:config.startDate endDate:config.endDate functionType:@"getRange" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"!!! ERROR1 !!!");
            NSLog(@"HTTP Get Range Data Faile : %@", error.localizedDescription);
        }else {
            
            NSString *xmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"XML : %@", xmlString);
            
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
                
                NSLog(@"get XML count : %lu", (unsigned long)objects.count);
                
                if(objects.count > 0) {
                    // switch to main queue to reload the tableView
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setupDataThenDrawHistoryChart];
                    });
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

- (void) setupDataThenDrawHistoryChart {
    
//    self.view.backgroundColor = [UIColor colorWithHexString:@"3e4a59"];
    _historyChartView.backgroundColor = [UIColor colorWithHexString:@"3e4a59"];
    
//    DVLineChartView *ccc = [[DVLineChartView alloc] init];
    
    DVLineChartView *ccc = [[DVLineChartView alloc] initWithFrame:_historyChartView.bounds];
    
//    [self.view addSubview:ccc];
    [_historyChartView addSubview:ccc];
    
    for(Sensor *sensor in objects) {
        //double a = [sensor.value doubleValue];
        [values addObject:[NSNumber numberWithDouble:[sensor.value doubleValue]]];
        [date addObject:sensor.date];
    }
    ccc.xAxisTitleArray = date;
    DVPlot *plot = [[DVPlot alloc] init];
    plot.pointArray = values;
    
//    ccc.width = self.view.width;
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
    
//    ccc.xAxisTitleArray = @[@"4.1", @"4.2", @"4.3", @"4.4", @"4.5", @"4.6", @"4.7", @"4.8", @"4.9", @"4.10", @"4.11", @"4.12", @"4.13", @"4.14", @"4.15", @"4.16", @"4.17", @"4.18", @"4.19", @"4.20", @"4.21", @"4.22", @"4.23", @"4.24", @"4.25", @"4.26", @"4.27", @"4.28", @"4.29", @"4.30"];
    
    
    ccc.x = 0;
    ccc.y = 100;
//    ccc.width = self.view.width;
    ccc.width = _historyChartView.width;
    ccc.height = 300;
    
    
    
//    DVPlot *plot = [[DVPlot alloc] init];
//    plot.pointArray = @[@300, @550, @700, @200, @370, @890, @760, @430, @210, @30, @300, @550, @700, @200, @370, @890, @760, @430, @210, @30, @300, @550, @700, @200, @370, @890, @760, @430, @210, @30];
    
    
    
    
    plot.lineColor = [UIColor colorWithHexString:@"2f7184"];
    plot.pointColor = [UIColor colorWithHexString:@"14b9d6"];
    plot.chartViewFill = YES;
    plot.withPoint = YES;
    
    
    DVPlot *plot1 = [[DVPlot alloc] init];
    plot1.pointArray = @[@100, @300, @200, @120, @650, @770, @240, @530, @10, @90, @100, @300, @200, @120, @650, @770, @240, @530, @10, @90, @100, @300, @200, @120, @650, @770, @240, @530, @10, @90];
    
    
    plot1.lineColor = [[UIColor blueColor] colorWithAlphaComponent:0.3];
    plot1.pointColor = [UIColor whiteColor];
    plot1.chartViewFill = YES;
    plot1.withPoint = YES;
    
    [ccc addPlot:plot];
//    [ccc addPlot:plot1];
    [ccc draw];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)lineChartView:(DVLineChartView *)lineChartView DidClickPointAtIndex:(NSInteger)index {
    
    NSLog(@"%ld", index);
    
}

@end
