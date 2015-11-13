//
//  AnalyticsSalesSummaryController.m
//  EntreeManage
//
//  Created by Faraz on 8/6/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "AnalyticsSalesSummaryController.h"

@interface AnalyticsSalesSummaryController ()<CommsDelegate, UITableViewDelegate, UITableViewDataSource>{
    
<<<<<<< HEAD
    NSMutableArray *rowNameArray;
=======
    NSMutableArray *rowNames;
>>>>>>> origin/tanner
    NSMutableArray *sumVal;
    
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

@implementation AnalyticsSalesSummaryController

- (void)viewDidLoad {
    [super viewDidLoad];
<<<<<<< HEAD

    _pickDateView.hidden = true;
    
    
    rowNameArray = [[NSMutableArray alloc] initWithObjects:@"Gross Sales", @"Discounts", @"Net Sales", @"Tax", @"Tips", @"Refunds Given", @"Total Collected", @"", @"Payments", @"Cash", @"Card", nil];
    
    // Do any additional setup after loading the view.
    UIBarButtonItem *exportButton = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(exportItemClicked)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:exportButton, nil];
    
    self.navigationItem.hidesBackButton = YES;
    
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
    
    [CommParse getAnalyticsSalesView:self StartDate:start_date EndDate:NSDate.date];
=======
    
    _pickDateView.hidden = true;
    
    
    rowNames = [[NSMutableArray alloc] initWithObjects:@"Gross Sales", @"Discounts", @"Net Sales", @"Tax", @"Tips", @"Refunds Given", @"Total Collected", @"Payments", @"Cash", @"Card", nil];
    
    UIBarButtonItem *exportButton = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(exportItemClicked)];
    
    self.navigationItem.rightBarButtonItems = @[exportButton];
    
    self.navigationItem.hidesBackButton = YES;
    
    // Previous month's data
    NSDate *startDate = [NSDate date30DaysAgo];
    NSDate *endDate   = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM-dd-yyyy";
    
    self.startDateText.text = [dateFormatter stringFromDate:startDate];
    self.endDateText.text = [dateFormatter stringFromDate:endDate];
    
    [CommParse getAnalyticsSalesView:self startDate:startDate endDate:endDate];
>>>>>>> origin/tanner
    
    self.title = @"Sales Overview";
    
}

<<<<<<< HEAD
// On Export
-(void)exportItemClicked{
    
    NSString *title;
    title = [NSString stringWithFormat:@"%@ (%@ ~ %@)", @"Analytics Sales Overview", _startDateText.text, _endDateText.text];
=======
- (void)exportItemClicked {
    
    NSString *title = [NSString stringWithFormat:@"%@ (%@ ~ %@)", @"Analytics Sales Overview", _startDateText.text, _endDateText.text];
>>>>>>> origin/tanner
    
    NSString *content;;
    content = @"Type,Total";
    
<<<<<<< HEAD
    //export with csv format
    for(int i=0; i< [rowNameArray count]; i++) {
        content = [NSString stringWithFormat:@"%@ \n %@,%@", content, rowNameArray[i], sumVal[i] ];
    }
    [CommParse sendEmailwithMailGun:self userEmail:@"" EmailSubject:title EmailContent:content];
=======
    // export with csv format
    for(int i = 0; i< rowNames.count; i++) {
        content = [NSString stringWithFormat:@"%@ \n %@,%@", content, rowNames[i], sumVal[i] ];
    }
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
=======
#pragma mark - Table view data source
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *CellIdentifier = @"AnalyticsTableCell";
>>>>>>> origin/tanner
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
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
    return [rowNameArray count];
=======
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return rowNames.count;
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
    UILabel *label;
    label = (UILabel*) [cell viewWithTag:1];
    label.text =rowNameArray[indexPath.row];
    
    label = (UILabel*) [cell viewWithTag:2];
=======
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = rowNames[indexPath.row];
    
    label = (UILabel *)[cell viewWithTag:2];
>>>>>>> origin/tanner
    label.text = [NSString stringWithFormat:@"%.02f", [sumVal[indexPath.row]floatValue]];
    
    return cell;
}

<<<<<<< HEAD
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}

