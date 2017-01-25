//
//  DrawChartTableViewController.m
//  eEyes
//
//  Created by Nap Chen on 2017/1/11.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "DrawChartTableViewController.h"
#import "RealtimeChartViewController.h"
#import "HistoryChartViewController.h"

@interface DrawChartTableViewController ()

@end

@implementation DrawChartTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // put on edit button
//    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editBtnPressed:)];
//    self.navigationItem.rightBarButtonItems = @[addItem];
}

// if press edit tab bar button
- (void)editBtnPressed:(UIBarButtonItem *)sender {
    
    // go to MyFriendsTableViewController fir friends' list of tableView
//    RealtimeChartViewController *realChartPage = [self.storyboard instantiateViewControllerWithIdentifier:@"RealtimeChartViewController"];
//    [self showViewController:realChartPage sender:nil];
    
//    HistoryChartViewController *historyChartPage = [self.storyboard instantiateViewControllerWithIdentifier:@"HistoryChartViewController"];
//        [self showViewController:historyChartPage sender:nil];
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

    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if(indexPath.row == 0) {
        cell.textLabel.text = @"即時曲線";
    } else {
        cell.textLabel.text = @"歷史曲線";
    }
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0) {
        RealtimeChartViewController *realChartPage = [self.storyboard instantiateViewControllerWithIdentifier:@"RealtimeChartViewController"];
        [self showViewController:realChartPage sender:nil];
    } else {
        HistoryChartViewController *historyChartPage = [self.storyboard instantiateViewControllerWithIdentifier:@"HistoryChartViewController"];
        [self showViewController:historyChartPage sender:nil];
    }
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
