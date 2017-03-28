//
//  AlarmTableViewController.m
//  eEyes
//
//  Created by Nap Chen on 2017/1/10.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "AlarmTableViewController.h"
#import "HTTPComm.h"
#import "RegularAction.h"
#import "AlarmTableViewCell.h"
#import "Sensor.h"

@interface AlarmTableViewController ()
{
    AllSensors *allSensors;
    HTTPComm *httpComm;
    ConfigManager *config;
    
    NSMutableArray *allSensorsInfo;
    
    NSInteger sensorIndex;
    NSString *SensorIDStr;
    
    BOOL isGetDBInfo;
}

@end

@implementation AlarmTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    allSensors = [AllSensors sharedInstance];
    
    allSensorsInfo = [NSMutableArray new];
    allSensorsInfo = [allSensors getAllSensorsInfoMutable];
    
    httpComm = [HTTPComm sharedInstance];
    config = [ConfigManager sharedInstance];
    
    [config initialConfigPlist];
    [config getAllConfig];
    
    self.tableView.rowHeight = 66;
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

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return allSensorsInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    // use custom table view cell
    AlarmTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // get alarm element
    Sensor *sensor = allSensorsInfo[indexPath.row];
    
    // set cell data
    cell.sensorNameLabel.text = [self getSensorNameByID:sensor.sensorID];
    cell.sensorAlarmValueLabel.text = [NSString stringWithFormat:@"%.1f", sensor.hiAlarm];
    cell.sensorAlarmTypeLabel.text = [NSString stringWithFormat:@"%.1f", sensor.loAlarm];

    return cell;
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Sensor *sensor = allSensorsInfo[indexPath.row];
    
    sensorIndex = indexPath.row;
    SensorIDStr = [sensor.sensorID stringValue];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:sensor.name message:@"請輸入高低警報值" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull hiAlarmTextField) {
        hiAlarmTextField.text = [NSString stringWithFormat:@"%.1f", sensor.hiAlarm];
        [hiAlarmTextField setKeyboardType:UIKeyboardTypeDecimalPad];
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull loAlarmTextField) {
        loAlarmTextField.text = [NSString stringWithFormat:@"%.1f", sensor.loAlarm];
        [loAlarmTextField setKeyboardType:UIKeyboardTypeDecimalPad];
    }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    UIAlertAction* confirm = [UIAlertAction actionWithTitle:@"確認" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        // get input string
        UITextField* hiAlarmTextField = alert.textFields[0];
        UITextField* loAlarmTextField = alert.textFields[1];
        
        NSString *hiAlarmStr = hiAlarmTextField.text;
        NSString *loAlarmStr = loAlarmTextField.text;
        
        NSLog(@"id : %@, hi：%@, lo：%@", SensorIDStr, hiAlarmStr, loAlarmStr);
        
        // update AllSensors singleton
        Sensor *sensor = allSensorsInfo[sensorIndex];
        sensor.hiAlarm = [hiAlarmStr doubleValue];
        sensor.loAlarm = [loAlarmStr doubleValue];
        allSensorsInfo[sensorIndex] = sensor;
        
        // update table view
        [tableView reloadData];
        
        // write hi lo alarm to DB
        NSURL *url = [[NSURL alloc] initWithString:config.dbInfoAddress];
        
        isGetDBInfo = false;
        
        NSString *insertData = [NSString stringWithFormat:@"{\"sensorID\":%@,\"hiAlarm\":%@,\"loAlarm\":%@}", SensorIDStr, hiAlarmStr, loAlarmStr];
        
        NSLog(@"url : %@", insertData);
        
        [httpComm sendHTTPPost:url timeout:1 dbTable:nil sensorID:@"1" startDate:config.startDate endDate:config.endDate insertData:insertData functionType:@"setHiLoAlarm" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            if (error) {
                NSLog(@"!!! getAlarmStatus ERROR !!!");
                NSLog(@"HTTP getAlarmStatus Faile : %@", error.localizedDescription);
                [self popoutWarningMessage:@"網路傳輸失敗！"];
            }
            
            isGetDBInfo = true;
        }];
        
        while (!isGetDBInfo) {
        }
    }];
    
    // 將按鍵加到警告視窗上
    [alert addAction:cancel];
    [alert addAction:confirm];
    
    // 顯示警告視窗
    [self presentViewController:alert animated:YES completion:nil];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
