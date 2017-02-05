//
//  ExportSettingsViewController.h
//  eEyes
//
//  Created by Denny on 2017/2/4.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConfigManager.h"
#import "Sensor.h"
#import "AllSensors.h"
#import "ExportCSVFile.h"
#import "ExportTableViewController.h"

@interface ExportSettingsViewController : UIViewController
{
    ExportCSVFile *exportCSV;
    ConfigManager *config;
    NSArray *allSensorsInfo;
    AllSensors *allSensors;
    BOOL isDisplayRealChart;
    NSMutableArray *sensorsButton;
    UITextField *startDateTextField;
    UITextField *endDateTextField;

}
@end
