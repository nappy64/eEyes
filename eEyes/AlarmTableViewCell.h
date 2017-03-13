//
//  AlarmTableViewCell.h
//  eEyes
//
//  Created by Nap Chen on 2017/3/11.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlarmTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *sensorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sensorAlarmValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *sensorAlarmDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *sensorAlarmTypeLabel;

@end
