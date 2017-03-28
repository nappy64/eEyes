//
//  ViewController.m
//  eEyes
//
//  Created by Nap Chen on 2017/1/10.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "ViewController.h"
#import "DrawChartSettingViewController.h"
#import "ExportTableViewController.h"
#import "AlarmTableViewController.h"
#import "ConfigTableViewController.h"
#import "ConfigManager.h"
#import "HTTPComm.h"
#import "AllSensors.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UIButton *btnCharting;
@property (weak, nonatomic) IBOutlet UIButton *btnExport;
@property (weak, nonatomic) IBOutlet UIButton *btnAlarm;
@property (weak, nonatomic) IBOutlet UIButton *btnSetting;

@end

@implementation ViewController
{
    HTTPComm *httpComm;
    ConfigManager *config;
    AllSensors *allSensors;
    
    BOOL isGetDBInfo;
    BOOL isOrientationLandscape;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    /*
    NSLog(@"H : %f, W : %f",self.view.bounds.size.height, self.view.bounds.size.width);
    
    if(self.view.bounds.size.height > self.view.bounds.size.width) {
        isOrientationLandscape = false;
    } else {
        isOrientationLandscape = true;
    }
    
    [self setButtonPosition];
    
    // 讀取目錄檔案
    // list the record files
    NSString *path=[NSString stringWithFormat:@"%@/Documents",NSHomeDirectory()];
    NSFileManager *myFileManager=[NSFileManager defaultManager];
    NSDirectoryEnumerator *myDirectoryEnumerator;
    
    myDirectoryEnumerator=[myFileManager enumeratorAtPath:path];
    
    //列举目录内容
    NSLog(@"用enumeratorAtPath:显示目录%@的内容：",path);
    
    while((path=[myDirectoryEnumerator nextObject])!=nil) {
        NSLog(@"%@",path);
    }
    
    httpComm = [HTTPComm sharedInstance];
    config = [ConfigManager sharedInstance];
    allSensors = [AllSensors sharedInstance];
    
    [config initialConfigPlist];
//    [config resetAllConfig];
    [config getAllConfig];
    
    NSURL *url = [[NSURL alloc] initWithString:config.dbInfoAddress];
    
    isGetDBInfo = false;
    
    [httpComm sendHTTPPost:url timeout:1 dbTable:nil sensorID:@"1" startDate:config.startDate endDate:config.endDate insertData:nil functionType:@"getSensorByUser" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"!!! ERROR1 !!!");
            NSLog(@"HTTP Get Sensor Info. Faile : %@", error.localizedDescription);
            [self popoutWarningMessage:@"網路傳輸失敗！"];
        }else {
            
            NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"JSON : %@", jsonString);
            
            NSMutableDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
            
            NSString *result = dataDictionary[@"result"];
            
            if([result isEqualToString: @"true"]) {
            
                [allSensors transferJSONToSensorsInfo:dataDictionary];
            
                isGetDBInfo = true;
            } else {
                NSString *errString = dataDictionary[@"errorCode"];
                [self popoutWarningMessage:errString];
            }
        }
    }];
    */
    
    // for test insert data function
    /*
    while (!isGetDBInfo) {
        
    }
    
    // test for HTTP insert
    NSArray *allSensorsInfo;
    allSensorsInfo = [allSensors getAllSensorsInfo];
    
    NSString *insertValue = @"123.4";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    
    int SensorIndex = 0;
    
    Sensor *sensor = allSensorsInfo[SensorIndex];
    NSString *averageDBName = sensor.dbAverageValueTable;
    
    url = [[NSURL alloc] initWithString:config.dbSensorValueAddress];
    
    [httpComm sendHTTPPost:url timeout:1 dbTable:averageDBName sensorID:@"1" startDate:dateStr endDate:nil insertData:insertValue functionType:@"insert" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"!!! ERROR1 !!!");
            NSLog(@"HTTP Get Sensor Info. Faile : %@", error.localizedDescription);
        }else {
            
        }
    }];
    */
    
    
    // test for HTTP insertAverage
    /*
    while (!isGetDBInfo) {
        
    }
    // test for HTTP insertAverage
    NSArray *allSensorsInfo;
    allSensorsInfo = [allSensors getAllSensorsInfo];
    
    NSString *insertValue = @"{\"dbAverageValueTable\":\"AverageID10001\",\"dataCount\":6,\"data\":[{\"date\":\"2017-02-21 10:00:00\",\"value\":23.4},{\"date\":\"2017-02-21 10:01:00\",\"value\":23.4},{\"date\":\"2017-02-21 10:02:00\",\"value\":23.4},{\"date\":\"2017-02-21 10:03:00\",\"value\":23.4},{\"date\":\"2017-02-21 10:04:00\",\"value\":23.4},{\"date\":\"2017-02-21 10:05:00\",\"value\":23.4}]}";
    
    url = [[NSURL alloc] initWithString:config.dbSensorValueAddress];
    
    [httpComm sendHTTPPost:url timeout:1 dbTable:nil sensorID:@"1" startDate:nil endDate:nil insertData:insertValue functionType:@"insertAverage" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"!!! ERROR1 !!!");
            NSLog(@"HTTP Get Sensor Info. Faile : %@", error.localizedDescription);
        }else {
            NSLog(@"insert Average pass~");
        }
    }];
    */
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    
    NSLog(@"H : %f, W : %f",self.view.bounds.size.height, self.view.bounds.size.width);
    
    if(self.view.bounds.size.height > self.view.bounds.size.width) {
        isOrientationLandscape = false;
    } else {
        isOrientationLandscape = true;
    }
    
    [self setButtonPosition];
    
    // 讀取目錄檔案
    // list the record files
    NSString *path=[NSString stringWithFormat:@"%@/Documents",NSHomeDirectory()];
    NSFileManager *myFileManager=[NSFileManager defaultManager];
    NSDirectoryEnumerator *myDirectoryEnumerator;
    
    myDirectoryEnumerator=[myFileManager enumeratorAtPath:path];
    
    //列举目录内容
    NSLog(@"用enumeratorAtPath:显示目录%@的内容：",path);
    
    while((path=[myDirectoryEnumerator nextObject])!=nil) {
        NSLog(@"%@",path);
    }
    
    httpComm = [HTTPComm sharedInstance];
    config = [ConfigManager sharedInstance];
    allSensors = [AllSensors sharedInstance];
    
    [config initialConfigPlist];
    //    [config resetAllConfig];
    [config getAllConfig];
    
    NSURL *url = [[NSURL alloc] initWithString:config.dbInfoAddress];
    
    isGetDBInfo = false;
    
    [httpComm sendHTTPPost:url timeout:1 dbTable:nil sensorID:@"1" startDate:config.startDate endDate:config.endDate insertData:nil functionType:@"getSensorByUser" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"!!! ERROR1 !!!");
            NSLog(@"HTTP Get Sensor Info. Faile : %@", error.localizedDescription);
            [self popoutWarningMessage:@"網路傳輸失敗！"];
        }else {
            
            NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"JSON : %@", jsonString);
            
            NSMutableDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
            
            NSString *result = dataDictionary[@"result"];
            
            if([result isEqualToString: @"true"]) {
                
                [allSensors transferJSONToSensorsInfo:dataDictionary];
                
                isGetDBInfo = true;
            } else {
                NSString *errString = dataDictionary[@"errorCode"];
                [self popoutWarningMessage:errString];
            }
        }
    }];
    
    
    // for test insert data function
    /*
     while (!isGetDBInfo) {
     
     }
     
     // test for HTTP insert
     NSArray *allSensorsInfo;
     allSensorsInfo = [allSensors getAllSensorsInfo];
     
     NSString *insertValue = @"123.4";
     
     NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
     [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
     NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
     
     int SensorIndex = 0;
     
     Sensor *sensor = allSensorsInfo[SensorIndex];
     NSString *averageDBName = sensor.dbAverageValueTable;
     
     url = [[NSURL alloc] initWithString:config.dbSensorValueAddress];
     
     [httpComm sendHTTPPost:url timeout:1 dbTable:averageDBName sensorID:@"1" startDate:dateStr endDate:nil insertData:insertValue functionType:@"insert" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
     
     if (error) {
     NSLog(@"!!! ERROR1 !!!");
     NSLog(@"HTTP Get Sensor Info. Faile : %@", error.localizedDescription);
     }else {
     
     }
     }];
     */
    
    
    // test for HTTP insertAverage
    /*
     while (!isGetDBInfo) {
     
     }
     // test for HTTP insertAverage
     NSArray *allSensorsInfo;
     allSensorsInfo = [allSensors getAllSensorsInfo];
     
     NSString *insertValue = @"{\"dbAverageValueTable\":\"AverageID10001\",\"dataCount\":6,\"data\":[{\"date\":\"2017-02-21 10:00:00\",\"value\":23.4},{\"date\":\"2017-02-21 10:01:00\",\"value\":23.4},{\"date\":\"2017-02-21 10:02:00\",\"value\":23.4},{\"date\":\"2017-02-21 10:03:00\",\"value\":23.4},{\"date\":\"2017-02-21 10:04:00\",\"value\":23.4},{\"date\":\"2017-02-21 10:05:00\",\"value\":23.4}]}";
     
     url = [[NSURL alloc] initWithString:config.dbSensorValueAddress];
     
     [httpComm sendHTTPPost:url timeout:1 dbTable:nil sensorID:@"1" startDate:nil endDate:nil insertData:insertValue functionType:@"insertAverage" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
     
     if (error) {
     NSLog(@"!!! ERROR1 !!!");
     NSLog(@"HTTP Get Sensor Info. Faile : %@", error.localizedDescription);
     }else {
     NSLog(@"insert Average pass~");
     }
     }];
     */
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)drawChartButtonPressed:(UIButton *)sender {
    // goto next page DrawChartTableViewController
    
    // message
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"繪圖種類" message:@"選擇曲線種類" preferredStyle:UIAlertControllerStyleAlert];
    
    // real time chart
    UIAlertAction* realTimeChart = [UIAlertAction actionWithTitle:@"即時曲線" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"即時曲線...");
