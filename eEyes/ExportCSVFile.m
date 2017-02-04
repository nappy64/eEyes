//
//  ExportCSVFile.m
//  eEyes
//
//  Created by Nap Chen on 2017/1/10.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "ExportCSVFile.h"

@implementation ExportCSVFile

- (BOOL) createCSVFile:(NSString*) fileName dataOfContent:(NSData*) data{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Create NSString object, that holds our exact path to the documents directory
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.csv", fileName]];
    NSLog(@"CSVFilePath:  %@",fullPath);
    
    BOOL result = [[NSFileManager defaultManager] createFileAtPath:fullPath contents:data attributes:nil];
    NSLog(@"CreateOrNot:  %d",result);
    return result;
}




@end