- (void)commsDidAction:(NSDictionary *)response
{
    [ProgressHUD dismiss];
    
    sumVal = [[NSMutableArray alloc]init];
    for(int i = 0;i <16;i++){
        [sumVal addObject:[NSNumber numberWithFloat:0]];
    }

    if ([[response objectForKey:@"responseCode"] boolValue]) {
        
        //export csv and send email
        if ([[response objectForKey:@"action"] intValue] == 9) {
            
        }
        else {
            NSMutableArray *quotes =  [[NSMutableArray alloc] init];
            quotes = [response objectForKey:@"objects"];
            
            //calculate sums
            for(int i = 0;i < [quotes count];i++){ //PFObject *item_obj in quotes
                PFObject *item_obj = [quotes objectAtIndex:i];
                //Gross Sales
                [sumVal replaceObjectAtIndex:0 withObject: [NSNumber numberWithFloat:[[item_obj objectForKey:@"subtotal"] floatValue] + [[sumVal objectAtIndex:0] floatValue]]];
                //Tax
                [sumVal replaceObjectAtIndex:3 withObject: [NSNumber numberWithFloat:[[item_obj objectForKey:@"tax"] floatValue] + [[sumVal objectAtIndex:3] floatValue]]];
                //Tips
                [sumVal replaceObjectAtIndex:4 withObject: [NSNumber numberWithFloat:[[item_obj objectForKey:@"tip"] floatValue] + [[sumVal objectAtIndex:4] floatValue]]];
                
                //Cash
                if([[item_obj objectForKey:@"type"] isEqualToString:@"Cash"]) {
                    [sumVal replaceObjectAtIndex:9 withObject: [NSNumber numberWithFloat:[[item_obj objectForKey:@"subtotal"] floatValue] + [[sumVal objectAtIndex:9] floatValue]]];
                }
                //Card
                else {
                    [sumVal replaceObjectAtIndex:10 withObject: [NSNumber numberWithFloat:[[item_obj objectForKey:@"subtotal"] floatValue] + [[sumVal objectAtIndex:10] floatValue]]];
                }
            }
            //Net Sales (Gross Sales - Discounts: OrderItem's onTheHouse boolean)
            float temp = [[response objectForKey:@"discount"] floatValue];
            [sumVal replaceObjectAtIndex:1 withObject:[NSNumber numberWithFloat:temp]];
            temp = [[sumVal objectAtIndex:0] floatValue]-temp;
            [sumVal replaceObjectAtIndex:2 withObject:[NSNumber numberWithFloat:temp]];
            
            //Total collected (Net sales + Tax + Tips)
            temp = [[sumVal objectAtIndex:2] floatValue]+[[sumVal objectAtIndex:3] floatValue]+[[sumVal objectAtIndex:4] floatValue];
            [sumVal replaceObjectAtIndex:6 withObject:[NSNumber numberWithFloat:temp]];
            
            [sumVal replaceObjectAtIndex:8 withObject:[sumVal objectAtIndex:0]];
            
            [_analTableView reloadData];
        }
        
    }
    else {
        [ProgressHUD showError:[response valueForKey:@"errorMsg"]];
        
    }
    
=======
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)commsDidAction:(NSDictionary *)response {
    [ProgressHUD dismiss];
    
    sumVal = [NSMutableArray array];
    // why 16?
    for(int i = 0;i <16;i++){
        [sumVal addObject:@0];
    }
    
    if ([response[@"responseCode"] boolValue]) {
        
        // export csv and send email
        if ([response[@"action"] intValue] == 9) {
            NSLog(@"Action was 9");
        } else {
            NSArray *payments = response[@"objects"];
            
            // calculate sums
            CGFloat grossSales = [[payments valueForKeyPath:@"order.@sum.subtotal"] floatValue];
            CGFloat tax = [[payments valueForKeyPath:@"order.@sum.tax"] floatValue];
            CGFloat tips = [[payments valueForKeyPath:@"order.@sum.tip"] floatValue];
            CGFloat cash = [[[payments filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type = 'Card'"]] valueForKeyPath:@"order.@sum.subtotal"] floatValue];
            CGFloat card = [[[payments filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type = 'Cash'"]] valueForKeyPath:@"order.@sum.subtotal"] floatValue];
            sumVal[0] = @(grossSales);
            sumVal[3] = @(tax);
            sumVal[4] = @(tips);
            sumVal[8] = @(cash);
            sumVal[9] = @(card);
            
            // Net Sales (Gross Sales - Discounts: OrderItem's onTheHouse boolean)
            CGFloat temp = [response[@"discount"] floatValue];
            sumVal[1]    = @(temp);
            sumVal[2]    = @([sumVal[0] floatValue]-temp);
            
            // Total collected (Net sales + Tax + Tips)
            temp = [sumVal[2] floatValue]+[sumVal[3] floatValue]+[sumVal[4] floatValue];
            sumVal[6] = @(temp);
            
            sumVal[7] = sumVal[0];
            
            [_analTableView reloadData];
        }
    } else {
        [ProgressHUD showError:[response valueForKey:@"errorMsg"]];
    }
>>>>>>> origin/tanner
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
        [CommParse getAnalyticsSalesView:self StartDate:startDate EndDate:endDate];
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
        [CommParse getAnalyticsSalesView:self startDate:startDate endDate:endDate];
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
    
    _pickDateView.frame = CGRectMake(200,140,390,0);
    _pickDateView.hidden=false;
    [UIView animateWithDuration:1.0  animations:^ {
                         _pickDateView.frame = CGRectMake(200,140,390,270);
                     }];
    
}

- (IBAction)onTouchTextEndDate:(id)sender {
    startDate_Flag = false;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    NSDate *date = [dateFormat dateFromString: _endDateText.text];
    [_datePicker setDate:date];
    
    _pickDateView.frame = CGRectMake(200,140,390,0);
    _pickDateView.hidden=false;
    [UIView animateWithDuration:1.0  animations:^ {
        _pickDateView.frame = CGRectMake(200,140,390,270);
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
>>>>>>> origin/tanner
    }];
}

@end
