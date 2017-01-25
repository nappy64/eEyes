//
//  XMLParserDelegate.m
//  eEyes
//
//  Created by Nap Chen on 2017/1/10.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "XMLParserDelegate.h"
#import "Sensor.h"

@implementation XMLParserDelegate
{
    Sensor *currentItem;
    NSMutableString *currentValue;
    
    NSMutableArray *results;
}

// 解析到一个元素的开始就会调用
// ex: <title>
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    
    //    NSLog(@"didStartElement...");
    
    if([elementName isEqualToString:@"item"]) {
        
        // create result if necessary
        if(results == nil) {
            results = [NSMutableArray new];
        }
        // createa NewsItem for the following need
        currentItem = [Sensor new];
        
    } else if([elementName isEqualToString:@"id"] ||
              [elementName isEqualToString:@"value"] ||
              [elementName isEqualToString:@"date"]) {
        
        currentValue = nil;
        
    }
}

// 解析到一个元素的结束就会调用
// ex: </title>
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    //    NSLog(@"didEndElement...");
    
    // parse 一個 element 結束
    if([elementName isEqualToString:@"item"]) {
        
        // 結束時將新 item 放到 array 中
        [results addObject:currentItem];
        currentItem = nil;                  // 清掉 currentItem 很重要
        
    } else if([elementName isEqualToString:@"id"]) {
        
        currentItem.id = [NSNumber numberWithFloat:[currentValue intValue]];
        
    } else if([elementName isEqualToString:@"value"]) {
        
        currentItem.value = [NSNumber numberWithFloat:[currentValue floatValue]];
        
    } else if([elementName isEqualToString:@"date"]) {
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//        currentItem.date = [dateFormatter dateFromString:currentValue];
        currentItem.date = currentValue;
    }
    currentValue = nil; // close 掉 currentValue，避免影響到之前使用到 currentValue 這個物件的項目
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    //    NSLog(@"foundCharacters...");
    
    if(currentValue == nil) {
        currentValue = [[NSMutableString alloc] initWithString:string];
    } else {
        [currentValue appendString:string];
    }
    
}

- (NSMutableArray*) getParserResults{
    return results;
}
@end
