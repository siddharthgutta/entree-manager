//
//  BusinessMenuModifierAddController.m
//  EntreeManage
//
//  Created by Faraz on 8/3/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "BusinessMenuModifierAddController.h"
#import "BusinessViewController.h"
#import "BusinessModifierItemSelController.h"

@interface BusinessMenuModifierAddController ()<CommsDelegate,UITableViewDelegate, UITableViewDataSource> {
    PFRelation *relation;
    NSMutableArray *selectedItems;
}

- (IBAction)onClickCancel:(id)sender;
- (IBAction)onClickSave:(id)sender;
- (IBAction)onClickAddItems:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtPrice;

@property (weak, nonatomic) IBOutlet UITableView *menuView;


@end


@implementation BusinessMenuModifierAddController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //  go to add menuitems window popup
    if ([segue.identifier isEqualToString:@"segue_modifiertoitem"]) {
        
       BusinessModifierItemSelController *destController = segue.destinationViewController;
        
        
        destController.selectedItems = selectedItems;
        
        destController.parentDelegate = self;
    }
}
- (void)returnSelectedItems:(NSMutableArray *)returns {
    selectedItems = returns;
    [_menuView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    selectedItems = [NSMutableArray array];
    
    if (_menuObj!=nil) {
        _txtName.text = _menuObj[@"name"];
        NSNumber *price = _menuObj[@"price"];
        
        _txtPrice.text = [NSString stringWithFormat:@"%f", [price floatValue]];
        [CommParse getMenuItemsOfModifier:self ModifierObject:_menuObj];
        
    }
}



#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return selectedItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellMenuItemsOfModfier"];
    
    PFObject *itemObj = selectedItems[indexPath.row];
    
    NSString *name = itemObj[@"name"];
    cell.textLabel.text = name;
    
    
    return cell;
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
    
    // save selected items with relation
    relation = [_menuObj relationForKey:@"menuItems"];
    for(PFObject *itemObj in selectedItems){
        [relation addObject:itemObj];
    }
    
    _menuObj[@"price"] = price;
    
    
    [CommParse updateQuoteRequest:self Quote:_menuObj];
}

- (void)commsDidAction:(NSDictionary *)response {
    [ProgressHUD dismiss];
    if ([response[@"action"] intValue] == 1) {
        selectedItems = [NSMutableArray array];
        if ([response[@"responseCode"] boolValue]) {
            
            selectedItems = response[@"objects"];
        } else {
            [ProgressHUD showError:[response valueForKey:@"errorMsg"]];
        }
        
        [_menuView reloadData];
    }
    else if ([response[@"action"] intValue] == 2) {
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

// Add Items to Modifier
- (IBAction)onClickAddItems:(id)sender {

    // show item add window
    [self performSegueWithIdentifier:@"segue_modifiertoitem" sender:self];
    
    
}
@end
