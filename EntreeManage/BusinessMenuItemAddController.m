//
//  BusinessMenuItemAddController.m
//  EntreeManage
//
//  Created by Faraz on 8/1/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "BusinessMenuItemAddController.h"
#import "BusinessViewController.h"

@interface BusinessMenuItemAddController ()<CommsDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    
}

- (IBAction)onClickCancel:(id)sender;
- (IBAction)onClickSave:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerColor;
@property (weak, nonatomic) IBOutlet UITextField *txtPrice;

@end

@implementation BusinessMenuItemAddController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_menuObj!=nil) {
        _txtName.text = _menuObj[@"name"];
        NSNumber *price = _menuObj[@"price"];
        
        _txtPrice.text = [NSString stringWithFormat:@"%f", [price floatValue]];
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


- (IBAction)onClickCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onClickSave:(id)sender {
    [ProgressHUD show:@"" Interaction:NO];
    
    // if not exist then add
    if (_menuObj==nil) {
        _menuObj = [PFObject objectWithClassName:_menuType];
    }
    
    _menuObj[@"name"] = _txtName.text;
    
    NSNumber *price = @([_txtPrice.text floatValue]);
    
    _menuObj[@"price"] = price;
    
    // Get Color Picker Value
    NSInteger colorIndex = [_pickerColor selectedRowInComponent:0];
    _menuObj[@"colorIndex"] = @(colorIndex);
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
