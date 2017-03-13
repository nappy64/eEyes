//
//  HTTP.h
//  eEyes
//
//  Created by Nap Chen on 2017/1/10.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DoneHandler)(NSData *data, NSURLResponse *response, NSError *error);

@interface HTTPComm : NSObject<NSURLSessionDelegate,NSURLSessionTaskDelegate>
@property(nonatomic,strong)NSURLSession *uploadAverageSession;
@property(nonatomic,strong)NSURLSessionUploadTask *uploadTask;
@property(nonatomic,strong)NSMutableURLRequest *mutableRequest;
+ (instancetype) sharedInstance;

- (void) sendHTTPGet:(NSURL*) url completion:(DoneHandler) doneHandler;
- (void) sendHTTPPost:(NSURL*)url timeout:(NSTimeInterval)timeout dbTable:(NSString*)dbTable sensorID:(NSString*)sensorID startDate:(NSString*)startDate endDate:(NSString*)endDate insertData:(NSString*)insertData functionType:(NSString*)functionType completion:(DoneHandler)doneHandler;

- (void)uploadAverageToServer:(NSURL*)url
                      timeout:(NSTimeInterval)timeout
                   insertData:(NSString*)insertData
                   identifier:(NSString*)identifier
                 functionType:(NSString*)functionType;

@end
