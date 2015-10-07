//
//  AnalyticsCategorySalesController.m
//  EntreeManage
//
//  Created by Faraz on 8/6/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "AnalyticsCategorySalesController.h"


@interface AnalyticsCategorySalesController () <CommsDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    NSMutableDictionary *categories;
    NSArray *keys;
    // if selected text is start date then true
    BOOL startDate_Flag;
}


@property (weak, nonatomic) IBOutlet UILabel *lblNetSales;
@property (weak, nonatomic) IBOutlet UITableView *analTableView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (weak, nonatomic) IBOutlet UITextField *startDateText;
@property (weak, nonatomic) IBOutlet UITextField *endDateText;

@property (weak, nonatomic) IBOutlet UIView *pickDateView;

- (IBAction)onChangedDate:(id)sender;
- (IBAction)onTouchTextStartDate:(id)sender;
- (IBAction)onTouchTextEndDate:(id)sender;

@end

@implementation AnalyticsCategorySalesController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _pickDateView.hidden = true;
    
    UIBarButtonItem *exportButton = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(exportItemClicked)];
    
    self.navigationItem.rightBarButtonItems = @[exportButton];
    
    self.navigationItem.hidesBackButton = YES;
    self.title = @"Category Sales";
    
    // Previous month's data
    NSDate *startDate = [NSDate date30DaysAgo];
    NSDate *endDate   = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM-dd-yyyy";
    
    self.startDateText.text = [dateFormatter stringFromDate:startDate];
    self.endDateText.text = [dateFormatter stringFromDate:endDate];
    
    [CommParse getAnalyticsCategorySales:self startDate:startDate endDate:endDate];
    [CommParse getNetSalesForInterval:startDate end:endDate callback:^(NSNumber *num, NSError *error) {
        if (!error) {
            _lblNetSales.text = [NSString stringWithFormat:@"$%.02f", num.floatValue];
            [_analTableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)exportItemClicked {
    NSString *title = [NSString stringWithFormat:@"%@ (%@ ~ %@)", @"Analytics Category Sales", _startDateText.text, _endDateText.text];
    
    NSString *content;;
    content = @"Menu Category,Total,% of Net Sales";
    
    NSMutableArray *items;
    for(NSString *key in keys){
        items = categories[key];
        
        NSString *text1 = [NSString stringWithFormat:@"%.02f", [items[1] floatValue]];
        CGFloat netPro = ([items[1] floatValue]-[items[2] floatValue])/[items[1] floatValue]*100;
        
        NSString *text2 = [NSString stringWithFormat:@"%.02f", netPro];
        content = [NSString stringWithFormat:@"%@ \n %@,%@,%@", content, items[0], text1, text2 ];
    }
    
    // export with csv format
    [CommParse sendEmailwithMailGun:self userEmail:@"" emailSubject:title emailContent:content];
}


#pragma mark - Table view data source
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *CellIdentifier = @"AnalyticsTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = @"Menu Category";
    
    label = (UILabel *)[cell viewWithTag:2];
    label.text = @"Total";
    
    label = (UILabel *)[cell viewWithTag:3];
    label.text = @"% of Net Sales";
    
    [cell setBackgroundColor:[UIColor lightGrayColor]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return categories.count;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"AnalyticsTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSString *key = keys[indexPath.row];
    NSMutableArray *items;
    
    items = categories[key];
    
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = items[0];
    
    // Net Sales =  Total - discount
    CGFloat netPro = ([items[1] floatValue] - [items[2] floatValue])/[items[1] floatValue]*100;
    if (netPro != netPro || isinf(netPro)) // nan / inf
        netPro = 0;
    
    // Total
    label = (UILabel *)[cell viewWithTag:2];
    label.text = [NSString stringWithFormat:@"%.02f", [items[1] floatValue]];
    
    // % of Net Sales
    label = (UILabel *)[cell viewWithTag:3];
    label.text = [NSString stringWithFormat:@"%.02f", netPro];
    
    return cell;
}


- (void)commsDidAction:(NSDictionary *)response {
    [ProgressHUD dismiss];
    if ([response[@"responseCode"] boolValue]) {
        categories = response[@"objects"];
        keys = [categories allKeys];
        
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
        [CommParse getAnalyticsCategorySales:self startDate:startDate endDate:endDate];
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

- (BOOL)textfield:(UITextField *)textField shouldchangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return NO;
}

@end
