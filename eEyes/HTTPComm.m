//
//  HTTP.m
//  eEyes
//
//  Created by Nap Chen on 2017/1/10.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "HTTPComm.h"
#import "ConfigManager.h"

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

- (void) sendHTTPPost:(NSURL*)url timeout:(NSTimeInterval)timeout sensorID:(NSString*)sensorID startDate:(NSString*)startDate endDate:(NSString*)endDate functionType:(NSString*)functionType completion:(DoneHandler)doneHandler {
    
    // initial ConfigManager singleton
    ConfigManager *config = [ConfigManager sharedInstance];
    
    // 1、创建URL资源地址
//    NSURL *url = [[NSURL alloc] initWithString:phpLinkText];
    //    NSURL *url = [NSURL URLWithString:Post_Url_String];
    // 2、创建Reuest请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    // 3、配置Request
    request.timeoutInterval = timeout;
    request.HTTPMethod = @"POST";
    // 4、构造请求参数
    NSDictionary *parametersDict;
    // 4.1、创建字典参数，将参数放入字典中，可防止程序员在主观意识上犯错误，即参数写错。
    if([functionType isEqualToString:@"getNew"]) {
        parametersDict = @{@"username":config.dbUserName, @"password":config.dbPassword, @"database":config.dbName, @"table":@"RealID10001", @"field":@"RealValue", @"sensorID":@"1", @"datefield":@"Date", @"startdate":startDate, @"enddate":endDate, @"type":functionType};
    } else if([functionType isEqualToString:@"getRange"]) {
        parametersDict = @{@"username":config.dbUserName, @"password":config.dbPassword, @"database":config.dbName, @"table":@"SensorRawData", @"field":@"RawValue", @"sensorID":sensorID, @"datefield":@"StartDate", @"startdate":startDate, @"enddate":endDate, @"type":functionType};
    } else if([functionType isEqualToString:@"getSensorByUser"]) {
        parametersDict = @{@"username":config.dbUserName, @"password":config.dbPassword, @"database":config.dbName,@"appUserName":config.appUserName, @"appPassword":config.appPassword, @"type":functionType};
    }
    
    
    // 4.2、遍历字典，以“key=value&”的方式创建参数字符串。
    NSMutableString *parameterString = [NSMutableString string];
    
    for (NSString *key in parametersDict.allKeys) {
        // 拼接字符串
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
