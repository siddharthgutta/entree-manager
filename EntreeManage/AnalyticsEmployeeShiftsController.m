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
    NSDateFormatter *dateFormat = ({id d = [NSDateFormatter new]; [d setDateFormat:@"dd-MM-yyyy"]; d; });
    _startDateText.text         = [dateFormat stringFromDate:startDate];
    _endDateText.text           = [dateFormat stringFromDate:endDate];
    
    [CommParse getAnalyticsEmployeeShifts:self startDate:startDate endDate:endDate];
}

- (void)exportItemClicked {
    NSString *title = [NSString stringWithFormat:@"%@ (%@ ~ %@)", @"Analytics Category Sales", _startDateText.text, _endDateText.text];
    NSString *content = @"Employee,Date,Clocked In,Clocked Out,Hours Worked,Tips";
    
    for(PFObject *shiftObj in results) {
        PFObject *empObj = shiftObj[@"employee"];
        NSString *empName = empObj[@"name"];
        
        NSDate *startDate = shiftObj[@"startedAt"];
        NSDate *endDate = shiftObj[@"endedAt"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd-MM-yy"];
        
        
        [dateFormat setDateFormat:@"hh:mm a"];
        // Start Time
        NSString *startText = [dateFormat stringFromDate: startDate];
        
        // End Time
        NSString *endText = [dateFormat stringFromDate: endDate];
        
        // calculate Time
        NSTimeInterval timeDifference = [endDate timeIntervalSinceDate:startDate];
        
        // Hours worked
        CGFloat hoursDiff =  timeDifference/3600;
        
        
        // Tips
        CGFloat hourlyWage = [empObj[@"hourlyWage"] floatValue];
        CGFloat tips = hourlyWage *hoursDiff;
        
        
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
    
    PFObject *shiftObj = results[indexPath.row];
    PFObject *empObj = shiftObj[@"employee"];
    
    NSString *empName = empObj[@"name"];
    
    // employee name
    label = (UILabel *)[cell viewWithTag:6];
    label.text = empName;
    
    NSDate *startDate = shiftObj[@"startedAt"];
    NSDate *endDate = shiftObj[@"endedAt"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yy"];
    
    NSString *dateText = [dateFormat stringFromDate: startDate];
    // Date
    label = (UILabel *)[cell viewWithTag:1];
    label.text = dateText;
    
    [dateFormat setDateFormat:@"hh:mm a"];
    dateText = [dateFormat stringFromDate: startDate];
    // Start Time
    label = (UILabel *)[cell viewWithTag:2];
    label.text = dateText;
    
    dateText = [dateFormat stringFromDate: endDate];
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
    CGFloat hourlyWage = [empObj[@"hourlyWage"] floatValue];
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
    NSDate *selDate = [_datePicker date];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    NSString *dateText = [dateFormat stringFromDate: selDate];
    if (startDate_Flag)  _startDateText.text = dateText;
    else _endDateText.text = dateText;
    
    _pickDateView.hidden = true;
    NSDate *startDate = [dateFormat dateFromString: _startDateText.text];
    NSDate *endDate = [dateFormat dateFromString: _endDateText.text];
    // from start day 00:00 to end day 24:00
    endDate = [endDate dateByAddingTimeInterval:24*3600];
    
    if (startDate && endDate) {
        [CommParse getAnalyticsEmployeeShifts:self startDate:startDate endDate:endDate];
    }
}

- (IBAction)onTouchTextStartDate:(id)sender {
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



@end
