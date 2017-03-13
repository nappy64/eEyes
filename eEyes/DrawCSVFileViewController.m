//
//  DrawCSVFileViewController.m
//  eEyes
//
//  Created by Denny on 2017/2/6.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "DrawCSVFileViewController.h"
#import "DVLineChartView.h"
#import "UIView+Extension.h"
#import "UIColor+Hex.h"
#import "HistoryChartValues.h"
#import "ExportCSVFile.h"


#define X_AXIS_GAP_STEP 5
#define X_AXIS_MAX_GAP  100
#define X_AXIS_MID_GAP  1.0
#define X_AXIS_MIN_GAP  0.1

#define Y_AXIS_GAP_STEP 5
#define Y_AXIS_MAX_GAP  500
#define Y_AXIS_MIN_GAP  1

#define DRAW_MAX_LIMIT 450

@interface DrawCSVFileViewController ()<DVLineChartViewDelegate>
{
    NSMutableArray *chartList;
    ExportCSVFile *exportCSV;
    AllSensors *allSensors;
    NSArray *allSensorsInfo;
    ConfigManager *config;
    DVLineChartView *ccc;
    NSArray *eachDataList;
    NSMutableArray *allDataList;
    
    CGFloat xAxisGap;
    CGFloat yAxisGap;
    
    int dataCount;

    
}
@property (weak, nonatomic) IBOutlet UIButton *isDisplayRemarkButton;

@property (weak, nonatomic) IBOutlet UIView *historyChartView;

@end

@implementation DrawCSVFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    allDataList = [NSMutableArray array];
    exportCSV = [ExportCSVFile sharedInstance];
    chartList = [NSMutableArray array];
    chartList = [exportCSV transferCSVToArray:exportCSV.fileNameSelected];
    allSensors = [AllSensors sharedInstance];
    allSensorsInfo = [allSensors getAllSensorsInfo];
    NSRange theRange;
    theRange.location = 0;
    theRange.length = DRAW_MAX_LIMIT;
    
    for(eachDataList in chartList){
        if(eachDataList.count >= DRAW_MAX_LIMIT){
            eachDataList = [eachDataList subarrayWithRange:theRange];
        }
        dataCount = (int)eachDataList.count;
        [allDataList addObject:eachDataList];
    }
    
    xAxisGap = 30;
    yAxisGap = 100;

    CGSize viewSize = [[UIScreen mainScreen] bounds].size;
    
    CGFloat STATUS_BAR_HEIGHT = 20;
    UIInterfaceOrientation CURRENT_ORIENTATION = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(UIInterfaceOrientationIsLandscape(CURRENT_ORIENTATION)){
        viewSize = CGSizeMake(_historyChartView.height, _historyChartView.width - STATUS_BAR_HEIGHT);
        
    } else {
        viewSize = CGSizeMake(_historyChartView.width, _historyChartView.height - STATUS_BAR_HEIGHT);
    }

    
    [self drawHistoryChart];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) drawHistoryChart {
    
    _historyChartView.backgroundColor = [UIColor whiteColor];
    
    CGRect chartRect = CGRectMake(0, 0, _historyChartView.bounds.size.width, _historyChartView.bounds.size.height);
    
    ccc = [[DVLineChartView alloc] initWithFrame:chartRect];
    
    [_historyChartView addSubview:ccc];
    
    ccc.width = self.view.bounds.size.width;
    
    // Y 座標刻度與左方的間距
    ccc.yAxisViewWidth = 52;
    
    // Y 軸分成幾格
    ccc.numberOfYAxisElements = 10;
    
    ccc.delegate = self;
    ccc.pointUserInteractionEnabled = YES;
    
    // Y 軸最大值
    ccc.yAxisMaxValue = yAxisGap;
    
    // 兩點間的 X 軸間距
    ccc.pointGap = xAxisGap;
    
    ccc.showSeparate = YES;
    ccc.separateColor = [UIColor colorWithHexString:@"67707c"];
    
    ccc.textColor = [UIColor colorWithHexString:@"9aafc1"];
    ccc.backColor = [UIColor whiteColor];
    ccc.axisColor = [UIColor colorWithHexString:@"67707c"];
    
    ccc.x = 0;
    ccc.y = 0;
    ccc.width = _historyChartView.width;
    ccc.height = _historyChartView.height;
    
    DVPlot *plot = [[DVPlot alloc] init];
    DVPlot *plot1 = [[DVPlot alloc] init];
    HistoryChartValues *hcv = [HistoryChartValues new];

    for(int i = 0; i < allDataList.count; i++) {
        hcv = allDataList[i];

        if(i == 0) {
            plot.pointArray = allDataList[0];
            //plot.lineColor = [UIColor colorWithHexString:@"2f7184"];
            //plot.pointColor = [UIColor colorWithHexString:@"14b9d6"];
            //plot.chartViewFill = YES;
            plot.lineColor = [UIColor orangeColor];
            plot.pointColor = [UIColor orangeColor];
            plot.withPoint = YES;
            [ccc addPlot:plot];
        } else if (i == 2){
            plot1.pointArray = allDataList[2];
            //plot1.lineColor = [[UIColor blueColor] colorWithAlphaComponent:0.3];
            //plot1.pointColor = [UIColor whiteColor];
            //plot1.chartViewFill = YES;
            plot1.lineColor = [UIColor blueColor];
            plot1.pointColor = [UIColor blueColor];
            plot1.withPoint = YES;
            [ccc addPlot:plot1];
        }
        
        NSLog(@"plat data %@",hcv);
        
    }
    
    
    ccc.xAxisTitleArray = allDataList[1];
    
    ccc.xAxisViewX = 0;
    ccc.xAxisViewY = 0;
    ccc.xAxisViewW = dataCount * ccc.pointGap + 200;
    ccc.xAxisViewH = ccc.height;
    
    ccc.yAxisViewX = 0;
    ccc.yAxisViewY = 0;
    ccc.yAxisViewW = ccc.yAxisViewWidth;
    ccc.yAxisViewH = ccc.height;
    
    ccc.scrollViewX = ccc.yAxisViewWidth;
    ccc.scrollViewY = 0;
    ccc.scrollViewW = _historyChartView.width - ccc.yAxisViewW;
    ccc.scrollViewH = ccc.height;
    
    [ccc draw];
    
    
}


