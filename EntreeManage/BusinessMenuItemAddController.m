//
//  BusinessMenuItemAddController.m
//  EntreeManage
//
//  Created by Faraz on 8/1/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "BusinessMenuItemAddController.h"
#import "BusinessViewController.h"
#import "BusinessMenuItemController.h"

@interface BusinessMenuItemAddController ()<CommsDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    
}

- (IBAction)onClickCancel:(id)sender;
- (IBAction)onClickSave:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerColor;
@property (weak, nonatomic) IBOutlet UITextField *txtPrice;
@property (weak, nonatomic) IBOutlet UITextField *printerTextField;

@end

@implementation BusinessMenuItemAddController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.menuObj) {
        self.txtName.text = self.menuObj[@"name"];
        NSNumber *price = self.menuObj[@"price"];
        
        self.txtPrice.text = [NSString stringWithFormat:@"%.2f", [price floatValue]];
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
    
    if (!self.menuObj) {
        self.menuObj = [MenuItem object];
    }
    
    self.menuObj.name = self.txtName.text;
    
    self.menuObj.price = [self.txtPrice.text floatValue];
    self.menuObj.menuCategory = self.menuCategory;
    
    // Get Color Picker Value
    NSInteger colorIndex = [self.pickerColor selectedRowInComponent:0];
    self.menuObj.colorIndex = colorIndex;
    // NSString *colorStr = COLOR_ARRAY[colorIndex];
    
    [CommParse updateQuoteRequest:self Quote:self.menuObj];
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
