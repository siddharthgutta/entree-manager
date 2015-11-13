//
//  AnalyticsModifierSalesController.m
//  EntreeManage
//
//  Created by Faraz on 8/6/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "AnalyticsModifierSalesController.h"

@interface AnalyticsModifierSalesController ()<CommsDelegate, UITableViewDelegate, UITableViewDataSource>{
    
<<<<<<< HEAD
    NSMutableDictionary *resultArray;
    NSMutableDictionary *timesArray;
    NSArray *keyArray;
    //if selected text is start date then true
=======
    NSMutableDictionary *results;
    NSMutableDictionary *timess;
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

@implementation AnalyticsModifierSalesController

- (void)viewDidLoad {
    [super viewDidLoad];
<<<<<<< HEAD
    // Do any additional setup after loading the view.
=======
>>>>>>> origin/tanner
    _pickDateView.hidden = true;
    
    UIBarButtonItem *exportButton = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(exportItemClicked)];
    
<<<<<<< HEAD
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:exportButton, nil];
=======
    self.navigationItem.rightBarButtonItems = @[exportButton];
>>>>>>> origin/tanner
    
    self.navigationItem.hidesBackButton = YES;
    self.title = @"Modifiers Overview";
    
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
    
    
    [CommParse getAnalyticsModifierSales:self StartDate:start_date EndDate:NSDate.date];
}
// On Export
-(void)exportItemClicked{
    
    NSString *title;
    title = [NSString stringWithFormat:@"%@ (%@ ~ %@)", @"Analytics Modifiers Overview", _startDateText.text, _endDateText.text];
=======
    // Previous month's data
    NSDate *startDate = [NSDate date30DaysAgo];
    NSDate *endDate   = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM-dd-yyyy";
    
    self.startDateText.text = [dateFormatter stringFromDate:startDate];
    self.endDateText.text = [dateFormatter stringFromDate:endDate];
    
    [CommParse getAnalyticsModifierSales:self startDate:startDate endDate:[NSDate date]];
}
// On Export
- (void)exportItemClicked {
    
NSString *title = [NSString stringWithFormat:@"%@ (%@ ~ %@)", @"Analytics Modifiers Overview", _startDateText.text, _endDateText.text];
>>>>>>> origin/tanner
    
    NSString *content;;
    content = @"Modifiers,Item,Category,Times Applied,Sales";
    
<<<<<<< HEAD
    NSMutableArray *itemArray;
    for(NSString *key in keyArray){
        itemArray =[resultArray objectForKey:key];
        
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
=======
    NSMutableArray *items;
    for(NSString *key in keys){
        items = results[key];
        
        content = [NSString stringWithFormat:@"%@ \n %@,%@,%@,%.02f,%.02f", content, items[0], items[1], items[2], [items[3] floatValue], [items[4] floatValue] ];
    }
    
    // export with csv format
    [CommParse sendEmailwithMailGun:self userEmail:@"" emailSubject:title emailContent:content];
    
}


#pragma mark - Table view data source
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *CellIdentifier = @"AnalyticsTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = @"Modifiers";
    
    label = (UILabel *)[cell viewWithTag:2];
    label.text = @"Item";
    
    label = (UILabel *)[cell viewWithTag:3];
    label.text = @"Category";
    
    label = (UILabel *)[cell viewWithTag:4];
    label.text = @"Times Applied";
    
    label = (UILabel *)[cell viewWithTag:5];
>>>>>>> origin/tanner
    label.text = @"Sales";
    
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSMutableArray * itemArray;
    
    NSString *key = [keyArray objectAtIndex:indexPath.row];
    
    itemArray =[resultArray objectForKey:key];
    
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
    if ([[response objectForKey:@"responseCode"] boolValue]) {
        
        resultArray = [response objectForKey:@"objects"];
        timesArray = [response objectForKey:@"time_objects"];
        keyArray = [resultArray allKeys];
=======
    static NSString *CellIdentifier = @"AnalyticsTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSMutableArray *items;
    
    NSString *key = keys[indexPath.row];
    
    items = results[key];
    
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = items[0];
    
    label = (UILabel *)[cell viewWithTag:2];
    label.text = items[1];
    
    label = (UILabel *)[cell viewWithTag:3];
    label.text = items[2];
    
    label = (UILabel *)[cell viewWithTag:4];
    label.text = [NSString stringWithFormat:@"%d", [[timess objectForKey:items[3]] intValue] ];
    
    label = (UILabel *)[cell viewWithTag:5];
    label.text = [NSString stringWithFormat:@"%.02f", [items[4] floatValue]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


- (void)commsDidAction:(NSDictionary *)response {
    [ProgressHUD dismiss];
    if ([response[@"responseCode"] boolValue]) {
        
        results = response[@"objects"];
        timess = response[@"time_objects"];
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
        [CommParse getAnalyticsModifierSales:self StartDate:startDate EndDate:endDate];
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
        [CommParse getAnalyticsModifierSales:self startDate:startDate endDate:endDate];
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