//        [config setDisplayRealTimeChartEnable:true];
        config.isDisplayRealTimeChart = true;
        [self setToDrawChartTableViewController];
    }];
    
    // history chart
    UIAlertAction* historyChart = [UIAlertAction actionWithTitle:@"歷史曲線" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"歷史曲線...");
//        [config setDisplayRealTimeChartEnable:false];
        config.isDisplayRealTimeChart = false;
        [self setToDrawChartTableViewController];
    }];
    
    // cancel
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"取消...");
    }];
    
    [alert addAction:realTimeChart];
    [alert addAction:historyChart];
    [alert addAction:cancel];
    
    // 顯示警告視窗
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void) setToDrawChartTableViewController {
    DrawChartSettingViewController *drawChartPage = [self.storyboard instantiateViewControllerWithIdentifier:@"DrawChartSettingViewController"];
    
    [self showViewController:drawChartPage sender:nil];
}

- (IBAction)exportDataButtonPressed:(UIButton *)sender {
    // goto next page ExportTableViewController
    ExportTableViewController *exportDataPage = [self.storyboard instantiateViewControllerWithIdentifier:@"ExportSettingsViewController"];
    
    [self showViewController:exportDataPage sender:nil];
}

- (IBAction)alarmListButtonPressed:(UIButton *)sender {
    // goto next page AlarmTableViewController
//    AlarmTableViewController *alarmListPage = [self.storyboard instantiateViewControllerWithIdentifier:@"AlarmTableViewController"];
    
    AlarmTableViewController *alarmListPage = [self.storyboard instantiateViewControllerWithIdentifier:@"AlarmListViewController"];
    
    [self showViewController:alarmListPage sender:nil];
}

