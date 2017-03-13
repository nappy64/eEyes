//
//  ConfigTableViewCell.h
//  eEyes
//
//  Created by Nap Chen on 2017/3/11.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfigTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *configTextField;
@property (copy, nonatomic) void(^block)(NSString *);

@end
