//
//  AnalyticsEmployeeShiftsController.m
//  EntreeManage
//
//  Created by Faraz on 8/6/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "AnalyticsEmployeeShiftsController.h"

@interface AnalyticsEmployeeShiftsController () <CommsDelegate, UITableViewDelegate, UITableViewDataSource>{
    NSMutableArray *results;
    NSMutableArray *sumVal;
    // if selected text is start date then true
    BOOL startDate_Flag;
    
}

@property (weak, nonatomic) IBOutlet UITableView *analTableView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (weak, nonatomic) IBOutlet UITextField *startDateText;
@property (weak, nonatomic) IBOutlet UITextField *endDateText;

@property (weak, nonatomic) IBOutlet UIView *pickDateView;

- (IBAction)onChangedDate:(id)sender;
- (IBAction)onTouchTextStartDate:(id)sender;
- (IBAction)onTouchTextEndDate:(id)sender;

@end

@implementation AnalyticsEmployeeShiftsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _pickDateView.hidden = true;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(exportItemClicked)];
    
    self.navigationItem.hidesBackButton = YES;
    self.title = @"Employee Shift Log";
    
    // Previous month's data
    NSDate *startDate = [NSDate date30DaysAgo];
    NSDate *endDate   = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM-dd-yyyy";
    
    self.startDateText.text = [dateFormatter stringFromDate:startDate];
    self.endDateText.text = [dateFormatter stringFromDate:endDate];
    
    [CommParse getAnalyticsEmployeeShifts:self startDate:startDate endDate:endDate];
}

- (void)exportItemClicked {
    NSString *title = [NSString stringWithFormat:@"%@ (%@ ~ %@)", @"Analytics Category Sales", _startDateText.text, _endDateText.text];
    NSString *content = @"Employee,Date,Clocked In,Clocked Out,Hours Worked,Tips";
    
    for(Shift *shift in results) {
        Employee *employee = shift.employee;
        NSString *empName = employee.name;
        
        NSDate *startDate = shift.startedAt;
        NSDate *endDate = shift.endedAt;
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [[NSDateFormatter shared] setDateFormat:@"hh:mm a"];
        
        NSString *startText           = [dateFormatter stringFromDate: startDate];
        NSString *endText             = [dateFormatter stringFromDate: endDate];
        
        NSTimeInterval timeDifference = [endDate timeIntervalSinceDate:startDate];
        CGFloat hoursDiff             = timeDifference/3600;
        
        // Tips
        CGFloat tips = employee.hourlyWage *hoursDiff;
        
        content = [NSString stringWithFormat:@"%@ \n %@,%@,%@,%.02f,%.02f", content, empName, startText, endText, hoursDiff, tips];
    }
    
    // export with csv format
    [CommParse sendEmailwithMailGun:self userEmail:@"" emailSubject:title emailContent:content];
}

#pragma mark - Table view data source
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *CellIdentifier = @"AnalyticsTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = @"Employee";
    
    label = (UILabel *)[cell viewWithTag:2];
    label.text = @"Date";
    
    label = (UILabel *)[cell viewWithTag:3];
    label.text = @"Clocked In";
    
    label = (UILabel *)[cell viewWithTag:4];
    label.text = @"Clocked Out";
    
    label = (UILabel *)[cell viewWithTag:5];
    label.text = @"Hours Worked";
    
    label = (UILabel *)[cell viewWithTag:6];
    label.text = @"Tips";
    
    [cell setBackgroundColor:[UIColor lightGrayColor]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return results.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"AnalyticsTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    UILabel *label;
    
    Shift *shift = results[indexPath.row];
    Employee *employee = shift.employee;
    
    NSString *empName = employee.name;
    
    // employee name
    label = (UILabel *)[cell viewWithTag:6];
    label.text = empName;
    
    NSDate *startDate = shift.startedAt;
    NSDate *endDate = shift.endedAt;
    
    NSString *dateText = [[NSDateFormatter shared] stringFromDate: startDate];
    // Date
    label = (UILabel *)[cell viewWithTag:1];
    label.text = dateText;
    
    [[NSDateFormatter shared] setDateFormat:@"hh:mm a"];
    dateText = [[NSDateFormatter shared] stringFromDate: startDate];
    // Start Time
    label = (UILabel *)[cell viewWithTag:2];
    label.text = dateText;
    
    dateText = [[NSDateFormatter shared] stringFromDate: endDate];
    // End Time
    label = (UILabel *)[cell viewWithTag:3];
    label.text = dateText;
    
    // calculate Time
    NSTimeInterval timeDifference = [endDate timeIntervalSinceDate:startDate];
    CGFloat hoursDiff =  timeDifference/3600;
    
    // Hours worked
    label = (UILabel *)[cell viewWithTag:4];
    label.text = [NSString stringWithFormat:@"%.03f", hoursDiff];
    
    // Tips
    CGFloat hourlyWage = employee.hourlyWage;
    CGFloat tips = hourlyWage *hoursDiff;
    
    label = (UILabel *)[cell viewWithTag:5];
    label.text = [NSString stringWithFormat:@"%.02f", tips];
    
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)commsDidAction:(NSDictionary *)response {
    [ProgressHUD dismiss];
    if ([response[@"responseCode"] boolValue]) {
        results = response[@"objects"];
        [_analTableView reloadData];
    }
    else {
        [ProgressHUD showError:[response valueForKey:@"errorMsg"]];
    }
}


- (IBAction)onChangedDate:(id)sender {
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
        [CommParse getAnalyticsEmployeeShifts:self startDate:startDate endDate:endDate];
    }
}

- (IBAction)onTouchTextStartDate:(id)sender {
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



@end
