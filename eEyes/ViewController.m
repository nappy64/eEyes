//
//  ViewController.m
//  eEyes
//
//  Created by Nap Chen on 2017/1/10.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "ViewController.h"
#import "DrawChartTableViewController.h"
#import "ExportTableViewController.h"
#import "AlarmTableViewController.h"
#import "ConfigTableViewController.h"
#import "ConfigManager.h"
#import "HTTPComm.h"

@interface ViewController ()

@end

@implementation ViewController
{
    HTTPComm *httpComm;
    ConfigManager *config;
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
    [config initialConfigPlist];
//    [config resetAllConfig];
    [config getAllConfig];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)drawChartButtonPressed:(UIButton *)sender {
    // goto next page DrawChartTableViewController
    DrawChartTableViewController *drawChartPage = [self.storyboard instantiateViewControllerWithIdentifier:@"DrawChartTableViewController"];
    
    [self showViewController:drawChartPage sender:nil];
}

- (IBAction)exportDataButtonPressed:(UIButton *)sender {
    // goto next page ExportTableViewController
    ExportTableViewController *exportDataPage = [self.storyboard instantiateViewControllerWithIdentifier:@"ExportTableViewController"];
    
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
