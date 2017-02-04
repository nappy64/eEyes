//
//  ExportTableViewController.h
//  eEyes
//
//  Created by Nap Chen on 2017/1/10.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPComm.h"
#import "ExportCSVFile.h"
#import "ConfigManager.h"
#import "XMLParserDelegate.h"


@interface ExportTableViewController : UITableViewController
{
    ConfigManager *config;
    HTTPComm *httpComm;
    ExportCSVFile *exportCSVFile;
    NSMutableArray *objects;
    NSMutableArray *values;
    NSMutableArray *date;
}

@end
