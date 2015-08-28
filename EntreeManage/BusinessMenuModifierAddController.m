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
    NSMutableArray *selected_items;
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
    if([segue.identifier isEqualToString:@"segue_modifiertoitem"]){
        
       BusinessModifierItemSelController *destController = segue.destinationViewController;
        
        
        destController.selected_items = selected_items;
        
        destController.parent_delegate = self;
    }
}
- (void)returnSelectedItems:(NSMutableArray *)returns {
    selected_items = returns;
    [_menuView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    selected_items = [[NSMutableArray alloc] init];
    
    // Do any additional setup after loading the view.
    if(_menuObj!=nil){
        _txtName.text = [PFUtils getProperty:@"name" InObject:_menuObj];
        NSNumber *price = [PFUtils getProperty:@"price" InObject:_menuObj];
        
        _txtPrice.text = [NSString stringWithFormat:@"%f", [price floatValue]];
        [CommParse getMenuItemsOfModifier:self ModifierObject:_menuObj];
        
    }
}



#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return selected_items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellMenuItemsOfModfier"];
    
    PFObject *item_obj = selected_items[indexPath.row];
    
    NSString *name = [PFUtils getProperty:@"name" InObject:item_obj];
    cell.textLabel.text = name;
    
    
    return cell;
}

- (IBAction)onClickCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onClickSave:(id)sender {
    [ProgressHUD show:@"" Interaction:NO];
    
    // if not exist then add
    if(_menuObj==nil) {
        _menuObj = [PFObject objectWithClassName:_menuType];
    }
    
    [_menuObj setObject:_txtName.text forKey:@"name"];
    
    NSNumber *price = [NSNumber numberWithFloat:[_txtPrice.text floatValue]];
    
    // save selected items with relation
    relation = [_menuObj relationForKey:@"menuItems"];
    for(PFObject *item_obj in selected_items){
        [relation addObject:item_obj];
    }
    
    _menuObj[@"price"] = price;
    
    
    [CommParse updateQuoteRequest:self Quote:_menuObj];
}

- (void)commsDidAction:(NSDictionary *)response {
    [ProgressHUD dismiss];
    if ([response[@"action"] intValue] == 1) {
        selected_items = [[NSMutableArray alloc] init];
        if ([response[@"responseCode"] boolValue]) {
            
            selected_items = response[@"objects"];
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
            
            [_parent_delegate showBusinessMenus:_menuType];
            
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
