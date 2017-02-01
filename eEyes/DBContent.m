//
//  DBContent.m
//  eEyes
//
//  Created by Nap Chen on 2017/1/25.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "DBContent.h"

@implementation DBContent

static DBContent *_singletonDBContent = nil;

+ (instancetype) sharedInstance {
    
    if(_singletonDBContent == nil){
        _singletonDBContent = [DBContent new];
    }
    return _singletonDBContent;
}

-(void) getDBContent {
    
}


@end
