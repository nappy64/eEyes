//
//  AlarmListViewController.m
//  eEyes
//
//  Created by Nap Chen on 2017/3/28.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "AlarmListViewController.h"
#import "HTTPComm.h"
#import "RegularAction.h"
#import "AlarmTableViewCell.h"
#import "AlarmTableViewController.h"

@interface AlarmListViewController () <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *btnAlarmCheckingEnable;
@property (weak, nonatomic) IBOutlet UIButton *btnAlarmCheckingDisable;
@property (weak, nonatomic) IBOutlet UIButton *btnAlarmStatus;
@property (weak, nonatomic) IBOutlet UITableView *alarmListTableView;

@end

@implementation AlarmListViewController
{
    AllSensors *allSensors;
    HTTPComm *httpComm;
    ConfigManager *config;
    
    NSArray *allSensorsInfo;
    
    NSMutableArray *allAlarmsInfo;
    
    BOOL isGetDBInfo, isNowAlarm, isAlarmChecking;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    allSensors = [AllSensors sharedInstance];
    allSensorsInfo = [allSensors getAllSensorsInfo];
    
    httpComm = [HTTPComm sharedInstance];
    config = [ConfigManager sharedInstance];
    
    [config initialConfigPlist];
    //    [config resetAllConfig];
    [config getAllConfig];
    
    isNowAlarm = false;
    isAlarmChecking = false;
    
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(pressEditButtonToCreateInputContent:)];
    
    // 放上導覽列
    self.navigationItem.rightBarButtonItems = @[editItem];
    
    // get current alarm status
    NSURL *url = [[NSURL alloc] initWithString:config.dbInfoAddress];
    
    isGetDBInfo = false;
    
    [httpComm sendHTTPPost:url timeout:1 dbTable:nil sensorID:@"1" startDate:config.startDate endDate:config.endDate insertData:nil functionType:@"getAlarmStatus" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"!!! getAlarmStatus ERROR !!!");
            NSLog(@"HTTP getAlarmStatus Faile : %@", error.localizedDescription);
            [self popoutWarningMessage:@"網路傳輸失敗！"];
            isGetDBInfo = true;
        }else {
            
            NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"JSON : %@", jsonString);
            
            NSMutableDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
            
            if([jsonData[@"alarm"] isEqualToString:@"true"]) {
                isNowAlarm = true;
            }
            
            isGetDBInfo = true;
        }
    }];
    
    while (!isGetDBInfo) {
    }
    
    if(isNowAlarm) {
        NSLog(@"alarm...");
        _btnAlarmStatus.backgroundColor = [UIColor redColor];
        [_btnAlarmStatus setTitle:@"Alarm!" forState:UIControlStateNormal];
    } else {
        NSLog(@"no alarm...");
        _btnAlarmStatus.backgroundColor = [UIColor greenColor];
        [_btnAlarmStatus setTitle:@"NORMAL!" forState:UIControlStateNormal];
    }
    
    // get checking alarm status
    url = [[NSURL alloc] initWithString:config.dbInfoAddress];
    
    isGetDBInfo = false;
    
    [httpComm sendHTTPPost:url timeout:1 dbTable:nil sensorID:@"1" startDate:config.startDate endDate:config.endDate insertData:nil functionType:@"getCheckingAlarmStatus" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"!!! getCheckingAlarmStatus ERROR !!!");
            NSLog(@"HTTP getCheckingAlarmStatus Faile : %@", error.localizedDescription);
            [self popoutWarningMessage:@"網路傳輸失敗！"];
            isGetDBInfo = true;
        }else {
            
            NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"JSON : %@", jsonString);
            
            NSMutableDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
            
            if([jsonData[@"alarm"] isEqualToString:@"true"]) {
                isAlarmChecking = true;
            }
            
            isGetDBInfo = true;
        }
    }];
    
    while (!isGetDBInfo) {
    }
    
    if(isAlarmChecking) {
        NSLog(@"checking alarm...");
        _btnAlarmCheckingEnable.backgroundColor = [UIColor yellowColor];
        _btnAlarmCheckingDisable.backgroundColor = [UIColor grayColor];
    } else {
        NSLog(@"no checking alarm...");
        _btnAlarmCheckingEnable.backgroundColor = [UIColor grayColor];
        _btnAlarmCheckingDisable.backgroundColor = [UIColor yellowColor];
    }
    
    // get all alarm list
    url = [[NSURL alloc] initWithString:config.dbAlarmAddress];
    
    _alarmListTableView.rowHeight = 88;
    
    isGetDBInfo = false;
    
    [httpComm sendHTTPPost:url timeout:1 dbTable:nil sensorID:@"1" startDate:config.startDate endDate:config.endDate insertData:nil functionType:@"getAlarmByUser" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"!!! ERROR1 !!!");
            NSLog(@"HTTP Get Alarm Info. Faile : %@", error.localizedDescription);
            [self popoutWarningMessage:@"網路傳輸失敗！"];
            isGetDBInfo = true;
        }else {
            
            NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"JSON : %@", jsonString);
            
            NSMutableDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
            
            NSString *result = jsonData[@"result"];
            
            if([result isEqualToString: @"true"]) {
                
                allAlarmsInfo = [NSMutableArray new];
                NSMutableArray *allAlarms = jsonData[@"alarms"];
                
                for (int i = 0; i < (int)allAlarms.count; i++) {
                    
                    // get a alarm element
                    NSMutableDictionary *sensorInfo = jsonData[@"alarms"][i];
                    
                    // save to a Sensor object
                    Sensor *currentSensor = [Sensor new];
                    
                    currentSensor.sensorID = sensorInfo[@"sensorID"];
                    currentSensor.date = sensorInfo[@"date"];
                    
                    currentSensor.alarmValue = [sensorInfo[@"alarmValue"] floatValue];
                    currentSensor.alarmType = sensorInfo[@"alarmType"];
                    
                    // save a alarm element
                    [allAlarmsInfo addObject:currentSensor];
                }
            } else {
                NSString *errString = jsonData[@"errorCode"];
                [self popoutWarningMessage:errString];
            }
            
            isGetDBInfo = true;
        }
    }];
    
    while (!isGetDBInfo) {
    }
}

