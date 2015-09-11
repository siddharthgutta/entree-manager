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
@property (weak, nonatomic) IBOutlet UITextField *printerTextField;

@property (weak, nonatomic) IBOutlet UITableView *menuView;


@end


@implementation BusinessMenuModifierAddController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //  go to add menuitems window popup
    if ([segue.identifier isEqualToString:@"segue_modifiertoitem"]) {
        
        BusinessModifierItemSelController *destController = segue.destinationViewController;
        
        destController.selectedItems  = selectedItems;
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
    
    if (self.menuObj) {
        self.txtName.text = self.menuObj.name;
        self.txtPrice.text = [NSString stringWithFormat:@"%.2f", self.menuObj.price];
        self.printerTextField.text = self.menuObj.printText;
        [CommParse getMenuItemsOfModifier:self modifierect:self.menuObj];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return selectedItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellMenuItemsOfModfier"];
    
    PFObject *item = selectedItems[indexPath.row];
    
    cell.textLabel.text = item[@"name"];
    
    
    return cell;
}

- (IBAction)onClickCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onClickSave:(id)sender {
    [ProgressHUD show:@"" Interaction:NO];
    
    BOOL isNew = !self.menuObj;
    if (!self.menuObj) {
        self.menuObj = [MenuItemModifier object]; //[PFObject objectWithClassName:_menuType];
    }
    
    self.menuObj.name = self.txtName.text;
    self.menuObj.price = [self.txtPrice.text floatValue];
    self.menuObj.printText = self.printerTextField.text;
    
    // save selected items with relation
    relation = self.menuObj.menuItems;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Cannot remove objects on unsaved relation
        if (!isNew) [relation removeAllObjectsBlocking];
        dispatch_async(dispatch_get_main_queue(), ^{
            for(PFObject *item in selectedItems)
                [relation addObject:item];
            
            [CommParse updateQuoteRequest:self Quote:self.menuObj];
        });
    });
}

- (void)commsDidAction:(NSDictionary *)response {
    [ProgressHUD dismiss];
    if ([response[@"action"] intValue] == 1) {
        if ([response[@"responseCode"] boolValue]) {
            
            selectedItems = response[@"objects"];
        } else {
            selectedItems = [NSMutableArray array];
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
