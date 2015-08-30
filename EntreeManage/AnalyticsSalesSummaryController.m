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

@property (weak, nonatomic) IBOutlet UIView *pickDateView;

- (IBAction)onChangedDate:(id)sender;
- (IBAction)onTouchTextStartDate:(id)sender;
- (IBAction)onTouchTextEndDate:(id)sender;

@end

@implementation AnalyticsSalesSummaryController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _pickDateView.hidden = true;
    
    
    rowNames = [[NSMutableArray alloc] initWithObjects:@"Gross Sales", @"Discounts", @"Net Sales", @"Tax", @"Tips", @"Refunds Given", @"Total Collected", @"Payments", @"Cash", @"Card", nil];
    
    UIBarButtonItem *exportButton = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(exportItemClicked)];
    
    self.navigationItem.rightBarButtonItems = @[exportButton];
    
    self.navigationItem.hidesBackButton = YES;
    
    // Previous month's data
    NSDate *startDate = [NSDate date30DaysAgo];
    NSDate *endDate   = [NSDate date];
    NSDateFormatter *dateFormat = ({id d = [NSDateFormatter new]; [d setDateFormat:@"dd-MM-yyyy"]; d; });
    _startDateText.text         = [dateFormat stringFromDate:startDate];
    _endDateText.text           = [dateFormat stringFromDate:endDate];
    
    [CommParse getAnalyticsSalesView:self startDate:startDate endDate:endDate];
    
    self.title = @"Sales Overview";
    
}

- (void)exportItemClicked {
    
    NSString *title = [NSString stringWithFormat:@"%@ (%@ ~ %@)", @"Analytics Sales Overview", _startDateText.text, _endDateText.text];
    
    NSString *content;;
    content = @"Type,Total";
    
    // export with csv format
    for(int i = 0; i< rowNames.count; i++) {
        content = [NSString stringWithFormat:@"%@ \n %@,%@", content, rowNames[i], sumVal[i] ];
    }
    [CommParse sendEmailwithMailGun:self userEmail:@"" emailSubject:title emailContent:content];
    
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
    return rowNames.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"AnalyticsTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = rowNames[indexPath.row];
    
    label = (UILabel *)[cell viewWithTag:2];
    label.text = [NSString stringWithFormat:@"%.02f", [sumVal[indexPath.row]floatValue]];
    
    return cell;
}

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
            NSArray *quotes = response[@"objects"];
            
            // calculate sums
            CGFloat grossSales = 0, tax = 0, tips = 0, cash = 0, card = 0;
            for (Payment *payment in quotes) {
                grossSales += payment.subtotal;
                tax += payment.tax;
                tips += payment.tip;
                if ([payment.type isEqualToString:@"Cash"])
                    cash += payment.subtotal;
                else
                    card += payment.subtotal;
            }
            
            sumVal[0]  = @(grossSales);
            sumVal[3]  = @(tax);
            sumVal[4]  = @(tips);
            sumVal[8]  = @(cash);
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
        [CommParse getAnalyticsSalesView:self startDate:startDate endDate:endDate];
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
