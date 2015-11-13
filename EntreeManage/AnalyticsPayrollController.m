//
//  AnalyticsPayrollController.m
//  EntreeManage
//
//  Created by Faraz on 8/6/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "AnalyticsPayrollController.h"

@interface AnalyticsPayrollController ()<CommsDelegate, UITableViewDelegate, UITableViewDataSource>{
    
<<<<<<< HEAD
    NSMutableDictionary *resultArray;
    NSArray *keyArray;
    //if selected text is start date then true
=======
    NSMutableDictionary *results;
    NSArray *keys;
    // if selected text is start date then true
>>>>>>> origin/tanner
    BOOL startDate_Flag;
    
}

@property (weak, nonatomic) IBOutlet UITableView *analTableView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (weak, nonatomic) IBOutlet UITextField *startDateText;
@property (weak, nonatomic) IBOutlet UITextField *endDateText;

- (IBAction)onChangedDate:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *pickDateView;
- (IBAction)onTouchTextStartDate:(id)sender;
- (IBAction)onTouchTextEndDate:(id)sender;

@end

@implementation AnalyticsPayrollController

- (void)viewDidLoad {
    [super viewDidLoad];
<<<<<<< HEAD
    // Do any additional setup after loading the view.
    _pickDateView.hidden = true;
    
    // Do any additional setup after loading the view.
    UIBarButtonItem *exportButton = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(exportItemClicked)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:exportButton, nil];
=======
    _pickDateView.hidden = true;
    
    UIBarButtonItem *exportButton = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(exportItemClicked)];
    
    self.navigationItem.rightBarButtonItems = @[exportButton];
>>>>>>> origin/tanner
    
    self.navigationItem.hidesBackButton = YES;
    self.title = @"Employee Overview";
    
<<<<<<< HEAD
    //get previous month
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear fromDate:NSDate.date];
    comps.month-=1;
    NSDate *start_date = [cal dateFromComponents:comps];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    NSString *dateText = [dateFormat stringFromDate: start_date];
    _startDateText.text = dateText;
    dateText = [dateFormat stringFromDate: NSDate.date];
    _endDateText.text = dateText;
    
    
    [CommParse getAnalyticsPayroll:self StartDate:start_date EndDate:NSDate.date];
    
}
// On Export
-(void)exportItemClicked{
    
    NSString *title;
    title = [NSString stringWithFormat:@"%@ (%@ ~ %@)", @"Analytics Employee Overview", _startDateText.text, _endDateText.text];
=======
    // Previous month's data
    NSDate *startDate = [NSDate date30DaysAgo];
    NSDate *endDate   = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM-dd-yyyy";
    
    self.startDateText.text = [dateFormatter stringFromDate:startDate];
    self.endDateText.text = [dateFormatter stringFromDate:endDate];
    
    [CommParse getAnalyticsPayroll:self startDate:startDate endDate:endDate];
    
}
// On Export
- (void)exportItemClicked {
    
NSString *title = [NSString stringWithFormat:@"%@ (%@ ~ %@)", @"Analytics Employee Overview", _startDateText.text, _endDateText.text];
>>>>>>> origin/tanner
    
    NSString *content;;
    content = @"Employee,Hours Worked,Tips,Hourly Wage,$ Owed";
    
<<<<<<< HEAD
    NSMutableArray *empArray;
    for(NSString *key in keyArray){
        empArray =[resultArray objectForKey:key];
       
        
        //owed $ = hourly wage * hours worked + tips
        float temp = [empArray[1] floatValue] *[empArray[3] floatValue] + [empArray[2] floatValue];
        
        content = [NSString stringWithFormat:@"%@ \n %@,%.02f,%.02f,%.02f,%.02f", content, empArray[0], [empArray[1] floatValue], [empArray[2] floatValue], [empArray[3] floatValue], temp ];
        
    }
    
    //export with csv format
    [CommParse sendEmailwithMailGun:self userEmail:@"" EmailSubject:title EmailContent:content];
=======
    NSMutableArray *emps;
    for(NSString *key in keys){
        emps = results[key];
       
        
        // owed $ = hourly wage *hours worked + tips
        CGFloat temp = [emps[1] floatValue] * [emps[3] floatValue] + [emps[2] floatValue];
        
        content = [NSString stringWithFormat:@"%@ \n %@,%.02f,%.02f,%.02f,%.02f", content, emps[0], [emps[1] floatValue], [emps[2] floatValue], [emps[3] floatValue], temp ];
    }
    
    // export with csv format
    [CommParse sendEmailwithMailGun:self userEmail:@"" emailSubject:title emailContent:content];
>>>>>>> origin/tanner
   
    
}