#pragma mark - button pressed
- (IBAction)yIncrementButtonTapped:(UIButton *)sender{
    [ccc removeFromSuperview];
    
    if(yAxisGap >= Y_AXIS_MAX_GAP) {
        yAxisGap = Y_AXIS_MAX_GAP;
    } else {
        yAxisGap += Y_AXIS_GAP_STEP;
        
        if(yAxisGap > Y_AXIS_MAX_GAP) {
            yAxisGap = Y_AXIS_MAX_GAP;
        }
    }
    
    NSLog(@"yAxisGap : %f",yAxisGap);
    
    [self drawHistoryChart];

}
- (IBAction)yDecrementButtonTapped:(UIButton *)sender{
    [ccc removeFromSuperview];
    
    if(yAxisGap <= Y_AXIS_MIN_GAP) {
        yAxisGap = Y_AXIS_MIN_GAP;
    } else {
        yAxisGap -= Y_AXIS_GAP_STEP;
        
        if(yAxisGap < Y_AXIS_MIN_GAP) {
            yAxisGap = Y_AXIS_MIN_GAP;
        }
    }
    
    NSLog(@"yAxisGap : %f",yAxisGap);
    
    [self drawHistoryChart];
}

- (IBAction)displayRemarkButtonTapped:(UIButton *)sender {
    
    if(config.isDisplayValueInHistoryChart) {
        [config setIsDisplayValueInHistoryChart:false];
        _isDisplayRemarkButton.backgroundColor = [UIColor grayColor];
        
    } else {
        [config setIsDisplayValueInHistoryChart:true];
        _isDisplayRemarkButton.backgroundColor = [UIColor greenColor];
    }
    
    [ccc removeFromSuperview];
    
    [self drawHistoryChart];
}

#pragma mark - redraw after change Orientation
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    [ccc removeFromSuperview];
    
    [self drawHistoryChart];
}










/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
