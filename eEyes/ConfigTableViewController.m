//
//  ConfigTableViewController.m
//  eEyes
//
//  Created by Nap Chen on 2017/1/10.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "ConfigTableViewController.h"
#import "AllSensors.h"
#import "Sensor.h"
#import "ConfigManager.h"
#import "ConfigTableViewCell.h"

@interface ConfigTableViewController ()

@end

@implementation ConfigTableViewController
{
    ConfigManager *config;
    
    NSArray *allConfigKeys;
    
    NSDictionary *allConfigData;
    NSDictionary *allConfigText;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    config = [ConfigManager sharedInstance];
    
    allConfigData = [config getConfigDictionary];
    allConfigText = [config getConfigText];
    allConfigKeys = [config getConfigKeys];
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [config getAllConfig];
    [config savePlist];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return allConfigKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

//    allConfigKeys = allConfigText.allKeys;
//    NSArray *sortedArray = [allConfigKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
//        return [obj1 compare:obj2 options:NSNumericSearch];
//    }];//由于allKeys返回的是无序数组，这里我们要排列它们的顺序
    return 1;
    
    
//    NSArray *allKeys = allItems.allKeys;
//    NSString *uuidKey = allKeys[indexPath.row];
//    PeripheralItem *item = allItems[uuidKey];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *key = allConfigKeys[section];
//    NSString *str = [allConfigText objectForKey:key];
    
    return [allConfigText objectForKey:key];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    ConfigTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    NSString *key = allConfigKeys[indexPath.section];
    cell.configTextField.text = [allConfigData objectForKey:key];
    
    if ([key containsString:@"Password"]) {
//    if ([key isEqualToString: @"dbPassword"] || [key isEqualToString: @"appPassword"]) {
        cell.configTextField.secureTextEntry = true;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ConfigTableViewCell *customCell = (ConfigTableViewCell *)cell;
    
    NSString *key = allConfigKeys[indexPath.section];
                    
    customCell.block = ^(NSString *text){
                        [config setValueByKey:key value:text];
                    };
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