<<<<<<< HEAD
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    static NSString * CellIdentifier = @"AnalyticsTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    UILabel *label;
    label = (UILabel*) [cell viewWithTag:1];
    label.text = @"Employee";
    
    label = (UILabel*) [cell viewWithTag:2];
    label.text = @"Hours Worked";
    
    label = (UILabel*) [cell viewWithTag:3];
    label.text = @"Tips";
    
    label = (UILabel*) [cell viewWithTag:4];
    label.text = @"Hourly Wage";
    
    label = (UILabel*) [cell viewWithTag:5];
=======

#pragma mark - Table view data source
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *CellIdentifier = @"AnalyticsTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = @"Employee";
    
    label = (UILabel *)[cell viewWithTag:2];
    label.text = @"Hours Worked";
    
    label = (UILabel *)[cell viewWithTag:3];
    label.text = @"Tips";
    
    label = (UILabel *)[cell viewWithTag:4];
    label.text = @"Hourly Wage";
    
    label = (UILabel *)[cell viewWithTag:5];
>>>>>>> origin/tanner
    label.text = @"$ Owed";
    
    [cell setBackgroundColor:[UIColor lightGrayColor]];
    
    return cell;
}

<<<<<<< HEAD
-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [resultArray count];
=======
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return results.count;
>>>>>>> origin/tanner
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
<<<<<<< HEAD
    static NSString * CellIdentifier = @"AnalyticsTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil){
=======
    static NSString *CellIdentifier = @"AnalyticsTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
>>>>>>> origin/tanner
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
<<<<<<< HEAD
    NSMutableArray * empArray;
    
    NSString *key = [keyArray objectAtIndex:indexPath.row];
    
    empArray =[resultArray objectForKey:key];
    
    UILabel *label;
    label = (UILabel*) [cell viewWithTag:1];
    label.text = empArray[0];
    
    label = (UILabel*) [cell viewWithTag:2];
    label.text = [NSString stringWithFormat:@"%.02f", [empArray[1] floatValue]];
    
    label = (UILabel*) [cell viewWithTag:3];
    label.text = [NSString stringWithFormat:@"%.02f", [empArray[2] floatValue]];

    label = (UILabel*) [cell viewWithTag:4];
    label.text = [NSString stringWithFormat:@"%.02f", [empArray[3] floatValue]];
    
    //owed $ = hourly wage * hours worked + tips
    float temp = [empArray[1] floatValue] *[empArray[3] floatValue] + [empArray[2] floatValue];
    label = (UILabel*) [cell viewWithTag:5];
=======
    NSMutableArray *emps;
    
    NSString *key = keys[indexPath.row];
    
    emps = results[key];
    
UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = emps[0];
    
    label = (UILabel *)[cell viewWithTag:2];
    label.text = [NSString stringWithFormat:@"%.02f", [emps[1] floatValue]];
    
    label = (UILabel *)[cell viewWithTag:3];
    label.text = [NSString stringWithFormat:@"%.02f", [emps[2] floatValue]];

    label = (UILabel *)[cell viewWithTag:4];
    label.text = [NSString stringWithFormat:@"%.02f", [emps[3] floatValue]];
    
    // owed $ = hourly wage *hours worked + tips
    CGFloat temp = [emps[1] floatValue] *[emps[3] floatValue] + [emps[2] floatValue];
    label = (UILabel *)[cell viewWithTag:5];
