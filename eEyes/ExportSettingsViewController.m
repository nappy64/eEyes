//
//  ExportSettingsViewController.m
//  eEyes
//
//  Created by Denny on 2017/2/4.
//  Copyright © 2017年 Nappy. All rights reserved.
//

#import "ExportSettingsViewController.h"
#define IMAGE_NAME_TEMP @"temperature.png"
#define IMAGE_NAME_HUMID @"water.png"
#define ROOM_TEMPERATURE @"房間溫度"
#define ROOM_HUMIDITY @"房間濕度"

@interface ExportSettingsViewController ()
{
    HTTPComm *httpComm;
    UIImage *originButtonImage;
    UIImage *buttonImage;
    UIImage *greyButtonImage;
    ExportCSVFile *exportCSV;
    ConfigManager *config;
    NSArray *allSensorsInfo;
    AllSensors *allSensors;
    BOOL isDisplayRealChart;
    NSMutableArray *sensorsButton;
    UITextField *startDateTextField;
    UITextField *endDateTextField;
}

@property(nonatomic,strong) UIDatePicker *datePicker;
@end

@implementation ExportSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    exportCSV = [ExportCSVFile new];
    
    allSensors = [AllSensors sharedInstance];
    allSensorsInfo = [allSensors getAllSensorsInfo];
    sensorsButton = [NSMutableArray array];
    
    
    // 準備導覽列上按鈕
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pressConfirmButtonToGenerateCSV:)];
    
    // 放上導覽列
    self.navigationItem.rightBarButtonItems = @[addItem];
    
    
    Sensor *sensor = [Sensor new];
    
    CGFloat xIndex = 40;
    CGFloat yIndex = 80;
    CGFloat wIndex = self.view.bounds.size.width/2 - 100;
    
    for(int i = 0; i < [allSensors getSensorsCount]; i++) {
        
        sensor = allSensorsInfo[i];
        
        // create UIButton
        CGRect buttonFrame = CGRectMake( xIndex, yIndex, wIndex, 90 );
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
            yIndex += 100;
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
    UIButton *generateCSV = [UIButton buttonWithType:UIButtonTypeSystem];
    generateCSV.frame = CGRectMake(100, yIndex, 100, 30);
    [generateCSV setTitle:@"SAVE File" forState:UIControlStateNormal];
    [generateCSV setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [generateCSV setBackgroundColor:[UIColor whiteColor]];
    [generateCSV sizeToFit];
    [generateCSV addTarget:self action:@selector(saveBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:generateCSV];
    

    
}


- (IBAction)saveBtnPressed:(id)sender{
    UIAlertController *giveFileName = [UIAlertController alertControllerWithTitle:@"檔案名稱" message:@"請輸入檔案名稱" preferredStyle:UIAlertControllerStyleAlert];
    
    [giveFileName addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"在此輸入檔名";
        }];
    UIAlertAction *save = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // Save CSV File
        exportCSV = [ExportCSVFile sharedInstance];
        [exportCSV prepareDataForGenerateCSV:@"1"
                                    fileName:giveFileName.textFields[0].text
                                    startDate:startDateTextField.text
                                     endDate:endDateTextField.text];
       
    }];
    [giveFileName addAction:save];
    [self presentViewController:giveFileName animated:true completion:nil];
    
    
    /*
    exportCSV = [ExportCSVFile new];
    [exportCSV prepareDataForGenerateCSV:@"1" startDate:startDateTextField.text endDate:endDateTextField.text];
     */

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



// FOR TEST


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
