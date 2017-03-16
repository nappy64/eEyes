//
//  DrawChartSettingViewController.m
//  eEyes
//
//  Created by Nap Chen on 2017/1/28.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "DrawChartSettingViewController.h"
#import "ConfigManager.h"
#import "AllSensors.h"
#import "Sensor.h"
#import "RealtimeChartViewController.h"
#import "HistoryChartViewController.h"

#define IMAGE_NAME_TEMP @"temperature.png"
#define IMAGE_NAME_HUMID @"water.png"
#define ROOM_TEMPERATURE @"房間溫度"
#define ROOM_HUMIDITY @"房間濕度"


@interface DrawChartSettingViewController ()

@property(nonatomic,strong) UIDatePicker *datePicker;

@end

@implementation DrawChartSettingViewController
{
    ConfigManager *config;
    AllSensors *allSensors;
    
    bool isDisplayRealChart;
    
    NSArray *allSensorsInfo;
    NSMutableArray *sensorsButton;
    
    UITextField *startDateTextField;
    UITextField *endDateTextField;
    
    UIImage *originButtonImage;
    UIImage *buttonImage;
    UIImage *greyButtonImage;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    config = [ConfigManager sharedInstance];
    allSensors = [AllSensors sharedInstance];
    
    allSensorsInfo = [allSensors getAllSensorsInfo];
    
//    isDisplayRealChart = [config getDisplayRealTimeChartEnable];
    isDisplayRealChart = config.isDisplayRealTimeChart;
    
    sensorsButton = [NSMutableArray array];
    
    // 準備導覽列上按鈕
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pressConfirmButtonToCreateInputContent:)];
    
    // 放上導覽列
    self.navigationItem.rightBarButtonItems = @[addItem];
    
    Sensor *sensor = [Sensor new];
    
    CGFloat xIndex = 50;
    CGFloat yIndex = 80;
    CGFloat wIndex = self.view.bounds.size.width/2 - 100;
    
    for(int i = 0; i < [allSensors getSensorsCount]; i++) {
        
        sensor = allSensorsInfo[i];
        
        // create UIButton
        CGRect buttonFrame = CGRectMake( xIndex, yIndex, wIndex, 125 );
        UIButton *button = [[UIButton alloc] initWithFrame: buttonFrame];
        //[button setTitle:sensor.name forState:UIControlStateNormal];
        config = [ConfigManager sharedInstance];
        NSString *sensorName = [NSString stringWithFormat:@"%@",sensor.name];
        [button.imageView setAccessibilityIdentifier:sensorName];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        
        
        
        // Set Button Image
        if([sensor.name isEqualToString:ROOM_TEMPERATURE]){
            buttonImage = [UIImage imageNamed:IMAGE_NAME_TEMP];
        }else if([sensor.name isEqualToString:ROOM_HUMIDITY]){
            buttonImage = [UIImage imageNamed:IMAGE_NAME_HUMID];
        }
        originButtonImage = buttonImage;
        // Set Button GreyImage
        greyButtonImage = [self convertImageToGrayScale:buttonImage];
        [button setImage:buttonImage forState:UIControlStateNormal];
        
        // Check button status
        if(sensor.isSelected) {
            button.selected = true;
            //button.backgroundColor = [UIColor greenColor];
        } else {
            button.selected = false;
            [button setImage:greyButtonImage forState:UIControlStateNormal];
            //button.backgroundColor = [UIColor grayColor];
        }
        
        [self.view addSubview:button];
        
        [button addTarget:self
                   action:@selector(handleButtonClicked:)
         forControlEvents:UIControlEventTouchUpInside
         ];
        
        xIndex += self.view.bounds.size.width/2;
        if(xIndex > self.view.bounds.size.width) {
            xIndex = 10;
            yIndex += 150;
        }
    }

        /*
        CGRect buttonFrame = CGRectMake( xIndex, yIndex, wIndex, 30 );
        UIButton *button = [[UIButton alloc] initWithFrame: buttonFrame];
        [button setTitle:sensor.name forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        if(isDisplayRealChart == true) {
            if([[sensor.sensorID stringValue] isEqualToString:config.realChartSensorID]) {
                button.selected = true;
                button.backgroundColor = [UIColor greenColor];
            } else {
                button.selected = false;
                button.backgroundColor = [UIColor grayColor];
            }
        } else {
            if(sensor.isSelected) {
                button.selected = true;
                button.backgroundColor = [UIColor greenColor];
            } else {
                button.selected = false;
                button.backgroundColor = [UIColor grayColor];
            }
        }
        
        
        
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
    }*/
    
    if(isDisplayRealChart == false) {
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
        datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
        datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        
        startDateTextField.inputView = datePicker;
        endDateTextField.inputView = datePicker;
        _datePicker = datePicker;
        
        [datePicker addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    }
}

