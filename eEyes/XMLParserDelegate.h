//
//  XMLParserDelegate.h
//  eEyes
//
//  Created by Nap Chen on 2017/1/10.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLParserDelegate : NSObject <NSXMLParserDelegate>

- (NSMutableArray*) getParserResults;

@end
