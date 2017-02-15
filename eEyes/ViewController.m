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

@end

@implementation ViewController
{
    HTTPComm *httpComm;
    ConfigManager *config;
    AllSensors *allSensors;
    
//    BOOL isGetDBInfo;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
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
    
//    isGetDBInfo = false;
    
    [httpComm sendHTTPPost:url timeout:1 dbTable:nil sensorID:@"1" startDate:config.startDate endDate:config.endDate insertData:nil functionType:@"getSensorByUser" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"!!! ERROR1 !!!");
            NSLog(@"HTTP Get Sensor Info. Faile : %@", error.localizedDescription);
        }else {
            
            NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"JSON : %@", jsonString);
            
            NSMutableDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
            
            [allSensors transferJSONToSensorsInfo:dataDictionary];
            
//            isGetDBInfo = true;
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
    AlarmTableViewController *alarmListPage = [self.storyboard instantiateViewControllerWithIdentifier:@"AlarmTableViewController"];
    
    [self showViewController:alarmListPage sender:nil];
}

- (IBAction)configSettingButtonPressed:(UIButton *)sender {
    // goto next page ConfigTableViewController
    ConfigTableViewController *configSettingPage = [self.storyboard instantiateViewControllerWithIdentifier:@"ConfigTableViewController"];
    
    [self showViewController:configSettingPage sender:nil];
}

@end
