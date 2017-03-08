//
//  ExportTableViewController.m
//  eEyes
//
//  Created by Nap Chen on 2017/1/10.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "ExportTableViewController.h"


@interface ExportTableViewController ()<MFMailComposeViewControllerDelegate>
{
    ExportCSVFile *exportCSVFile;
    NSMutableArray *fileList;
    MFMailComposeViewController *mailComposer;
}

@end

@implementation ExportTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    fileList = [NSMutableArray new];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
     exportCSVFile = [ExportCSVFile sharedInstance];
    //[exportCSVFile prepareDataForGenerateCSV:@"1" startDate:@"2017-01-25 21:46:04" endDate:@"2017-01-25 21:48:10"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSLog(@"%@",paths);
    // Create NSString object, that holds our exact path to the documents directory
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //NSLog(@"%@",documentsDirectory);
    NSArray *pathContent = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:documentsDirectory error:nil];
    //NSLog(@"%@",pathContent);
    for (NSString *fileName in pathContent){
        if([fileName containsString:@".csv"]){
            [fileList addObject:fileName];
        }
    }
    //NSLog(@"fileList:  %@",fileList);
    
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
    return fileList.count;
}


 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExportCell" forIndexPath:indexPath];
 // Configure the cell...
     cell.textLabel.text = fileList[indexPath.row];
     //NSLog(@"%@",cell.textLabel.text);
 return cell;
 }


#pragma mark - tableviewRowAction
-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *sendEmail = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Email" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        // maybe show an action sheet with more options
        NSString *fileName = fileList[indexPath.row];
        [self sendEmailWithAttachment:fileName];
    }];
    sendEmail.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0.8 alpha:1];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        // Delete the row from the data source
        NSString *fileName = fileList[indexPath.row];
        NSLog(@"%@",fileName);
        [self deleteFile:fileName];
        [fileList removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
        
        //[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];


    return @[deleteAction, sendEmail];
}
-(void) sendEmailWithAttachment:(NSString*)fileName{
    if (![MFMailComposeViewController canSendMail]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"不支援信件或未設定信件" message:@"此裝置不支援信件或未設定信件" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        NSLog(@"Mail services are not available.");
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    MFMailComposeViewController* composeVC = [[MFMailComposeViewController alloc] init];
    composeVC.mailComposeDelegate = self;
    
    // Load attachment
    // Find the path of file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", fileName]];
    NSData *csvData = [NSData dataWithContentsOfFile:fullPath];
    
    // Configure the fields of the interface.
    [composeVC setToRecipients:@[@"denny80226@gmail.com"]];
    [composeVC setSubject:@"My Sensor Record CSV File"];
    [composeVC setMessageBody:@"Here is your file!" isHTML:NO];
    [composeVC addAttachmentData:csvData
                        mimeType:@"text/csv"
                        fileName:[NSString stringWithFormat:@"%@",fileName]];
    // Present the view controller modally.
    [self presentViewController:composeVC animated:YES completion:nil];


}
#pragma mark - dismissMailViewController
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    // Check the result or perform other tasks.
    
    // Dismiss the mail compose view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
}




- (void)deleteFile:(NSString*)fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Create NSString object, that holds our exact path to the documents directory
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", fileName]];
    //NSLog(@"%@",fullPath);
    BOOL result = [[NSFileManager defaultManager]removeItemAtPath:fullPath error:nil];
    NSLog(@"Delete:%d",result);
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *fileName = fileList[indexPath.row];
    NSLog(@"%@",fileName);
    exportCSVFile.fileNameSelected = fileName;
    DrawCSVFileViewController *drawFileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DrawCSVFileViewController"];
    [self showViewController:drawFileVC sender:nil];



}



/*
#pragma mark - delete files
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSString *fileName = fileList[indexPath.row];
        NSLog(@"%@",fileName);
        [self deleteFile:fileName];
        [fileList removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
 
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
