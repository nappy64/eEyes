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


@interface DrawCSVFileViewController ()<DVLineChartViewDelegate>
{
    NSMutableArray *chartList;
    ExportCSVFile *exportCSV;
}
@property (weak, nonatomic) IBOutlet UIView *historyChartView;

@end

@implementation DrawCSVFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    exportCSV = [ExportCSVFile sharedInstance];
    chartList = [NSMutableArray array];
    chartList = [exportCSV transferCSVToArray:exportCSV.fileNameSelected];
    [self drawHistoryChart];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) drawHistoryChart {
    
    _historyChartView.backgroundColor = [UIColor colorWithHexString:@"3e4a59"];
    
    DVLineChartView *ccc = [[DVLineChartView alloc] initWithFrame:_historyChartView.bounds];
    
    [_historyChartView addSubview:ccc];
    
    ccc.width = _historyChartView.width;
    
    // Y 座標刻度與左方的間距
    ccc.yAxisViewWidth = 52;
    
    // Y 軸分成幾格
    ccc.numberOfYAxisElements = 20;
    
    ccc.delegate = self;
    ccc.pointUserInteractionEnabled = YES;
    
    // Y 軸最大值
    ccc.yAxisMaxValue = 100;
    
    // 兩點間的 X 軸間距
    ccc.pointGap = 30;
    
    ccc.showSeparate = YES;
    ccc.separateColor = [UIColor colorWithHexString:@"67707c"];
    
    ccc.textColor = [UIColor colorWithHexString:@"9aafc1"];
    ccc.backColor = [UIColor colorWithHexString:@"3e4a59"];
    ccc.axisColor = [UIColor colorWithHexString:@"67707c"];
    
    ccc.x = 0;
    ccc.y = 100;
    ccc.width = _historyChartView.width;
    ccc.height = 300;
    
    DVPlot *plot = [[DVPlot alloc] init];
    //DVPlot *plot1 = [[DVPlot alloc] init];
    //HistoryChartValues *hcv = [HistoryChartValues new];
    
//    for(int i = 0; i < chartList.count; i++) {
//        hcv = chartList[i];
    
//        if(i == 0) {
            plot.pointArray = chartList[0];
            plot.lineColor = [UIColor colorWithHexString:@"2f7184"];
            plot.pointColor = [UIColor colorWithHexString:@"14b9d6"];
            plot.chartViewFill = YES;
            plot.withPoint = YES;
            [ccc addPlot:plot];
//        } else {
//            plot1.pointArray = hcv.values;
//            plot1.lineColor = [[UIColor blueColor] colorWithAlphaComponent:0.3];
//            plot1.pointColor = [UIColor whiteColor];
//            plot1.chartViewFill = YES;
//            plot1.withPoint = YES;
//            [ccc addPlot:plot1];
//        }
    
        //NSLog(@"plat data %@",hcv.values[0]);
    //}
    
    ccc.xAxisTitleArray = chartList[1];
    
    [ccc draw];
    
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
