//
//  Config.m
//  eEyes
//
//  Created by Nap Chen on 2017/1/10.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "ConfigManager.h"

@implementation ConfigManager
{
    NSMutableDictionary *allConfigDictionary;
}

static ConfigManager *_singletonConfigManager = nil;

+ (instancetype) sharedInstance {
    
    if(_singletonConfigManager == nil){
        _singletonConfigManager = [ConfigManager new];
    }
    return _singletonConfigManager;
}

- (void) initialConfigPlist {
    
    // load file Config.plist
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"Config.plist"];
    
    // create if no Config.plist existed
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath])
    {
        plistPath = [[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"];
    }
    
    // transfer plist to dictionary
    allConfigDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
}

- (void) resetAllConfig{
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Setting" ofType:@"plist"];
    allConfigDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    [self getAllConfig];
}

- (void) getAllConfig {
    
    _dbMainAddress = [allConfigDictionary objectForKey:@"dbMainAddress"];
    _dbRegisterAddress = [allConfigDictionary objectForKey:@"dbRegisterAddress"];
    _dbUserName = [allConfigDictionary objectForKey:@"dbUserName"];
    _dbPassword = [allConfigDictionary objectForKey:@"dbPassword"];
    _dbName = [allConfigDictionary objectForKey:@"dbName"];
    _dbTable = [allConfigDictionary objectForKey:@"dbTable"];
    _dbField = [allConfigDictionary objectForKey:@"dbField"];
    _startDate = [allConfigDictionary objectForKey:@"startDate"];
    _endDate = [allConfigDictionary objectForKey:@"endDate"];
}

- (void) setAllConfig {
    
    [allConfigDictionary setObject:_dbMainAddress forKey:@"dbMainAddress"];
    [allConfigDictionary setObject:_dbRegisterAddress forKey:@"dbRegisterAddress"];
    [allConfigDictionary setObject:_dbUserName forKey:@"dbUserName"];
    [allConfigDictionary setObject:_dbPassword forKey:@"dbPassword"];
    [allConfigDictionary setObject:_dbName forKey:@"dbName"];
    [allConfigDictionary setObject:_dbTable forKey:@"dbTable"];
    [allConfigDictionary setObject:_dbField forKey:@"dbField"];
    [allConfigDictionary setObject:_startDate forKey:@"startDate"];
    [allConfigDictionary setObject:_endDate forKey:@"endDate"];
    
    // save file Setting.plist
    NSString *SaveRootPath = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    NSString *SavePath = [SaveRootPath stringByAppendingPathComponent:@"Config.plist"];
    
    [allConfigDictionary writeToFile:SavePath atomically:YES];
}

- (NSDictionary*) getConfigDictionary {
    
    return allConfigDictionary;
}

@end
