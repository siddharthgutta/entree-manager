//
//  BusinessEmployeeAddController.m
//  EntreeManage
//
//  Created by Faraz on 8/1/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "BusinessEmployeeAddController.h"
#import "BusinessViewController.h"

@interface BusinessEmployeeAddController ()<CommsDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    
}
- (IBAction)onCancelClick:(id)sender;
- (IBAction)onClickSave:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtRole;
@property (weak, nonatomic) IBOutlet UISwitch *switchManager;
@property (weak, nonatomic) IBOutlet UITextField *txtPincode;
@property (weak, nonatomic) IBOutlet UITextField *txtHourlyWage;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerColor;


@end

@implementation BusinessEmployeeAddController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view.
    if(_menuObj!=nil){
       _txtName.text = [PFUtils getProperty:@"name" InObject:_menuObj];
       _txtRole.text = [PFUtils getProperty:@"role" InObject:_menuObj];
        NSNumber *adminFlag = [PFUtils getProperty:@"administrator" InObject:_menuObj];
        if([adminFlag intValue]==1)  {
            _switchManager.on = YES;
        }
        else {
            _switchManager.on = NO;
        }
        _txtPincode.text = [PFUtils getProperty:@"pinCode" InObject:_menuObj];
        NSNumber *hourlyWage = [PFUtils getProperty:@"hourlyWage" InObject:_menuObj];
        
        _txtHourlyWage.text = [NSString stringWithFormat:@"%f", [hourlyWage floatValue]];
    }
    
}

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerColor {
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerColor numberOfRowsInComponent:(NSInteger)component {
    return COLOR_ARRAY.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString *)pickerView:(UIPickerView *)pickerColor titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return COLOR_ARRAY[row];
}



- (IBAction)onCancelClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onClickSave:(id)sender {
    [ProgressHUD show:@"" Interaction:NO];
    
    // if not exist then add
    if(_menuObj==nil) {
        _menuObj = [PFObject objectWithClassName:_menuType];
    }
    
    [_menuObj setObject:_txtName.text forKey:@"name"];
    [_menuObj setObject:_txtRole.text forKey:@"role"];
    
    [_menuObj setObject:[NSNumber numberWithBool:_switchManager.on] forKey:@"administrator"];
    [_menuObj setObject:_txtPincode.text forKey:@"pinCode"];
    
    NSNumber *hourlyWage = [NSNumber numberWithFloat:[_txtHourlyWage.text floatValue]];

    _menuObj[@"hourlyWage"] = hourlyWage;
    
    // Get Color Picker Value
    NSInteger colorIndex = [_pickerColor selectedRowInComponent:0];
    [_menuObj setObject:@(colorIndex) forKey:@"colorIndex"];
    // NSString *colorStr = COLOR_ARRAY[colorIndex];
    
    [CommParse updateQuoteRequest:self Quote:_menuObj];
    
    
}

- (void)commsDidAction:(NSDictionary *)response {
    [ProgressHUD dismiss];
    
    if ([response[@"action"] intValue] == 2) {
        if ([response[@"responseCode"] boolValue]) {
            
            // Dismiss modal window
            [self dismissViewControllerAnimated:YES completion:nil];
            // Menus Refresh
            
            [_parentDelegate showBusinessMenus:_menuType];
            
        } else {
            [ProgressHUD showError:[response valueForKey:@"errorMsg"]];
        }
    }
}

@end
