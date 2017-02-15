//
//  HTTP.m
//  eEyes
//
//  Created by Nap Chen on 2017/1/10.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "HTTPComm.h"
#import "ConfigManager.h"
#import "Sensor.h"

@implementation HTTPComm

static HTTPComm *_singletonHTTPComm = nil;

+ (instancetype) sharedInstance {
    
    if(_singletonHTTPComm == nil){
        _singletonHTTPComm = [HTTPComm new];
    }
    return _singletonHTTPComm;
}

- (void) sendHTTPGet:(NSURL*) url completion:(DoneHandler) doneHandler{
    
    NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask *task= [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        doneHandler(data, response, error);
    }];
    
    [task resume];
}

- (void) sendHTTPPost:(NSURL*)url timeout:(NSTimeInterval)timeout dbTable:(NSString*)dbTable sensorID:(NSString*)sensorID startDate:(NSString*)startDate endDate:(NSString*)endDate insertData:(NSString*)insertData functionType:(NSString*)functionType completion:(DoneHandler)doneHandler {
    
    // initial ConfigManager singleton
    ConfigManager *config = [ConfigManager sharedInstance];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.timeoutInterval = timeout;
    request.HTTPMethod = @"POST";
    
    NSDictionary *parametersDict;
    
    if([functionType isEqualToString:@"getNew"]) {
        parametersDict = @{@"username":config.dbUserName, @"password":config.dbPassword, @"database":config.dbName, @"table":dbTable, @"field":@"RealValue", @"sensorID":sensorID, @"datefield":@"Date", @"startdate":startDate, @"enddate":endDate, @"type":functionType};
    } else if([functionType isEqualToString:@"getRange"]) {
        parametersDict = @{@"username":config.dbUserName, @"password":config.dbPassword, @"database":config.dbName, @"table":@"SensorRawData", @"field":@"RawValue", @"sensorID":sensorID, @"datefield":@"StartDate", @"startdate":startDate, @"enddate":endDate, @"type":functionType};
    } else if([functionType isEqualToString:@"getSensorByUser"]) {
        parametersDict = @{@"username":config.dbUserName, @"password":config.dbPassword, @"database":config.dbName,@"appUserName":config.appUserName, @"appPassword":config.appPassword, @"type":functionType};
    } else if([functionType isEqualToString:@"insert"]) {
        parametersDict = @{@"username":config.dbUserName, @"password":config.dbPassword, @"database":config.dbName, @"table":dbTable, @"field":@"Value", @"datefield":@"Date", @"insertdate":startDate, @"insertdata":insertData, @"type":functionType};
    }
    
    NSMutableString *parameterString = [NSMutableString string];
    
    for (NSString *key in parametersDict.allKeys) {
        
        [parameterString appendFormat:@"%@=%@&", key, parametersDict[key]];
    }
    // 4.3、截取参数字符串，去掉最后一个“&”，并且将其转成NSData数据类型。
    NSData *parametersData = [[parameterString substringToIndex:parameterString.length - 1] dataUsingEncoding:NSUTF8StringEncoding];
    
    // 5、设置请求报文
    request.HTTPBody = parametersData;
    // 6、构造NSURLSessionConfiguration
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    // 7、创建网络会话
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    // 8、创建会话任务
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        doneHandler(data, response, error);
    }];
    // 9、执行任务
    [task resume];
}

@end
