//
//  RealChartView.h
//  eEyes
//
//  Created by Nap Chen on 2017/1/17.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RealChartView : UIView

@property (nonatomic, readonly, strong) NSMutableArray *values;

- (void)updateValues:(NSMutableArray*)values;
//- (void)draw;

@end