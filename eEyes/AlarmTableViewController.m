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

@interface AlarmTableViewController ()
{
    AllSensors *allSensors;
    HTTPComm *httpComm;
    ConfigManager *config;
    
    NSArray *allSensorsInfo;
    
    NSMutableArray *allAlarmsInfo;
    
    BOOL isGetDBInfo;
}

@end

@implementation AlarmTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
<<<<<<< HEAD

    allSensors = [AllSensors sharedInstance];
    allSensorsInfo = [allSensors getAllSensorsInfo];
    
    httpComm = [HTTPComm sharedInstance];
    config = [ConfigManager sharedInstance];
    
    [config initialConfigPlist];
    //    [config resetAllConfig];
    [config getAllConfig];
    
    NSURL *url = [[NSURL alloc] initWithString:config.dbAlarmAddress];
    
    self.tableView.rowHeight = 88;

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

- (void) popoutWarningMessage:(NSString*)message {
    
    // alert title
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"注意" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    // confirm button
    UIAlertAction* confirm = [UIAlertAction actionWithTitle:@"確認" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:confirm];
    
    [self presentViewController:alert animated:YES completion:nil];
=======
    ra= [RegularAction sharedInstance];
    [ra getTheTimeOfTheLastAverage:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"here:%@",result);
    }];
   
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
>>>>>>> 3ca030c15e80467b2723038f44fd85332274e1fa
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

    return allAlarmsInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    // use custom table view cell
    AlarmTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // get alarm element
    Sensor *alarm = allAlarmsInfo[indexPath.row];
    
    // set cell data
    cell.sensorNameLabel.text = [self getSensorNameByID:alarm.sensorID];
    cell.sensorAlarmValueLabel.text = [NSString stringWithFormat:@"%.1f", alarm.alarmValue];
    cell.sensorAlarmDateLabel.text = alarm.date;
    cell.sensorAlarmTypeLabel.text = alarm.alarmType;
    
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
