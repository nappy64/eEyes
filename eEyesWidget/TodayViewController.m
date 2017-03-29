//
//  TodayViewController.m
//  eEyesWidget
//
//  Created by Nap Chen on 2017/3/29.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "HTTPComm.h"
#import "Sensor.h"
#import "XMLParserDelegate.h"

@interface TodayViewController () <NCWidgetProviding>

@property (weak, nonatomic) IBOutlet UILabel *value1Label;
@property (weak, nonatomic) IBOutlet UILabel *value2Label;

@property (nonatomic, strong)   dispatch_source_t timer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *toAppTapGesture;

@end

@implementation TodayViewController
{
    HTTPComm *httpComm;
    
    double value1, value2;
    
    bool isWaitingResponse, isError, isGotData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    isGotData = false;
    
    self.preferredContentSize = CGSizeMake(320.0, 60.0);
    self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
    
    httpComm = [HTTPComm sharedInstance];
    
    // create timer
    double delayInSeconds = 1.0;  // 1 秒畫一點
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), (unsigned)(delayInSeconds * NSEC_PER_SEC), 0);
    
    // regular task
    dispatch_source_set_event_handler(_timer, ^{
        
        [self sendHTTPPostGetData];
    });
    
    // start timer
    dispatch_resume(_timer);
}

- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {
    
    if(activeDisplayMode == NCWidgetDisplayModeExpanded) {
        self.preferredContentSize = CGSizeMake(320.0, 60.0);
    } else if(activeDisplayMode == NCWidgetDisplayModeCompact) {    // no effect for NCWidgetDisplayModeCompact
        self.preferredContentSize = CGSizeMake(320.0, 60.0);
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    
    dispatch_source_cancel(_timer);
//    NSLog(@"886");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (void) sendHTTPPostGetData {
    
    NSURL *url = [[NSURL alloc] initWithString:@"http://192.168.43.119/dbSensorValue.php"];
    
    isError = false;
    
    for(int i = 0; i < 2; i++) {
        
        NSString *dbTableName = @"RealID10001";
        NSString *sensorIDStr = @"1";
        
        if(i == 1) {
            dbTableName = @"RealID10002";
            sensorIDStr = @"2";
        }
        
        isWaitingResponse = true;
        
        [httpComm sendHTTPPost:url timeout:1 dbTable:dbTableName sensorID:sensorIDStr startDate:@" " endDate:@" " insertData:@" " functionType:@"getNewest" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            NSMutableArray *objects = [NSMutableArray new];
            
            if (error) {
                NSLog(@"!!! HTTP Get Newest Data Faile : %@ !!!", error.localizedDescription);
                isError = true;
            }else {
                
//                NSString *xmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                // parse the XML data
                NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
                XMLParserDelegate *parserDelegate = [XMLParserDelegate new];
                
                parser.delegate = parserDelegate;
                
                if([parser parse]) {
                    // success
                    objects = [parserDelegate getParserResults];
                    
                    if(objects.count > 0) {
                        
                        // save newest data
                        Sensor *sensor = objects[0];
                        if([sensor.id integerValue] == 1) {
                            value1 = [sensor.value doubleValue];
                        } else if([sensor.id integerValue] == 2) {
                            value2 = [sensor.value doubleValue];
                            
                            isGotData = true;
                        }
                    } else {
                        NSLog(@"no data...");
                        return;
                    }
                } else {
                    // fail to parse
                    NSLog(@"資料解析錯誤！");
                    isError = true;
                }
            }
            isWaitingResponse = false;
        }];
    }
    
    if(isError == false && isGotData == true)
    {
        NSLog(@"upadte %@ , %@...", [NSString stringWithFormat:@"%.1f", value1], [NSString stringWithFormat:@"%.1f", value2]);
        // update sensor value
        _value1Label.text = [NSString stringWithFormat:@"%.1f", value1];
        _value2Label.text = [NSString stringWithFormat:@"%.1f", value2];
    }
}

// tap to execute app
- (IBAction)toAppGestureTapped:(UITapGestureRecognizer *)sender {
    
    // open URL to execute self container App
    NSURL *url = [NSURL URLWithString:@"eeyeswidget://2"];
    [self.extensionContext openURL:url completionHandler:^(BOOL success) {
        NSLog(@"openURL result : %@",(success?@"pass~":@"!!! fail !!!"));
    }];
}

@end
