//
//  ExportTableViewController.h
//  eEyes
//
//  Created by Nap Chen on 2017/1/10.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExportCSVFile.h"


@interface ExportTableViewController : UITableViewController
{
    ExportCSVFile *exportCSVFile;
    NSMutableArray *fileList;
}
@end
