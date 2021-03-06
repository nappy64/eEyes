//
//  AppDelegate.m
//  eEyes
//
//  Created by Nap Chen on 2017/1/10.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "AppDelegate.h"
#import "HTTPComm.h"
#import "ConfigManager.h"
#import "RegularAction.h"

#define CONNECT_TYPE_UPDATE_DEVICETOKEN @"updateDeviceToken"
#define DB_DEVICETOKEN @"deviceToken"


@interface AppDelegate ()<NSURLSessionDelegate>
{
    ConfigManager *config;
    HTTPComm *httpComm;
    RegularAction *ra;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Ask user's permission of notification.
    UIUserNotificationType type = UIUserNotificationTypeAlert | UIUserNotificationTypeSound |UIUserNotificationTypeBadge;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
    [application registerUserNotificationSettings:settings];
    
    // Ask device token from APNS
    [application registerForRemoteNotifications];
    return YES;
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSLog(@"DeviceToken: %@",deviceToken.description);
    
    config = [ConfigManager sharedInstance];
    
    NSString *finalDeviceToken = deviceToken.description;
    finalDeviceToken = [finalDeviceToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    finalDeviceToken = [finalDeviceToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    finalDeviceToken = [finalDeviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"finalDeviceToken: %@",finalDeviceToken);
    
    // Upload DeviceToken
    httpComm = [HTTPComm sharedInstance];
    config = [ConfigManager sharedInstance];
    
    NSURL *url = [[NSURL alloc] initWithString:config.dbSensorValueAddress];
    
    // Date Record
    NSDate *currentDate=[NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentDateString = [formatter stringFromDate:currentDate];
    NSLog(@"currentDate=%@", currentDateString);

    [httpComm sendHTTPPost:url
                   timeout:2
                   dbTable:DB_DEVICETOKEN
                  sensorID:nil
                 startDate:currentDateString
                   endDate:nil
                insertData:finalDeviceToken
              functionType:CONNECT_TYPE_UPDATE_DEVICETOKEN
                completion:^(NSData *data, NSURLResponse *response, NSError *error) {
                    if(error){
                        NSLog(@"%@",error);
                    }else{
                        NSLog(@"Response %@",response);
                        //NSLog(@"Success %@",finalDeviceToken);
                    }
                }];
    
    

}
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@",error);
}


- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSDictionary *aps = userInfo[@"aps"];
    
    if(aps[@"content-available"]){
        ra= [RegularAction sharedInstance];
        NSString *newTime = [ra getTheTimeOfTheLastAverage:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"here:%@",result);
        }];
        NSLog(@"%@",newTime);
        [ra getDataToAverage:@"2017-01-25 21:00:14.111" withEndDate:@"2017-01-25 21:59:14.222"];
        
        NSLog(@"HERE");
        [ra dataToJSON];
        } else {
        // Post a notification
        [[NSNotificationCenter defaultCenter] postNotificationName:DID_RECEIVE_REMOTE_NOTIFICATION object:nil];
        
    }}

-(void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler{

}
/*
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    

}
*/

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)getDataToAverage{
    httpComm = [HTTPComm sharedInstance];
    NSURL *url = [[NSURL alloc] initWithString:config.dbSensorValueAddress];
    //NSURL *url = [NSURL URLWithString:CONNECT_FOR_MOBILE];
    [httpComm sendHTTPPost:url
                   timeout:10
                   dbTable:nil
                  sensorID:@"1"
                 startDate:@"2017-01-25 21:00:14"
                   endDate:@"2017-01-25 01:59:14"
                insertData:nil
              functionType:@"getRange"
                completion:^(NSData *data, NSURLResponse *response, NSError *error) {
                    NSString *dataString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                    NSLog(@"%@",dataString);
                }];


}

-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    NSString *urlString = url.absoluteString;
    NSString *parameter = [urlString stringByReplacingOccurrencesOfString:@"eeyeswidget://" withString:@""];
    
    NSLog(@"parameter is %@", parameter);
    
    return true;
}

@end
