//
//  ExportTableViewController.m
//  eEyes
//
//  Created by Nap Chen on 2017/1/10.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "ExportTableViewController.h"


@interface ExportTableViewController ()

@end

@implementation ExportTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    httpComm = [HTTPComm sharedInstance];
    NSURL *url = [[NSURL alloc] initWithString:@"http://127.0.0.1/dbSensorValue.php"];
    
    [httpComm sendHTTPPost:url timeout:1 sensorID:@"1" startDate:@"2017-01-25 21:46:04" endDate:@"2017-01-25 21:48:08" functionType:@"getRange" completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        
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
                        //...
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExportCell" forIndexPath:indexPath];
 
 // Configure the cell...
 
 
 return cell;
 }
 */

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
