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
#import "AppDelegate.h"
#define HTTPMAXIMUM_PER_HOST 5

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
    } else if([functionType isEqualToString:@"updateDeviceToken"]) {
        parametersDict = @{@"username":config.dbUserName, @"password":config.dbPassword, @"database":config.dbName, @"table":dbTable, @"field":@"DeviceToken", @"datefield":@"LastUpdateDateTime", @"insertdate":startDate, @"insertdata":insertData, @"type":functionType};
    } else if([functionType isEqualToString:@"insertAverage"]) {
        parametersDict = @{@"username":config.dbUserName, @"password":config.dbPassword, @"database":config.dbName, @"field":@"Value", @"datefield":@"Date", @"data":insertData, @"type":functionType};
    } else if([functionType isEqualToString:@"getNewestAverageTime"]) {
        parametersDict = @{@"username":config.dbUserName,
                           @"password":config.dbPassword,
                           @"database":config.dbName,
                           @"type":functionType};
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
- (void)uploadAverageToServer:(NSURL*)url
                      timeout:(NSTimeInterval)timeout
                   insertData:(NSString*)insertData
                   identifier:(NSString*)identifier
                 functionType:(NSString*)functionType{
                   //completion:(DoneHandler)doneHandler {
    
    // initial ConfigManager singleton
    ConfigManager *config = [ConfigManager sharedInstance];
    
    //NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    _mutableRequest = [NSMutableURLRequest requestWithURL:url];
    _mutableRequest.timeoutInterval = timeout;
    _mutableRequest.HTTPMethod = @"POST";
    
    NSDictionary *parametersDict;
    if([functionType isEqualToString:@"insertAverage"]) {
        parametersDict = @{@"username":config.dbUserName,
                           @"password":config.dbPassword,
                           @"database":config.dbName,
                           @"field":@"Value",
                           @"datefield":@"Date",
                           @"data":insertData,
                           @"type":functionType};
    }
    NSMutableString *parameterString = [NSMutableString string];
    
    for (NSString *key in parametersDict.allKeys) {
        
        [parameterString appendFormat:@"%@=%@&", key, parametersDict[key]];
    }
    // 4.3、截取参数字符串，去掉最后一个“&”，并且将其转成NSData数据类型。
    NSData *parametersData = [[parameterString substringToIndex:parameterString.length - 1] dataUsingEncoding:NSUTF8StringEncoding];
    
    // 5、设置请求报文
    _mutableRequest.HTTPBody = parametersData;
    // 6、构造NSURLSessionConfiguration
    //NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"uploadAverageValue"];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
    
    /*
    configuration.timeoutIntervalForRequest = 10;
    configuration.allowsCellularAccess = true;
    configuration.sessionSendsLaunchEvents = true;
    configuration.discretionary = false;
    configuration.HTTPMaximumConnectionsPerHost = 1;
    configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    */

    
    // 7、创建网络会话
    //NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    _uploadAverageSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    //NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    // 8、创建会话任务
    
    _uploadTask = [_uploadAverageSession uploadTaskWithStreamedRequest:_mutableRequest];
    
    //NSURLSessionTask * task = [session dataTaskWithRequest:request];
    //NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //doneHandler(data, response, error);
    //}];
    // 9、执行任务
    [_uploadTask resume];
}


-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if(error){
        NSLog(@"%@",error);
    }else{
        NSLog(@"背景執行成功");
    }

}












@end
