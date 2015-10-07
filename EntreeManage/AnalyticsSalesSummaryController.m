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
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM-dd-yyyy";
    
    self.startDateText.text = [dateFormatter stringFromDate:startDate];
    self.endDateText.text = [dateFormatter stringFromDate:endDate];
    
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
        [CommParse getAnalyticsSalesView:self startDate:startDate endDate:endDate];
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