- (void)pressEditButtonToCreateInputContent:(UIBarButtonItem *)sender {
    
    AlarmTableViewController *realChartPage = [self.storyboard instantiateViewControllerWithIdentifier:@"AlarmTableViewController"];
    [self showViewController:realChartPage sender:nil];
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

- (IBAction)alarmEnableEnablePressed:(UIButton *)sender {
    
    NSURL *url = [[NSURL alloc] initWithString:@"http://192.168.43.119/SendAllAlarm/checkAlarmGet.php?username=root&password=root&database=eEyes&appUserName=user&type=checkAlarm&sec=1"];
    
    isGetDBInfo = false;
    
    [httpComm sendHTTPGet:url completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"!!! checkAlarm ERROR !!!");
            NSLog(@"HTTP checkAlarm Faile : %@", error.localizedDescription);
            [self popoutWarningMessage:@"網路傳輸失敗！"];
        }
    }];

    isAlarmChecking = true;
    
    NSLog(@"~checking alarm...");
    _btnAlarmCheckingEnable.backgroundColor = [UIColor yellowColor];
    _btnAlarmCheckingDisable.backgroundColor = [UIColor grayColor];
}

- (IBAction)alarmDisableEnablePressed:(UIButton *)sender {
    
    // get current alarm status
    NSURL *url = [[NSURL alloc] initWithString:config.dbInfoAddress];
    
    isGetDBInfo = false;
    
    [httpComm sendHTTPPost:url timeout:1 dbTable:nil sensorID:@"1" startDate:config.startDate endDate:config.endDate insertData:nil functionType:@"stopAlarmChecking" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"!!! stopAlarmChecking ERROR !!!");
            NSLog(@"HTTP stopAlarmChecking Faile : %@", error.localizedDescription);
            [self popoutWarningMessage:@"網路傳輸失敗！"];
            isGetDBInfo = true;
        }else {
            isGetDBInfo = true;
        }
    }];
    
    while (!isGetDBInfo) {
    }
    
    isAlarmChecking = false;
    
    NSLog(@"no checking alarm...");
    _btnAlarmCheckingEnable.backgroundColor = [UIColor grayColor];
    _btnAlarmCheckingDisable.backgroundColor = [UIColor yellowColor];

}

- (IBAction)alarmStatusConfirmPressed:(UIButton *)sender {
    
    // get current alarm status
    NSURL *url = [[NSURL alloc] initWithString:config.dbInfoAddress];
    
    isGetDBInfo = false;
    
    [httpComm sendHTTPPost:url timeout:1 dbTable:nil sensorID:@"1" startDate:config.startDate endDate:config.endDate insertData:nil functionType:@"clearAlarmStatus" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"!!! clearAlarmStatus ERROR !!!");
            NSLog(@"HTTP clearAlarmStatus Faile : %@", error.localizedDescription);
            [self popoutWarningMessage:@"網路傳輸失敗！"];
            isGetDBInfo = true;
        }else {
            isGetDBInfo = true;
        }
    }];
    
    while (!isGetDBInfo) {
    }
    
    isNowAlarm = false;
    
    if(isNowAlarm) {
        NSLog(@"alarm...");
        _btnAlarmStatus.backgroundColor = [UIColor redColor];
        [_btnAlarmStatus setTitle:@"Alarm!" forState:UIControlStateNormal];
    } else {
        NSLog(@"no alarm...");
        _btnAlarmStatus.backgroundColor = [UIColor greenColor];
        [_btnAlarmStatus setTitle:@"NORMAL!" forState:UIControlStateNormal];
    }
}

- (NSString*) getSensorNameByID:(NSNumber*)sensorID {
    
    NSString *sensorName = @"";
    
    for (Sensor *sensor in allSensorsInfo) {
        if(sensor.sensorID == sensorID) {
            sensorName = sensor.name;
        }
    }
    
    return sensorName;
}

#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return allAlarmsInfo.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // use custom table view cell
    AlarmTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // get alarm element
    Sensor *alarm = allAlarmsInfo[indexPath.row];
    
    // set cell data
    cell.sensorNameLabel.text = [self getSensorNameByID:alarm.sensorID];
    cell.sensorAlarmValueLabel.text = [NSString stringWithFormat:@"%.1f", alarm.alarmValue];
    cell.sensorAlarmDateLabel.text = alarm.date;
    cell.sensorAlarmTypeLabel.text = alarm.alarmType;
    
//    [cell.sensorAlarmDateLabel setHidden:true];
    return cell;
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