>>>>>>> origin/tanner
    label.text = [NSString stringWithFormat:@"%.02f", temp];
    
    return cell;
}

<<<<<<< HEAD
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}

- (void)commsDidAction:(NSDictionary *)response
{
    [ProgressHUD dismiss];
    if ([[response objectForKey:@"responseCode"] boolValue]) {
        
        resultArray = [response objectForKey:@"objects"];
        keyArray = [resultArray allKeys];
=======
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)commsDidAction:(NSDictionary *)response {
    [ProgressHUD dismiss];
    if ([response[@"responseCode"] boolValue]) {
        
        results = response[@"objects"];
        keys = [results allKeys];
>>>>>>> origin/tanner
        
        [_analTableView reloadData];
    }
    else {
        [ProgressHUD showError:[response valueForKey:@"errorMsg"]];
<<<<<<< HEAD
        
=======
>>>>>>> origin/tanner
    }
}


- (IBAction)onChangedDate:(id)sender {
<<<<<<< HEAD
    NSDate *selDate = [_datePicker date];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];

    NSString *dateText = [dateFormat stringFromDate: selDate];
    if(startDate_Flag)  _startDateText.text = dateText;
    else _endDateText.text = dateText;
    
    _pickDateView.hidden = true;
    NSDate *startDate = [dateFormat dateFromString: _startDateText.text];
    NSDate *endDate = [dateFormat dateFromString: _endDateText.text];
    //from start day 00:00 to end day 24:00
    endDate = [endDate dateByAddingTimeInterval:24*3600];

    if(startDate && endDate) {
        [CommParse getAnalyticsPayroll:self StartDate:startDate EndDate:endDate];
=======
    // Jesse rew-rote this.
    NSDate *selectedDate = _datePicker.date;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM-dd-yyyy";
    
    NSString *dateString = [dateFormatter stringFromDate:selectedDate];
    if (startDate_Flag) {
        self.startDateText.text = dateString;
    } else {
        self.endDateText.text = dateString;
    }
    
    self.pickDateView.hidden = YES;
    
    NSDate *startDate = [dateFormatter dateFromString: self.startDateText.text];
    NSDate *endDate = [[dateFormatter dateFromString: self.endDateText.text] dateByAddingTimeInterval:86400];
    if (startDate && endDate) {
        [CommParse getAnalyticsPayroll:self startDate:startDate endDate:endDate];
>>>>>>> origin/tanner
    }
}

- (IBAction)onTouchTextStartDate:(id)sender {
<<<<<<< HEAD
    startDate_Flag = true;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];

    NSDate *date = [dateFormat dateFromString: _startDateText.text];
    [_datePicker setDate:date];
    
    _pickDateView.hidden = false;
}

- (IBAction)onTouchTextEndDate:(id)sender {
    startDate_Flag = false;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];

    NSDate *date = [dateFormat dateFromString: _endDateText.text];
    [_datePicker setDate:date];
    
    _pickDateView.hidden = false;
}


=======
    // Jesse rew-rote this.
    startDate_Flag = YES;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM-dd-yyyy";
    
    NSDate *date = [dateFormatter dateFromString: self.startDateText.text];
    [self.datePicker setDate:date];
    
    self.pickDateView.frame = CGRectMake(200, 140, 390, 0);
    self.pickDateView.hidden = false;
    [UIView animateWithDuration:1.0  animations:^ {
        self.pickDateView.frame = CGRectMake(200, 140, 390, 270);
    }];
}

- (IBAction)onTouchTextEndDate:(id)sender {
    // Jesse rew-rote this.
    startDate_Flag = NO;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM-dd-yyyy";
    
    NSDate *date = [[NSDateFormatter shared] dateFromString: self.endDateText.text];
    [self.datePicker setDate:date];
    
    self.pickDateView.frame = CGRectMake(200, 140, 390, 0);
    self.pickDateView.hidden = false;
    [UIView animateWithDuration:1.0  animations:^ {
        self.pickDateView.frame = CGRectMake(200,140,390,270);
    }];
}

>>>>>>> origin/tanner
@end
