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

@interface RealtimeChartViewController ()

@property (nonatomic, strong)   dispatch_source_t timer;
@property (weak, nonatomic) IBOutlet UIView *realChartView;

@end

@implementation RealtimeChartViewController
{
    HTTPComm *httpComm;
    ConfigManager *config;
    double drawValue;
    bool isWaitingResponse;
    NSMutableArray *objects;
    NSString *requestCurrentDate;
    bool isNeedToUpdateRequestDate;
    NSMutableArray *values;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    httpComm = [HTTPComm sharedInstance];
    config = [ConfigManager sharedInstance];
    
    isWaitingResponse = false;
    isNeedToUpdateRequestDate = true;
    
    values = [NSMutableArray array];
    
    RealChartView *ccc = [[RealChartView alloc] initWithFrame:_realChartView.bounds];
    
    [_realChartView addSubview:ccc];
    
    double delayInSeconds = 1.0;  // 1 秒畫一點
    // 创建一个 timer 类型定时器 （ DISPATCH_SOURCE_TYPE_TIMER）
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    // 设置定时器的各种属性（何时开始，间隔多久执行）
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), (unsigned)(delayInSeconds * NSEC_PER_SEC), 0);
    // 任务回调
    
    dispatch_source_set_event_handler(_timer, ^{
        ///*
        isWaitingResponse = true;
        
        NSURL *url = [[NSURL alloc] initWithString:config.dbMainAddress];
        
        if(isNeedToUpdateRequestDate == true) {
            isNeedToUpdateRequestDate = false;
            
            // get current time to get newest data
            NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
            [DateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];               // 24 hours
            requestCurrentDate = [DateFormatter stringFromDate:[NSDate date]];
        }
        
        NSLog(@"start date : %@", requestCurrentDate);
        
        [httpComm sendHTTPPost:url timeout:1 sensorID:@"1" startDate:requestCurrentDate endDate:config.endDate functionType:@"getNew" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            if (error) {
                NSLog(@"!!! ERROR1 !!!");
                NSLog(@"HTTP Get Newest Data Faile : %@", error.localizedDescription);
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
                            
                            for(Sensor *sensor in objects) {
                                //double a = [sensor.value doubleValue];
                                [values addObject:[NSNumber numberWithDouble:[sensor.value doubleValue]]];
                                requestCurrentDate = sensor.date;
                            }
                            
//                            RealChartView *ccc = [[RealChartView alloc] initWithFrame:_realChartView.bounds];
//                            
//                            [_realChartView addSubview:ccc];
                            [ccc updateValues:values];
                            
//                            CGRect frame = _realChartView.frame;
                            
                        });
                    }
                } else {
                    // fail to parse
                }
                
                isWaitingResponse = false;
            }
        }];
        //*/
    });
    
    // 开始定时器任务（定时器默认开始是暂停的，需要复位开启）
    dispatch_resume(_timer);
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
