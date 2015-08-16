//
//  AnalyticsEmployeeShiftsController.m
//  EntreeManage
//
//  Created by Faraz on 8/6/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "AnalyticsEmployeeShiftsController.h"

@interface AnalyticsEmployeeShiftsController ()<CommsDelegate, UITableViewDelegate, UITableViewDataSource>{
    
    NSMutableArray *resultArray;
    NSMutableArray *sumVal;

    //if selected text is start date then true
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

@implementation AnalyticsEmployeeShiftsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    _pickDateView.hidden = true;
    
    // Do any additional setup after loading the view.
    UIBarButtonItem *exportButton = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(exportItemClicked)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:exportButton, nil];
    
    self.navigationItem.hidesBackButton = YES;
    self.title = @"Employee Shift Log";
    
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
    
    [cell setBackgroundColor:[UIColor lightGrayColor]];
    
    return cell;
}

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
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * CellIdentifier = @"AnalyticsTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    UILabel *label;
    
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
    label.text = [NSString stringWithFormat:@"%.02f", tips];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}

- (void)commsDidAction:(NSDictionary *)response
{
    [ProgressHUD dismiss];
    if ([[response objectForKey:@"responseCode"] boolValue]) {
        
        resultArray = [response objectForKey:@"objects"];
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
    NSString *dateText = [dateFormat stringFromDate: selDate];
    if(startDate_Flag)  _startDateText.text = dateText;
    else _endDateText.text = dateText;
    
    _pickDateView.hidden = true;
    NSDate *startDate = [dateFormat dateFromString: _startDateText.text];
    NSDate *endDate = [dateFormat dateFromString: _endDateText.text];
    
    if(startDate && endDate) {
        [CommParse getAnalyticsEmployeeShifts:self StartDate:startDate EndDate:endDate];
    }
}

- (IBAction)onTouchTextStartDate:(id)sender {
    startDate_Flag = true;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    NSDate *date = [dateFormat dateFromString: _startDateText.text];
    [_datePicker setDate:date];
    
    _pickDateView.hidden = false;
}

- (IBAction)onTouchTextEndDate:(id)sender {
    startDate_Flag = false;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    NSDate *date = [dateFormat dateFromString: _endDateText.text];
    [_datePicker setDate:date];
    
    _pickDateView.hidden = false;
}



@end