- (void) handleButtonClicked:(id)sender {
    
    NSLog(@"button have been clicked.");
    
    UIButton *button = (UIButton *)sender;
    NSString *sensorName = button.imageView.accessibilityIdentifier;
    //NSString *sensorName = button.titleLabel.text;
    
    Sensor *sensor = [self getSensorNoByName:sensorName];
    buttonImage = button.currentImage;
    greyButtonImage = [self convertImageToGrayScale:buttonImage];
    
    NSString *name = [button.imageView accessibilityIdentifier];
    if([name isEqualToString:ROOM_TEMPERATURE]){
        buttonImage = [UIImage imageNamed:IMAGE_NAME_TEMP];
    }else if([name isEqualToString:ROOM_HUMIDITY]){
        buttonImage = [UIImage imageNamed:IMAGE_NAME_HUMID];
    }
    
    
    if(button.selected) {
        button.selected = false;
        sensor.isSelected = false;
        //[button setBackgroundColor:[UIColor grayColor]];
        [button setImage:greyButtonImage forState:UIControlStateNormal];
        NSLog(@"deSelected...");
    } else {
        button.selected = true;
        sensor.isSelected = true;
        NSLog(@"Selected...");
        //[button setBackgroundColor:[UIColor greenColor]];
        [button setImage:buttonImage forState:UIControlStateNormal];
    }

    
    
    /*
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
        [button setBackgroundColor:[UIColor greenColor]];
        NSLog(@"Selected...");
        
        config.realChartSensorID = [sensor.sensorID stringValue];
    }
     */
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
        [config setStartDate:dateStr];
        [config setAllConfig];
    }
    else if ([endDateTextField isFirstResponder])
    {
        endDateTextField.text = dateStr;
        [config setEndDate:dateStr];
        [config setAllConfig];
    }
}

- (void)pressConfirmButtonToCreateInputContent:(UIBarButtonItem *)sender {
    
//    if([config getDisplayRealTimeChartEnable]) {
    if(config.isDisplayRealTimeChart) {
        RealtimeChartViewController *realChartPage = [self.storyboard instantiateViewControllerWithIdentifier:@"RealtimeChartViewController"];
        [self showViewController:realChartPage sender:nil];
    } else {
        config.startDate = startDateTextField.text;
        config.endDate = endDateTextField.text;
        
        HistoryChartViewController *historyChartPage = [self.storyboard instantiateViewControllerWithIdentifier:@"HistoryChartViewController"];
        [self showViewController:historyChartPage sender:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - make UIImage grey
-(UIImage *)convertImageToGrayScale:(UIImage *)image {
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    context = CGBitmapContextCreate(nil,image.size.width, image.size.height, 8, 0, nil, kCGImageAlphaOnly );
    CGContextDrawImage(context, imageRect, [image CGImage]);
    CGImageRef mask = CGBitmapContextCreateImage(context);
    
    // Create a new UIImage object
    UIImage *newImage = [UIImage imageWithCGImage:CGImageCreateWithMask(imageRef, mask)];
    CGImageRelease(imageRef);
    CGImageRelease(mask);
    
    // Return the new grayscale image
    return newImage;
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
