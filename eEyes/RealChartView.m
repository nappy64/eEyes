//
//  RealChartView.m
//  eEyes
//
//  Created by Nap Chen on 2017/1/17.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "RealChartView.h"
#import "HTTPComm.h"
#import "ConfigManager.h"
#import "XMLParserDelegate.h"
#import "Sensor.h"

#define point(x, y) CGPointMake((x) * kXScale, yOffset + (y) * kYScale)

@interface RealChartView ()
@end

@implementation RealChartView
{
    ConfigManager *config;
    bool isWaitingResponse;
}

const CGFloat kXScale = 25.0;   // x scale
const CGFloat kYScale = 3.0;    // y scale

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        // UIImageView content mode to Right
        [self setContentMode:UIViewContentModeRight];
        
        _values = [NSMutableArray array];
    }
    
    self.backgroundColor = [UIColor clearColor];
    
    return self;
}

- (void)updateValues:(NSMutableArray *)values;
{

    _values = values;

    // will call drawRect
    [self setNeedsDisplay];
}

- (void)dealloc
{
//    NSLog(@"~~~ dealloc ~~~");
}

// will clear the previous context first
- (void)drawRect:(CGRect)rect
{
    
    if ([self.values count] == 0) {
        return;
    }
    
    // remove some subview from a cell
    for (UILabel *obj in [self subviews]) {
        if ([obj isKindOfClass:[UILabel class]]) {
            [obj removeFromSuperview];
        }
    }
    
    // y axis
    CGFloat yOffset = self.bounds.size.height;
    // create an affine transformation matrix
    CGAffineTransform transform = CGAffineTransformMake(_xScale,0,0,_yScale,0,yOffset);
    
    for(int i = 0; i < 11; i++) {
    
        CGFloat yOffset = (_maxValue / 10) * i;
        
        // the base line
        // get current context
        CGContextRef ctxCenter = UIGraphicsGetCurrentContext();
        // path color
        CGContextSetStrokeColorWithColor(ctxCenter, [UIColor grayColor].CGColor);
        // path style rounded
        CGContextSetLineJoin(ctxCenter, kCGLineJoinRound);
        // path width
        CGContextSetLineWidth(ctxCenter, 0.3);
        // create new path
        CGMutablePathRef pathCenter = CGPathCreateMutable();
        
        CGFloat y = 0 - yOffset;
        
        // add first value in values to this path
        CGPathMoveToPoint(pathCenter, &transform, 0, y);
        // add next point to this path
        CGPathAddLineToPoint(pathCenter, &transform, self.bounds.size.width, y);
        // add the path to this context
        CGContextAddPath(ctxCenter, pathCenter);
        // release this path
        CGPathRelease(pathCenter);
        // close this path
        CGContextStrokePath(ctxCenter);
        
        CGRect frame = CGRectMake(0, (self.bounds.size.height/10)*i, 100, 15);
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.text = [NSString stringWithFormat: @"%.1f", _maxValue - yOffset];
        [self addSubview:label];
    }
    
    
    
    
    
    NSMutableArray *oneChartValue = [NSMutableArray array];
    
    // realtime chart width
    CGFloat maxDimension = self.bounds.size.width;
    // max display points
    NSUInteger  maxValues = (NSUInteger)floorl(maxDimension / _xScale) + 1;
    
    // draw charts by values
    for(int i = 0; i < _values.count; i++) {
    
        // path data from view controller
        oneChartValue = _values[i];
        
        NSString *str = @" ";
        
        if ([oneChartValue count] > maxValues) {
            // over max display points
            [oneChartValue removeObjectsInRange:NSMakeRange(0, [oneChartValue count] - maxValues)];
        }
        
        // get current context
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        // line join in the current graphics state
        CGContextSetLineJoin(ctx, kCGLineJoinRound);
        // line width
        CGContextSetLineWidth(ctx, 5);
        // create new path
        CGMutablePathRef path = CGPathCreateMutable();
        
        CGFloat y = 0 - [[oneChartValue objectAtIndex:0] floatValue];
        // add first value in values to this path
        CGPathMoveToPoint(path, &transform, 0, y);
        
        if(_isDisplayValue == true) {
            str = [NSString stringWithFormat : @"%.1f", [[oneChartValue objectAtIndex:(0)] floatValue]];
        }
        
        CGPoint point = CGPointMake(0, yOffset + y * _yScale);
        
        // setup line color and text
        if(i == 0) {
            [str drawAtPoint:point
 withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:8], NSStrokeColorAttributeName:[[UIColor orangeColor] colorWithAlphaComponent:1.0]}];
        } else if(i == 1) {
            [str drawAtPoint:point withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:8], NSStrokeColorAttributeName:[[UIColor blueColor] colorWithAlphaComponent:1.0]}];
        }
        
        // add value in values to this path
        for (NSUInteger x = 1; x < oneChartValue.count; ++x) {
            y = 0 - [[oneChartValue objectAtIndex:x] floatValue];
            
            // add next point to this path
            CGPathAddLineToPoint(path, &transform, x, y);
            
            if(_isDisplayValue == true) {
                str = [NSString stringWithFormat : @"%.1f", [[oneChartValue objectAtIndex:(x)] floatValue]];
            }

            point = CGPointMake(x * _xScale, yOffset + y * _yScale);
            
            // setup line color and text
            if(i == 0) {
                [str drawAtPoint:point withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:8], NSStrokeColorAttributeName:[[UIColor orangeColor] colorWithAlphaComponent:1.0]}];
            } else if(i == 1) {
                [str drawAtPoint:point withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:8], NSStrokeColorAttributeName:[[UIColor blueColor] colorWithAlphaComponent:1.0]}];
            }
        }
        // add the path to this context
        CGContextAddPath(ctx, path);
        // release this path
        CGPathRelease(path);
        // close this path
        CGContextStrokePath(ctx);
    }
    
    
}

@end
