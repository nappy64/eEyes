//
//  Config.h
//  eEyes
//
//  Created by Nap Chen on 2017/1/10.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfigManager : NSObject

@property NSString *dbMainAddress;          // 00 DB Main Address
@property NSString *dbRegisterAddress;      // 01 DB Register Address
@property NSString *dbUserName;             // 02 DB Username
@property NSNumber *dbPassword;             // 03 DB Password
@property NSNumber *dbName;                 // 04 DB Name
@property NSNumber *dbTable;                // 05 DB Table
@property NSNumber *dbField;                // 06 DB Field
//@property NSDate *startDate;                // 07 Start Date
//@property NSDate *endDate;                  // 08 End Date
@property NSString *startDate;                // 07 Start Date
@property NSString *endDate;                  // 08 End Date


+ (instancetype) sharedInstance;

- (void) initialConfigPlist;
- (void) resetAllConfig;
- (void) getAllConfig;
- (void) setAllConfig;
- (NSDictionary*) getConfigDictionary;

@end
