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


#define NLSystemVersionGreaterOrEqualThan(version)  ([[[UIDevice currentDevice] systemVersion] floatValue] >= version)

#define IOS7_OR_LATER   NLSystemVersionGreaterOrEqualThan(7.0)

#define GraphColor  [[UIColor greenColor] colorWithAlphaComponent:0.5]

#define str(index)  [NSString stringWithFormat : @"%.f", [[self.values objectAtIndex:(index)] floatValue]]

#define point(x, y) CGPointMake((x) * kXScale, yOffset + (y) * kYScale)


@interface RealChartView ()
@end

@implementation RealChartView
{
    ConfigManager *config;
    double drawValue;
    bool isWaitingResponse;
}

const CGFloat kXScale = 15.0; // 每个点的间隔
const CGFloat kYScale = 1.0; // 每个图像的高度

static inline CGAffineTransform
CGAffineTransformMakeScaleTranslate(CGFloat sx, CGFloat sy, CGFloat dx, CGFloat dy)
{
    return CGAffineTransformMake(sx, 0.f, 0.f, sy, dx, dy);
}

// 使用代码加载的对象调用（使用纯代码创建）
// 初始化並且回傳一個指定長寬的新 view 物件
- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"Initial with Frame...");
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code
        drawValue = 0;
        
        // UIImageView 整体不拉伸，往右對齊
        [self setContentMode:UIViewContentModeRight];
        
        _values = [NSMutableArray array];
    }
    
    

    CGFloat height = frame.size.height;
    CGFloat width = frame.size.width;
    
    
    
    return self;
}

// 从 xib 或者 storyboard 加载完毕就会调用
- (void)awakeFromNib
{
    NSLog(@"Awake from Nib...");
    
    [super awakeFromNib];
    
    // UIImageView 整体不拉伸，往右對齊
    [self setContentMode:UIViewContentModeRight];
    
    _values = [NSMutableArray array];
}

- (void)updateValues:(NSMutableArray *)values;
{
    
    _values = values;
    
    // bounds：该 view 在本地坐标系统中的位置和大小。
    CGSize size = self.bounds.size;
    
    // view 的寬
    CGFloat     maxDimension = size.width; // MAX(size.height, size.width);
    // 每個 view 顯示的點數
    NSUInteger  maxValues = (NSUInteger)floorl(maxDimension / kXScale);
    
    // 是否超過顯示點數
//    if ([self.values count] > maxValues) {
//        NSLog(@"Remove Value...self.bounds.size Width : %f, total count : %lu, maxValues : %lu", maxDimension, (unsigned long)self.values.count, (unsigned long)maxValues);
//        // 從 values 移除掉超過顯示點數的數值
//        [self.values removeObjectsInRange:NSMakeRange(0, [self.values count] - maxValues)];
//    }
    
    // 会重新调用 drawRect: 方法
    [self setNeedsDisplay];
}

- (void)dealloc
{
    NSLog(@"~~~ dealloc ~~~");
}

// 畫線
// 每次调用drawRect:方法，都会将以前画的东西清除掉
- (void)drawRect:(CGRect)rect
{
    
    if ([self.values count] == 0) {
        return;
    }
    NSLog(@"Draw Rect...");
    
    // 获取当前的上下文
    CGContextRef ctxCenter = UIGraphicsGetCurrentContext();
    // 设置线条颜色
    CGContextSetStrokeColorWithColor(ctxCenter, [UIColor blackColor].CGColor);
    // 设置连接点样式
    CGContextSetLineJoin(ctxCenter, kCGLineJoinRound);
    // 设置线条寬度
    CGContextSetLineWidth(ctxCenter, 3);
    
    CGMutablePathRef pathCenter = CGPathCreateMutable();
    
    // Y 軸中點
    CGFloat yOffset = self.bounds.size.height / 2;
    // 创建一个中心对称的路径平移函数
    CGAffineTransform transform = CGAffineTransformMakeScaleTranslate(kXScale, kYScale, 0, yOffset);
    
    // 中心線
    // 设置起点
    CGPathMoveToPoint(pathCenter, &transform, 0, 0);
    // 将点添加到路径里面
    CGPathAddLineToPoint(pathCenter, &transform, self.bounds.size.width, 0); // self.bounds.size.width其实大了kXScale倍
    
    // 进行绘制
    CGContextAddPath(ctxCenter, pathCenter);
    // 释放路径
    CGPathRelease(pathCenter);
    // 闭合路径
    CGContextStrokePath(ctxCenter);
    
    // 趨勢線
    // 获取当前的上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // 设置线条颜色
    CGContextSetStrokeColorWithColor(ctx, [GraphColor CGColor]);
    // 设置连接点样式
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    // 设置线条寬度
    CGContextSetLineWidth(ctx, 5);
    // 创建路径
    CGMutablePathRef path = CGPathCreateMutable();
    
    // 設定第一個點為起點的路徑
    CGFloat y = 0 - [[self.values objectAtIndex:0] floatValue];
    
    // 设置起点
    CGPathMoveToPoint(path, &transform, 0, y);
    // 顯示該點的數值
    [self drawAtPoint:point(0, y) withStr:str(0)];
    // 將 values 裡的點數添加到路径里面
    for (NSUInteger x = 1; x < [self.values count]; ++x) {
        y = 0 - [[self.values objectAtIndex:x] floatValue];
        
        // 将点添加到路径里面
        CGPathAddLineToPoint(path, &transform, x, y);
        [self drawAtPoint:point(x, y) withStr:str(x)];
    }
    // 进行绘制
    CGContextAddPath(ctx, path);
    // 释放路径
    CGPathRelease(path);
    // 闭合路径
    CGContextStrokePath(ctx);
}

- (void)drawAtPoint:(CGPoint)point withStr:(NSString *)str
{
    
    [str drawAtPoint:point withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:8], NSStrokeColorAttributeName:GraphColor}];
}

@end
