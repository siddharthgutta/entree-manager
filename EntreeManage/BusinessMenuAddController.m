//
//  BusinessMenuAddController.m
//  EntreeManage
//
//  Created by Faraz on 7/31/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "BusinessMenuAddController.h"
#import "BusinessViewController.h"
#import "BusinessMenuItemController.h"

@interface BusinessMenuAddController ()<CommsDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    
}

- (IBAction)onClickCancel:(id)sender;
- (IBAction)onClickSave:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerColor;

@end

@implementation BusinessMenuAddController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.menuOrCategory) {
        self.txtName.text = self.menuOrCategory[@"name"];
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
    if (!self.menuOrCategory) {
        self.menuOrCategory = [PFObject objectWithClassName:self.menuType];
    }
    
    self.menuOrCategory[@"name"] = self.txtName.text;
    if (self.menuForCategory) self.menuOrCategory[@"menu"] = self.menuForCategory;
    
    // Get Color Picker Value
    NSInteger colorIndex = [_pickerColor selectedRowInComponent:0];
    self.menuOrCategory[@"colorIndex"] = @(colorIndex);
    // NSString *colorStr = COLOR_ARRAY[colorIndex];
    
    [CommParse updateQuoteRequest:self Quote:self.menuOrCategory];
}
- (void)commsDidAction:(NSDictionary *)response {
    [ProgressHUD dismiss];
    
    if ([response[@"action"] intValue] == 2) {
        if ([response[@"responseCode"] boolValue]) {
            
            // Dismiss modal window
            [self dismissViewControllerAnimated:YES completion:nil];
            // Menus Refresh
            [_parentDelegate reloadMenus];
            
        } else {
            [ProgressHUD showError:[response valueForKey:@"errorMsg"]];
        }
    }
}

@end
