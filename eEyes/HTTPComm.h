//
//  HTTP.h
//  eEyes
//
//  Created by Nap Chen on 2017/1/10.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DoneHandler)(NSData *data, NSURLResponse *response, NSError *error);

@interface HTTPComm : NSObject

+ (instancetype) sharedInstance;

- (void) sendHTTPGet:(NSURL*) url completion:(DoneHandler) doneHandler;
- (void) sendHTTPPost:(NSURL*)url timeout:(NSTimeInterval)timeout sensorID:(NSString*)sensorID startDate:(NSString*)startDate endDate:(NSString*)endDate functionType:(NSString*)functionType completion:(DoneHandler)doneHandler;
@end
