//
//  BusinessEmployeeAddController.m
//  EntreeManage
//
//  Created by Faraz on 8/1/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "BusinessEmployeeAddController.h"
#import "BusinessViewController.h"
#import "BusinessMenuItemController.h"

@interface BusinessEmployeeAddController ()<CommsDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    
}

- (IBAction)onCancelClick:(id)sender;
- (IBAction)onClickSave:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField  *txtName;
@property (weak, nonatomic) IBOutlet UITextField  *txtRole;
@property (weak, nonatomic) IBOutlet UISwitch     *switchManager;
@property (weak, nonatomic) IBOutlet UITextField  *txtPincode;
@property (weak, nonatomic) IBOutlet UITextField  *txtHourlyWage;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerColor;


@end

@implementation BusinessEmployeeAddController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    if (_employee) {
        _txtName.text       = _employee.name;
        _txtRole.text       = _employee.role;
        _switchManager.on   = _employee.administrator;
        _txtPincode.text    = _employee.pinCode;

        _txtHourlyWage.text = [NSString stringWithFormat:@"%.2f", _employee.hourlyWage];
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
    if (!_employee) {
        _employee = [Employee object];
    }
    
    _employee.restaurant = [CommParse currentRestaurant];
    
    _employee.name = _txtName.text;
    _employee[@"role"] = _txtRole.text;
    
    _employee[@"administrator"] = @(_switchManager.on);
    _employee[@"pinCode"] = _txtPincode.text;
    
    NSNumber *hourlyWage = @([_txtHourlyWage.text floatValue]);
    
    _employee[@"hourlyWage"] = hourlyWage;
    
    // Get Color Picker Value
    NSInteger colorIndex = [_pickerColor selectedRowInComponent:0];
    _employee[@"colorIndex"] = @(colorIndex);
    // NSString *colorStr = COLOR_ARRAY[colorIndex];
    
    [CommParse updateQuoteRequest:self Quote:_employee];
    
    
}

- (void)commsDidAction:(NSDictionary *)response {
    [ProgressHUD dismiss];
    
    if ([response[@"action"] intValue] == 2) {
        if ([response[@"responseCode"] boolValue]) {
            
            // Dismiss modal window
            [self dismissViewControllerAnimated:YES completion:nil];
            // Menus Refresh
            
            if ([_parentDelegate respondsToSelector:@selector(reloadMenus)])
                [_parentDelegate reloadMenus];
            else
                [NSException raise:NSInternalInconsistencyException format:@"here"];
            
        } else {
            [ProgressHUD showError:[response valueForKey:@"errorMsg"]];
        }
    }
}

@end
