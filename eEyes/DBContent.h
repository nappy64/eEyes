//
//  DBContent.h
//  eEyes
//
//  Created by Nap Chen on 2017/1/25.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBContent : NSObject

+ (instancetype) sharedInstance;

-(void) getDBContent;
-(NSArray*) getSensorListByUser:(NSString*)username;

@end
