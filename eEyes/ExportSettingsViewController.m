//
//  ExportSettingsViewController.m
//  eEyes
//
//  Created by Denny on 2017/2/4.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "ExportSettingsViewController.h"

@interface ExportSettingsViewController ()
@property(nonatomic,strong) UIDatePicker *datePicker;
@end

@implementation ExportSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    exportCSV = [ExportCSVFile new];
    config = [ConfigManager sharedInstance];
    allSensors = [AllSensors sharedInstance];
    allSensorsInfo = [allSensors getAllSensorsInfo];
    sensorsButton = [NSMutableArray array];
    
    NSMutableArray *drawData = [exportCSV transferCSVToArray:@"5.csv"];
    
    // 準備導覽列上按鈕
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pressConfirmButtonToGenerateCSV:)];
    
    // 放上導覽列
    self.navigationItem.rightBarButtonItems = @[addItem];
    
    
    Sensor *sensor = [Sensor new];
    
    CGFloat xIndex = 10;
    CGFloat yIndex = 80;
    CGFloat wIndex = self.view.bounds.size.width/2 - 20;
    
    for(int i = 0; i < [allSensors getSensorsCount]; i++) {
        
        sensor = allSensorsInfo[i];
        
        // create UIButton
        CGRect buttonFrame = CGRectMake( xIndex, yIndex, wIndex, 30 );
        UIButton *button = [[UIButton alloc] initWithFrame: buttonFrame];
        [button setTitle:sensor.name forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        if(sensor.isSelected) {
            button.selected = true;
            button.backgroundColor = [UIColor greenColor];
        } else {
            button.selected = false;
            button.backgroundColor = [UIColor grayColor];
        }
        
        [self.view addSubview:button];
        
        [button addTarget:self
                   action:@selector(handleButtonClicked:)
         forControlEvents:UIControlEventTouchUpInside
         ];
        
        xIndex += self.view.bounds.size.width/2;
        if(xIndex > self.view.bounds.size.width) {
            xIndex = 10;
            yIndex += 40;
        }
    }
    
    // create UILabel for start date
    UILabel *startDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, yIndex, 100, 30)];
    startDateLabel.text = @"開始時間";
    startDateLabel.textColor = [UIColor blackColor];
    startDateLabel.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:startDateLabel];
    
    // create UITextField for start date
    startDateTextField = [[UITextField alloc] initWithFrame:CGRectMake(100, yIndex, 250, 30)];
    startDateTextField.placeholder = @"start date";
    startDateTextField.borderStyle = UITextBorderStyleLine;
    
    startDateTextField.text = config.startDate;
    
    [self.view addSubview:startDateTextField];
    yIndex += 40;
    
    // create UILabel for end date
    UILabel *endDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, yIndex, 100, 30)];
    endDateLabel.text = @"結束時間";
    endDateLabel.textColor = [UIColor blackColor];
    endDateLabel.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:endDateLabel];
    
    // create UITextField for end date
    endDateTextField = [[UITextField alloc] initWithFrame:CGRectMake(100, yIndex, 250, 30)];
    endDateTextField.placeholder = @"end date";
    endDateTextField.borderStyle = UITextBorderStyleLine;
    
    endDateTextField.text = config.endDate;
    
    [self.view addSubview:endDateTextField];
    yIndex += 40;
    
    // set UIDatePicker field
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    //设置本地语言
    datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
    //设置日期显示的格式
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    //设置_birthdayField的inputView控件为datePicker
    startDateTextField.inputView = datePicker;
    endDateTextField.inputView = datePicker;
    _datePicker = datePicker;
    //监听datePicker的ValueChanged事件
    [datePicker addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    yIndex += 20;
    
    // Create UIButton
    UIButton *generateCSV = [[UIButton alloc]initWithFrame:CGRectMake(150, yIndex, 100, 30)];
    [generateCSV setTitle:@"SAVE File" forState:UIControlStateNormal];
    [generateCSV setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [generateCSV setBackgroundColor:[UIColor whiteColor]];
    [generateCSV sizeToFit];
    [generateCSV addTarget:self action:@selector(saveBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:generateCSV];
    

    
}

- (IBAction)saveBtnPressed:(id)sender{
    exportCSV = [ExportCSVFile new];
    [exportCSV prepareDataForGenerateCSV:@"1" startDate:startDateTextField.text endDate:endDateTextField.text];

}

- (void) handleButtonClicked:(id)sender {
    
    NSLog(@"button have been clicked.");
    
    UIButton *button = (UIButton *)sender;
    NSString *sensorName = button.titleLabel.text;
    Sensor *sensor = [self getSensorNoByName:sensorName];
    
    if(button.selected) {
        button.selected = false;
        sensor.isSelected = false;
        [button setBackgroundColor:[UIColor grayColor]];
        NSLog(@"deSelected...");
    } else {
        button.selected = true;
        sensor.isSelected = true;
        NSLog(@"Selected...");
        [button setBackgroundColor:[UIColor greenColor]];
    }
    
    if(sender == sensorsButton) {
        
    }
}

- (void) textFieldDone:(UITextField*)textField
{
    
    [textField resignFirstResponder];
}

- (Sensor*) getSensorNoByName:(NSString*)name {
    
    Sensor *sensorInfo = [Sensor new];
    
    for (Sensor *sensor in allSensorsInfo) {
        if([sensor.name isEqualToString:name]) {
            sensorInfo = sensor;
        }
    }
    
    return sensorInfo;
}

- (void)valueChange:(UIDatePicker *)datePicker{
    
    // set NSDateFormatter for 24 hours
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    // transfer to NSString
    NSString *dateStr = [fmt stringFromDate:datePicker.date];
    
    // check whick textfield editing
    if ([startDateTextField isFirstResponder])
    {
        startDateTextField.text = dateStr;
    }
    else if ([endDateTextField isFirstResponder])
    {
        endDateTextField.text = dateStr;
    }
}

- (void)pressConfirmButtonToGenerateCSV:(UIBarButtonItem *)sender {
    
    ExportTableViewController *exportTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ExportTableViewController"];
    [self showViewController:exportTableViewController sender:nil];
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
