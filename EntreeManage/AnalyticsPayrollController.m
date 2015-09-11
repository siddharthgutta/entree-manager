//
//  AnalyticsPayrollController.m
//  EntreeManage
//
//  Created by Faraz on 8/6/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "AnalyticsPayrollController.h"

@interface AnalyticsPayrollController ()<CommsDelegate, UITableViewDelegate, UITableViewDataSource>{
    
    NSMutableDictionary *results;
    NSArray *keys;
    // if selected text is start date then true
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
    _pickDateView.hidden = true;
    
    UIBarButtonItem *exportButton = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(exportItemClicked)];
    
    self.navigationItem.rightBarButtonItems = @[exportButton];
    
    self.navigationItem.hidesBackButton = YES;
    self.title = @"Employee Overview";
    
    // Previous month's data
    NSDate *startDate   = [NSDate date30DaysAgo];
    NSDate *endDate     = [NSDate date];
    _startDateText.text = [[NSDateFormatter shared] stringFromDate:startDate];
    _endDateText.text   = [[NSDateFormatter shared] stringFromDate:endDate];
    
    [CommParse getAnalyticsPayroll:self startDate:startDate endDate:endDate];
    
}
// On Export
- (void)exportItemClicked {
    
NSString *title = [NSString stringWithFormat:@"%@ (%@ ~ %@)", @"Analytics Employee Overview", _startDateText.text, _endDateText.text];
    
    NSString *content;;
    content = @"Employee,Hours Worked,Tips,Hourly Wage,$ Owed";
    
    NSMutableArray *emps;
    for(NSString *key in keys){
        emps = results[key];
       
        
        // owed $ = hourly wage *hours worked + tips
        CGFloat temp = [emps[1] floatValue] * [emps[3] floatValue] + [emps[2] floatValue];
        
        content = [NSString stringWithFormat:@"%@ \n %@,%.02f,%.02f,%.02f,%.02f", content, emps[0], [emps[1] floatValue], [emps[2] floatValue], [emps[3] floatValue], temp ];
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
    label.text = @"Hours Worked";
    
    label = (UILabel *)[cell viewWithTag:3];
    label.text = @"Tips";
    
    label = (UILabel *)[cell viewWithTag:4];
    label.text = @"Hourly Wage";
    
    label = (UILabel *)[cell viewWithTag:5];
    label.text = @"$ Owed";
    
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
    label.text = [NSString stringWithFormat:@"%.02f", temp];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)commsDidAction:(NSDictionary *)response {
    [ProgressHUD dismiss];
    if ([response[@"responseCode"] boolValue]) {
        
        results = response[@"objects"];
        keys = [results allKeys];
        
        [_analTableView reloadData];
    }
    else {
        [ProgressHUD showError:[response valueForKey:@"errorMsg"]];
    }
}


- (IBAction)onChangedDate:(id)sender {
    NSDate *selDate = [_datePicker date];
    


    NSString *dateText = [[NSDateFormatter shared] stringFromDate: selDate];
    if (startDate_Flag)  _startDateText.text = dateText;
    else _endDateText.text = dateText;
    
    _pickDateView.hidden = true;
    NSDate *startDate = [[NSDateFormatter shared] dateFromString: _startDateText.text];
    NSDate *endDate = [[NSDateFormatter shared] dateFromString: _endDateText.text];
    // from start day 00:00 to end day 24:00
    endDate = [endDate dateByAddingTimeInterval:24*3600];

    if (startDate && endDate) {
        [CommParse getAnalyticsPayroll:self startDate:startDate endDate:endDate];
    }
}

- (IBAction)onTouchTextStartDate:(id)sender {
    startDate_Flag = true;


    NSDate *date = [[NSDateFormatter shared] dateFromString: _startDateText.text];
    [_datePicker setDate:date];
    
    _pickDateView.hidden = false;
}

- (IBAction)onTouchTextEndDate:(id)sender {
    startDate_Flag = false;


    NSDate *date = [[NSDateFormatter shared] dateFromString: _endDateText.text];
    [_datePicker setDate:date];
    
    _pickDateView.hidden = false;
}


@end
