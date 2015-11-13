//
//  AnalyticsCategorySalesController.m
//  EntreeManage
//
//  Created by Faraz on 8/6/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "AnalyticsCategorySalesController.h"


<<<<<<< HEAD
@interface AnalyticsCategorySalesController ()<CommsDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>{
    
    NSMutableDictionary *catArray;
    
    NSArray *keyArray;
    
    //if selected text is start date then true
=======
@interface AnalyticsCategorySalesController () <CommsDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    NSMutableDictionary *categories;
    NSArray *keys;
    // if selected text is start date then true
>>>>>>> origin/tanner
    BOOL startDate_Flag;
}


@property (weak, nonatomic) IBOutlet UILabel *lblNetSales;
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

@implementation AnalyticsCategorySalesController

- (void)viewDidLoad {
    [super viewDidLoad];
    
<<<<<<< HEAD
     _pickDateView.hidden = true;
    
    // Do any additional setup after loading the view.
    UIBarButtonItem *exportButton = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(exportItemClicked)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:exportButton, nil];
=======
    _pickDateView.hidden = true;
    
    UIBarButtonItem *exportButton = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(exportItemClicked)];
    
    self.navigationItem.rightBarButtonItems = @[exportButton];
>>>>>>> origin/tanner
    
    self.navigationItem.hidesBackButton = YES;
    self.title = @"Category Sales";
    
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
    
    
    [CommParse getAnalyticsCategorySales:self StartDate:start_date EndDate:NSDate.date];
}
// On Export
-(void)exportItemClicked{
    
    NSString *title;
    title = [NSString stringWithFormat:@"%@ (%@ ~ %@)", @"Analytics Category Sales", _startDateText.text, _endDateText.text];
=======
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
>>>>>>> origin/tanner
    
    NSString *content;;
    content = @"Menu Category,Total,% of Net Sales";
    
<<<<<<< HEAD
    NSMutableArray *itemArray;
    for(NSString *key in keyArray){
        itemArray =[catArray objectForKey:key];
        
        NSString *text1 = [NSString stringWithFormat:@"%.02f", [itemArray[1] floatValue]];
        float net_pro = ([itemArray[1] floatValue]-[itemArray[2] floatValue])/[itemArray[1] floatValue]*100;
        
        NSString *text2 = [NSString stringWithFormat:@"%.02f", net_pro];
        content = [NSString stringWithFormat:@"%@ \n %@,%@,%@", content, itemArray[0], text1, text2 ];
        
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
    label.text = @"Menu Category";
    
    label = (UILabel*) [cell viewWithTag:2];
    label.text = @"Total";
    
    label = (UILabel*) [cell viewWithTag:3];
=======
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
>>>>>>> origin/tanner
    label.text = @"% of Net Sales";
    
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
    return [catArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * CellIdentifier = @"AnalyticsTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil){
=======
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
>>>>>>> origin/tanner
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
<<<<<<< HEAD
    NSString *key = [keyArray objectAtIndex:indexPath.row];
    NSMutableArray * itemArray;
    
    itemArray =[catArray objectForKey:key];
    
    UILabel *label;
    label = (UILabel*) [cell viewWithTag:1];
    label.text = itemArray[0];
    
    //Net Sales =  Total - discount
    float net_pro = ([itemArray[1] floatValue]-[itemArray[2] floatValue])/[itemArray[1] floatValue]*100;
    
    //Total
    label = (UILabel*) [cell viewWithTag:2];
    label.text = [NSString stringWithFormat:@"%.02f", [itemArray[1] floatValue]];

    //% of Net Sales
    label = (UILabel*) [cell viewWithTag:3];
    label.text = [NSString stringWithFormat:@"%.02f", net_pro];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}


- (void)commsDidAction:(NSDictionary *)response
{
    [ProgressHUD dismiss];
    if ([[response objectForKey:@"responseCode"] boolValue]) {
        catArray = [response objectForKey:@"objects"];
        keyArray = [catArray allKeys];
        
        float sum_net = 0;
        NSMutableArray *itemArray;
        for(NSString *key in keyArray){
            itemArray =[catArray objectForKey:key];
            sum_net += [itemArray[1] floatValue]-[itemArray[2] floatValue];
        }
        
        _lblNetSales.text = [NSString stringWithFormat:@"$%.02f", sum_net];
=======
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
>>>>>>> origin/tanner
        
        [_analTableView reloadData];
    }
    else {
        [ProgressHUD showError:[response valueForKey:@"errorMsg"]];
<<<<<<< HEAD
        
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
        [CommParse getAnalyticsCategorySales:self StartDate:startDate EndDate:endDate];
=======
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
}


-(BOOL)textfield:(UITextField *)textField shouldchangeCharactersInRange:(NSRange)range replacementString:(NSString *) string{
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
}

- (BOOL)textfield:(UITextField *)textField shouldchangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
>>>>>>> origin/tanner
    return NO;
}

@end