- (IBAction)configSettingButtonPressed:(UIButton *)sender {
    // goto next page ConfigTableViewController
    ConfigTableViewController *configSettingPage = [self.storyboard instantiateViewControllerWithIdentifier:@"ConfigTableViewController"];
    
    [self showViewController:configSettingPage sender:nil];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    if(fromInterfaceOrientation == UIDeviceOrientationLandscapeRight || fromInterfaceOrientation == UIDeviceOrientationLandscapeLeft) {
        isOrientationLandscape = false;
    } else {
        isOrientationLandscape = true;
    }
    [self setButtonPosition];
}

- (void) setButtonPosition {
    
    if(isOrientationLandscape == false) {
        UIImage *image = [UIImage imageNamed:@"iphone.png"];
        _mainImageView.image = image;
        
        CGRect frame = CGRectMake(self.view.bounds.size.width*41/375, self.view.bounds.size.height*198/667, 100, 100);
        _btnCharting.frame = frame;
        
        frame = CGRectMake(self.view.bounds.size.width*240/375, self.view.bounds.size.height*188/667, 100, 100);
        _btnExport.frame = frame;
        
        frame = CGRectMake(self.view.bounds.size.width*41/375, self.view.bounds.size.height*458/667, 100, 100);
        _btnAlarm.frame = frame;
        
        frame = CGRectMake(self.view.bounds.size.width*240/375, self.view.bounds.size.height*458/667, 100, 100);
        _btnSetting.frame = frame;
    } else {
        UIImage *image = [UIImage imageNamed:@"iphone-.png"];
        _mainImageView.image = image;
        
        CGRect frame = CGRectMake(self.view.bounds.size.width*169/736, self.view.bounds.size.height*108/414, 100, 100);
        _btnCharting.frame = frame;
        
        frame = CGRectMake(self.view.bounds.size.width*464/736, self.view.bounds.size.height*98/414, 100, 100);
        _btnExport.frame = frame;
        
        frame = CGRectMake(self.view.bounds.size.width*169/736, self.view.bounds.size.height*242/414, 100, 100);
        _btnAlarm.frame = frame;
        
        frame = CGRectMake(self.view.bounds.size.width*464/736, self.view.bounds.size.height*242/414, 100, 100);
        _btnSetting.frame = frame;
    }
}

@end
