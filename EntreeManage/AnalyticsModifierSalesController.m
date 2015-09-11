//
//  AnalyticsModifierSalesController.m
//  EntreeManage
//
//  Created by Faraz on 8/6/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "AnalyticsModifierSalesController.h"

@interface AnalyticsModifierSalesController ()<CommsDelegate, UITableViewDelegate, UITableViewDataSource>{
    
    NSMutableDictionary *results;
    NSMutableDictionary *timess;
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

@implementation AnalyticsModifierSalesController

- (void)viewDidLoad {
    [super viewDidLoad];
    _pickDateView.hidden = true;
    
    UIBarButtonItem *exportButton = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(exportItemClicked)];
    
    self.navigationItem.rightBarButtonItems = @[exportButton];
    
    self.navigationItem.hidesBackButton = YES;
    self.title = @"Modifiers Overview";
    
    // Previous month's data
    NSDate *startDate = [NSDate date30DaysAgo];
    NSDate *endDate   = [NSDate date];
    _startDateText.text         = [[NSDateFormatter shared] stringFromDate:startDate];
    _endDateText.text           = [[NSDateFormatter shared] stringFromDate:endDate];
    
    [CommParse getAnalyticsModifierSales:self startDate:startDate endDate:[NSDate date]];
}
// On Export
- (void)exportItemClicked {
    
NSString *title = [NSString stringWithFormat:@"%@ (%@ ~ %@)", @"Analytics Modifiers Overview", _startDateText.text, _endDateText.text];
    
    NSString *content;;
    content = @"Modifiers,Item,Category,Times Applied,Sales";
    
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
        [CommParse getAnalyticsModifierSales:self startDate:startDate endDate:endDate];
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
