//
//  AnalyticsSalesSummaryController.m
//  EntreeManage
//
//  Created by Faraz on 8/6/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "AnalyticsSalesSummaryController.h"

@interface AnalyticsSalesSummaryController ()<CommsDelegate, UITableViewDelegate, UITableViewDataSource>{
    
    NSMutableArray *rowNames;
    NSMutableArray *sumVal;
    
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

@implementation AnalyticsSalesSummaryController

- (void)viewDidLoad {
    [super viewDidLoad];

    _pickDateView.hidden = true;
    
    
    rowNames = [[NSMutableArray alloc] initWithObjects:@"Gross Sales", @"Discounts", @"Net Sales", @"Tax", @"Tips", @"Refunds Given", @"Total Collected", @"", @"Payments", @"Cash", @"Card", nil];
    
    // Do any additional setup after loading the view.
    UIBarButtonItem *exportButton = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(exportItemClicked)];
    
    self.navigationItem.rightBarButtonItems = @[exportButton];
    
    self.navigationItem.hidesBackButton = YES;
    
    // get previous month
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear fromDate:NSDate.date];
    comps.month -= 1;
    NSDate *startDate = [cal dateFromComponents:comps];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    NSString *dateText = [dateFormat stringFromDate: startDate];
    _startDateText.text = dateText;
    dateText = [dateFormat stringFromDate: NSDate.date];
    _endDateText.text = dateText;
    
    [CommParse getAnalyticsSalesView:self StartDate:startDate EndDate:NSDate.date];
    
    self.title = @"Sales Overview";
    
}

// On Export
- (void)exportItemClicked {
    
NSString *title = [NSString stringWithFormat:@"%@ (%@ ~ %@)", @"Analytics Sales Overview", _startDateText.text, _endDateText.text];
    
    NSString *content;;
    content = @"Type,Total";
    
    // export with csv format
    for(int i = 0; i< rowNames.count; i++) {
        content = [NSString stringWithFormat:@"%@ \n %@,%@", content, rowNames[i], sumVal[i] ];
    }
    [CommParse sendEmailwithMailGun:self userEmail:@"" EmailSubject:title EmailContent:content];
    
}




#pragma mark - Table view data source
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *CellIdentifier = @"AnalyticsTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [cell setBackgroundColor:[UIColor lightGrayColor]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return rowNames.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"AnalyticsTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = rowNames[indexPath.row];
    
    label = (UILabel *)[cell viewWithTag:2];
    label.text = [NSString stringWithFormat:@"%.02f", [sumVal[indexPath.row]floatValue]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}

- (void)commsDidAction:(NSDictionary *)response {
    [ProgressHUD dismiss];
    
    sumVal = [[NSMutableArray alloc]init];
    for(int i = 0;i <16;i++){
        [sumVal addObject:@0];
    }

    if ([response[@"responseCode"] boolValue]) {
        
        // export csv and send email
        if ([response[@"action"] intValue] == 9) {
        }
        else {
            NSMutableArray *quotes =  [[NSMutableArray alloc] init];
            quotes = response[@"objects"];
            
            // calculate sums
            for(int i = 0;i < quotes.count;i++){ // PFObject *itemObj in quotes
                PFObject *itemObj = quotes[i];
                // Gross Sales
                [sumVal replaceObjectAtIndex:0 withObject: [NSNumber numberWithFloat:[itemObj[@"subtotal"] floatValue] + [sumVal[0] floatValue]]];
                // Tax
                [sumVal replaceObjectAtIndex:3 withObject: [NSNumber numberWithFloat:[itemObj[@"tax"] floatValue] + [sumVal[3] floatValue]]];
                // Tips
                [sumVal replaceObjectAtIndex:4 withObject: [NSNumber numberWithFloat:[itemObj[@"tip"] floatValue] + [sumVal[4] floatValue]]];
                
                // Cash
                if([itemObj[@"type"] isEqualToString:@"Cash"]) {
                    [sumVal replaceObjectAtIndex:9 withObject: [NSNumber numberWithFloat:[itemObj[@"subtotal"] floatValue] + [sumVal[9] floatValue]]];
                }
                // Card
                else {
                    [sumVal replaceObjectAtIndex:10 withObject: [NSNumber numberWithFloat:[itemObj[@"subtotal"] floatValue] + [sumVal[10] floatValue]]];
                }
            }
            // Net Sales (Gross Sales - Discounts: OrderItem's onTheHouse boolean)
            CGFloat temp = [response[@"discount"] floatValue];
            sumVal[1] = @(temp);
            temp = [sumVal[0] floatValue]-temp;
            sumVal[2] = @(temp);
            
            // Total collected (Net sales + Tax + Tips)
            temp = [sumVal[2] floatValue]+[sumVal[3] floatValue]+[sumVal[4] floatValue];
            sumVal[6] = @(temp);
            
            [sumVal replaceObjectAtIndex:8 withObject:sumVal[0]];
            
            [_analTableView reloadData];
        }
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
    // from start day 00:00 to end day 24:00
    endDate = [endDate dateByAddingTimeInterval:24*3600];
    
    if(startDate && endDate) {
        [CommParse getAnalyticsSalesView:self StartDate:startDate EndDate:endDate];
    }
}

- (IBAction)onTouchTextStartDate:(id)sender {
    startDate_Flag = true;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    NSDate *date = [dateFormat dateFromString: _startDateText.text];
    [_datePicker setDate:date];
    
    _pickDateView.frame = CGRectMake(200,140,390,0);
    _pickDateView.hidden = false;
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
    _pickDateView.hidden = false;
    [UIView animateWithDuration:1.0  animations:^ {
        _pickDateView.frame = CGRectMake(200,140,390,270);
    }];
}

@end
