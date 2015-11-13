//
//  AnalyticsEmployeeShiftsController.m
//  EntreeManage
//
//  Created by Faraz on 8/6/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "AnalyticsEmployeeShiftsController.h"

<<<<<<< HEAD
@interface AnalyticsEmployeeShiftsController ()<CommsDelegate, UITableViewDelegate, UITableViewDataSource>{
    
    NSMutableArray *resultArray;
    NSMutableArray *sumVal;

    //if selected text is start date then true
=======
@interface AnalyticsEmployeeShiftsController () <CommsDelegate, UITableViewDelegate, UITableViewDataSource>{
    NSMutableArray *results;
    NSMutableArray *sumVal;
    // if selected text is start date then true
>>>>>>> origin/tanner
    BOOL startDate_Flag;
    
}

@property (weak, nonatomic) IBOutlet UITableView *analTableView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (weak, nonatomic) IBOutlet UITextField *startDateText;
@property (weak, nonatomic) IBOutlet UITextField *endDateText;

<<<<<<< HEAD
- (IBAction)onChangedDate:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *pickDateView;
=======
@property (weak, nonatomic) IBOutlet UIView *pickDateView;

- (IBAction)onChangedDate:(id)sender;
>>>>>>> origin/tanner
- (IBAction)onTouchTextStartDate:(id)sender;
- (IBAction)onTouchTextEndDate:(id)sender;

@end

@implementation AnalyticsEmployeeShiftsController

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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(exportItemClicked)];
>>>>>>> origin/tanner
    
    self.navigationItem.hidesBackButton = YES;
    self.title = @"Employee Shift Log";
    
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
    
    
    [CommParse getAnalyticsEmployeeShifts:self StartDate:start_date EndDate:NSDate.date];
    
}
// On Export
-(void)exportItemClicked{
    
    NSString *title;
    title = [NSString stringWithFormat:@"%@ (%@ ~ %@)", @"Analytics Category Sales", _startDateText.text, _endDateText.text];
    
    NSString *content;;
    content = @"Employee,Date,Clocked In,Clocked Out,Hours Worked,Tips";
    
    for(int i=0; i< [resultArray count]; i++) {
    
        PFObject *shift_obj = [resultArray objectAtIndex:i];
        
        PFObject *emp_obj = [shift_obj objectForKey:@"employee"];
        
        NSString *emp_name = [emp_obj objectForKey:@"name"];
        
        NSDate *startDate = [shift_obj objectForKey:@"startedAt"];
        NSDate *endDate = [shift_obj objectForKey:@"endedAt"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd-MM-yy"];
        
        
        [dateFormat setDateFormat:@"hh:mm a"];
        //Start Time
        NSString *startText = [dateFormat stringFromDate: startDate];
        
        //End Time
        NSString *endText = [dateFormat stringFromDate: endDate];
        
        //calculate Time
        NSTimeInterval timeDifference = [endDate timeIntervalSinceDate:startDate];
        
        //Hours worked
        float hoursDiff =  timeDifference/3600;
        
        
        //Tips
        float hourlyWage = [[emp_obj objectForKey:@"hourlyWage"] floatValue];
        float tips = hourlyWage * hoursDiff;
        
    
        content = [NSString stringWithFormat:@"%@ \n %@,%@,%@,%.02f,%.02f", content, emp_name, startText, endText, hoursDiff, tips];
    }
    
    //export with csv format
    [CommParse sendEmailwithMailGun:self userEmail:@"" EmailSubject:title EmailContent:content];
    
}
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
    label.text = @"Date";
    
    label = (UILabel*) [cell viewWithTag:3];
    label.text = @"Clocked In";
    
    label = (UILabel*) [cell viewWithTag:4];
    label.text = @"Clocked Out";
    
    label = (UILabel*) [cell viewWithTag:5];
    label.text = @"Hours Worked";

    label = (UILabel*) [cell viewWithTag:6];
=======
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
>>>>>>> origin/tanner
    label.text = @"Tips";
    
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
    UILabel *label;
    
<<<<<<< HEAD
    PFObject *shift_obj = [resultArray objectAtIndex:indexPath.row];
    
    PFObject *emp_obj = [shift_obj objectForKey:@"employee"];
    
    
    NSString *emp_name = [emp_obj objectForKey:@"name"];
    
    //employee name
    label = (UILabel*) [cell viewWithTag:6];
    label.text = emp_name;
    
    NSDate *startDate = [shift_obj objectForKey:@"startedAt"];
    NSDate *endDate = [shift_obj objectForKey:@"endedAt"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yy"];
    
    NSString *dateText = [dateFormat stringFromDate: startDate];
    //Date
    label = (UILabel*) [cell viewWithTag:1];
    label.text = dateText;
    
    [dateFormat setDateFormat:@"hh:mm a"];
    dateText = [dateFormat stringFromDate: startDate];
    //Start Time
    label = (UILabel*) [cell viewWithTag:2];
    label.text = dateText;
    
    dateText = [dateFormat stringFromDate: endDate];
    //End Time
    label = (UILabel*) [cell viewWithTag:3];
    label.text = dateText;
    
    //calculate Time
    NSTimeInterval timeDifference = [endDate timeIntervalSinceDate:startDate];
    float hoursDiff =  timeDifference/3600;
    
    //Hours worked
    label = (UILabel*) [cell viewWithTag:4];
    label.text = [NSString stringWithFormat:@"%.03f", hoursDiff];
    
    //Tips
    float hourlyWage = [[emp_obj objectForKey:@"hourlyWage"] floatValue];
    float tips = hourlyWage * hoursDiff;
    
    label = (UILabel*) [cell viewWithTag:5];
=======
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
>>>>>>> origin/tanner
    label.text = [NSString stringWithFormat:@"%.02f", tips];
    
    
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
=======
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)commsDidAction:(NSDictionary *)response {
    [ProgressHUD dismiss];
    if ([response[@"responseCode"] boolValue]) {
        results = response[@"objects"];
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
        [CommParse getAnalyticsEmployeeShifts:self StartDate:startDate EndDate:endDate];
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
        [CommParse getAnalyticsEmployeeShifts:self startDate:startDate endDate:endDate];
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
>>>>>>> origin/tanner
}



@end
