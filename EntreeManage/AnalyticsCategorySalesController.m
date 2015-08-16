//
//  AnalyticsCategorySalesController.m
//  EntreeManage
//
//  Created by Faraz on 8/6/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "AnalyticsCategorySalesController.h"


@interface AnalyticsCategorySalesController ()<CommsDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>{
    
    NSMutableDictionary *catArray;
    
    NSArray *keyArray;
    
    //if selected text is start date then true
    BOOL startDate_Flag;
}


@property (weak, nonatomic) IBOutlet UILabel *lblNetSales;
@property (weak, nonatomic) IBOutlet UITableView *analTableView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (weak, nonatomic) IBOutlet UITextField *startDateText;
@property (weak, nonatomic) IBOutlet UITextField *endDateText;


- (IBAction)onChangedDate:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *pickDateView;
- (IBAction)onTouchTextStartDate:(id)sender;
- (IBAction)onTouchTextEndDate:(id)sender;

@end

@implementation AnalyticsCategorySalesController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     _pickDateView.hidden = true;
    
    // Do any additional setup after loading the view.
    UIBarButtonItem *exportButton = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(exportItemClicked)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:exportButton, nil];
    
    self.navigationItem.hidesBackButton = YES;
    self.title = @"Category Sales";
    
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
    
    NSString *content;;
    content = @"Menu Category,Total,% of Net Sales";
    
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
    return [catArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * CellIdentifier = @"AnalyticsTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
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
    NSString *dateText = [dateFormat stringFromDate: selDate];
    if(startDate_Flag)  _startDateText.text = dateText;
    else _endDateText.text = dateText;
    
    _pickDateView.hidden = true;
    NSDate *startDate = [dateFormat dateFromString: _startDateText.text];
    NSDate *endDate = [dateFormat dateFromString: _endDateText.text];
    
    if(startDate && endDate) {
        [CommParse getAnalyticsCategorySales:self StartDate:startDate EndDate:endDate];
    }
}

- (IBAction)onTouchTextStartDate:(id)sender {
    startDate_Flag = true;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    NSDate *date = [dateFormat dateFromString: _startDateText.text];
    [_datePicker setDate:date];
    
    _pickDateView.hidden = false;
}

- (IBAction)onTouchTextEndDate:(id)sender {
    startDate_Flag = false;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    NSDate *date = [dateFormat dateFromString: _endDateText.text];
    [_datePicker setDate:date];
    
    _pickDateView.hidden = false;
}


-(BOOL)textfield:(UITextField *)textField shouldchangeCharactersInRange:(NSRange)range replacementString:(NSString *) string{
    return NO;
}

@end
