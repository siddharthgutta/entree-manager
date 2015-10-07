//
//  AnalyticsOrderReportController.m
//  EntreeManage
//
//  Created by Faraz on 8/6/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "AnalyticsOrderReportController.h"

@interface AnalyticsOrderReportController ()<CommsDelegate, UITableViewDelegate, UITableViewDataSource>{
    
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

@implementation AnalyticsOrderReportController

- (void)viewDidLoad {
    [super viewDidLoad];
    _pickDateView.hidden = true;

    UIBarButtonItem *exportButton = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(exportItemClicked)];
    
    self.navigationItem.rightBarButtonItems = @[exportButton];
    
    self.navigationItem.hidesBackButton = YES;
    self.title = @"Orders Overview";
    
    // Previous month's data
    NSDate *startDate = [NSDate date30DaysAgo];
    NSDate *endDate   = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM-dd-yyyy";
    
    self.startDateText.text = [dateFormatter stringFromDate:startDate];
    self.endDateText.text = [dateFormatter stringFromDate:endDate];
    
    [ProgressHUD show:@"" Interaction:NO];
    [CommParse getAnalyticsOrderReport:self startDate:startDate endDate:endDate];
}
// On Export
- (void)exportItemClicked {
    
    NSString *title = [NSString stringWithFormat:@"%@ (%@ ~ %@)", @"Analytics Orders Overview", _startDateText.text, _endDateText.text];
    
    NSString *content = @"Item,Menu,Category,Times Ordered,Sales";
    
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
    label.text = @"Item";
    
    label = (UILabel *)[cell viewWithTag:2];
    label.text = @"Menu";
    
    label = (UILabel *)[cell viewWithTag:3];
    label.text = @"Category";
    
    label = (UILabel *)[cell viewWithTag:4];
    label.text = @"Times Ordered";
    
    label = (UILabel *)[cell viewWithTag:5];
    label.text = @"Sales";
    
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
    
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"%d", [items[3] intValue]];
    
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
        keys = [results allKeys];
        
        [_analTableView reloadData];
    }
    else {
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
        [ProgressHUD show:@"" Interaction:NO];
        [CommParse getAnalyticsOrderReport:self startDate:startDate endDate:endDate];
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
