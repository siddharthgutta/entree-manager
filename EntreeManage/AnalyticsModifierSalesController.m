//
//  AnalyticsModifierSalesController.m
//  EntreeManage
//
//  Created by Faraz on 8/6/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "AnalyticsModifierSalesController.h"

@interface AnalyticsModifierSalesController ()<CommsDelegate, UITableViewDelegate, UITableViewDataSource>{
    
    NSMutableDictionary *resultArray;
    NSMutableDictionary *timesArray;
    NSArray *keyArray;
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

@implementation AnalyticsModifierSalesController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _pickDateView.hidden = true;
    
    UIBarButtonItem *exportButton = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(exportItemClicked)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:exportButton, nil];
    
    self.navigationItem.hidesBackButton = YES;
    self.title = @"Modifiers Overview";
    
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
    
    
    [CommParse getAnalyticsModifierSales:self StartDate:start_date EndDate:NSDate.date];
}
// On Export
-(void)exportItemClicked{
    
    NSString *title;
    title = [NSString stringWithFormat:@"%@ (%@ ~ %@)", @"Analytics Modifiers Overview", _startDateText.text, _endDateText.text];
    
    NSString *content;;
    content = @"Modifiers,Item,Category,Times Applied,Sales";
    
    NSMutableArray *itemArray;
    for(NSString *key in keyArray){
        itemArray =resultArray[key];
        
        content = [NSString stringWithFormat:@"%@ \n %@,%@,%@,%.02f,%.02f", content, itemArray[0], itemArray[1], itemArray[2], [itemArray[3] floatValue], [itemArray[4] floatValue] ];
        
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
    label.text = @"Modifiers";
    
    label = (UILabel*) [cell viewWithTag:2];
    label.text = @"Item";
    
    label = (UILabel*) [cell viewWithTag:3];
    label.text = @"Category";
    
    label = (UILabel*) [cell viewWithTag:4];
    label.text = @"Times Applied";
    
    label = (UILabel*) [cell viewWithTag:5];
    label.text = @"Sales";
    
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
    NSMutableArray * itemArray;
    
    NSString *key = [keyArray objectAtIndex:indexPath.row];
    
    itemArray =resultArray[key];
    
    UILabel *label;
    label = (UILabel*) [cell viewWithTag:1];
    label.text = itemArray[0];
    
    label = (UILabel*) [cell viewWithTag:2];
    label.text = itemArray[1];
    
    label = (UILabel*) [cell viewWithTag:3];
    label.text = itemArray[2];
    
    label = (UILabel*) [cell viewWithTag:4];
    label.text = [NSString stringWithFormat:@"%d", [[timesArray objectForKey:itemArray[3]] intValue] ];
    
    label = (UILabel*) [cell viewWithTag:5];
    label.text = [NSString stringWithFormat:@"%.02f", [itemArray[4] floatValue]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}


- (void)commsDidAction:(NSDictionary *)response
{
    [ProgressHUD dismiss];
    if ([response[@"responseCode"] boolValue]) {
        
        resultArray = response[@"objects"];
        timesArray = response[@"time_objects"];
        keyArray = [resultArray allKeys];
        
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
    if(startDate_Flag)  _startDateText.text = dateText;
    else _endDateText.text = dateText;
    
    _pickDateView.hidden = true;
    NSDate *startDate = [dateFormat dateFromString: _startDateText.text];
    NSDate *endDate = [dateFormat dateFromString: _endDateText.text];
    //from start day 00:00 to end day 24:00
    endDate = [endDate dateByAddingTimeInterval:24*3600];
    
    if(startDate && endDate) {
        [CommParse getAnalyticsModifierSales:self StartDate:startDate EndDate:endDate];
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
