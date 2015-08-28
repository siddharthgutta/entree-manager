//
//  BusinessModifierItemSelController.m
//  EntreeManage
//
//  Created by Faraz on 8/3/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "BusinessModifierItemSelController.h"
#import "BusinessMenuModifierAddController.h"

@interface BusinessModifierItemSelController ()<CommsDelegate,UITableViewDelegate, UITableViewDataSource> {
    PFRelation *relation;
    NSMutableArray *menu_s;
    NSMutableArray *category_s;
    NSMutableArray *item_s;
    
    // tableviews' selected index key string save
    NSMutableArray *selected_key_s;
    
}

- (IBAction)onClickCancel:(id)sender;
- (IBAction)onClickSave:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *menuView;
@property (weak, nonatomic) IBOutlet UITableView *categoryView;
@property (weak, nonatomic) IBOutlet UITableView *itemView;

@end

@implementation BusinessModifierItemSelController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [CommParse getBusinessMenus:self MenuType:@"Menu" TopKey:@"" TopObject:nil];
    
    // init key array
    selected_key_s = [[NSMutableArray alloc] init];
    for(PFObject *item_obj in self.selected_items){
        [selected_key_s addObject:item_obj.objectId];
    }
    
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger nums;
    if(tableView == _menuView) nums = menu_s.count;
    else if(tableView == _categoryView) nums = category_s.count;
    else if(tableView == _itemView) nums = item_s.count;
    
    return nums;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cell_id;
    NSMutableArray *cell_s;
    
    if(tableView == _menuView) {
        cell_id = @"cellMenuInModifier";
        cell_s = menu_s;
    }
    else if(tableView == _categoryView) {
        cell_id = @"cellCategoryInModifier";
        cell_s = category_s;
    }
    else if(tableView == _itemView) {
        cell_id = @"cellItemInModifier";
        cell_s = item_s;
        
    }
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];

    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }

    PFObject *item_obj = cell_s[indexPath.row];
    
    // Item Table Multi select with Check Accessory Type
    if(tableView==_itemView){
        
        // NSString *key_string = [NSString stringWithFormat:@"%ld-%ld-%ld", selected_index1, selected_index2, indexPath.row];
        NSString *key_string = item_obj.objectId;
        
        BOOL is_contain = [selected_key_s containsObject:key_string];
        if(is_contain) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSString *name = [PFUtils getProperty:@"name" InObject:item_obj];
    cell.textLabel.text = name;
    
    
    return cell;
}
// table cell tapping - click
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == _menuView) {
        [CommParse getBusinessMenus:self MenuType:@"MenuCategory" TopKey:@"menu" TopObject:menu_s[indexPath.row]];
    }
    else if(tableView == _categoryView) {
        [CommParse getBusinessMenus:self MenuType:@"MenuItem" TopKey:@"menuCategory" TopObject:category_s[indexPath.row]];
    }
    else if(tableView == _itemView) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        PFObject *item_obj = item_s[indexPath.row];
        
        
        NSString *key_string = item_obj.objectId;
        
        if([selected_key_s containsObject:key_string]){
            [selected_key_s removeObject:key_string];
            [self.selected_items removeObject:item_obj];
        }
        else {
            [selected_key_s addObject:key_string];
            [self.selected_items addObject:item_obj];
        }
        [tableView reloadData];
    }
    
}

- (IBAction)onClickCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onClickSave:(id)sender {
    //[ProgressHUD show:@"" Interaction:NO];
    
    // if not exist then add
    [_parent_delegate returnSelectedItems:self.selected_items];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)commsDidAction:(NSDictionary *)response {
    [ProgressHUD dismiss];
    if ([response[@"action"] intValue] == 1) {
        
       
        if ([response[@"responseCode"] boolValue]) {
            if([response[@"menu_type"] isEqualToString:@"Menu"]) {
                menu_s = [[NSMutableArray alloc] init];
                menu_s = response[@"objects"];
                [_menuView reloadData];
            }
            else if([response[@"menu_type"] isEqualToString:@"MenuCategory"]) {
                category_s = [[NSMutableArray alloc] init];
                category_s = response[@"objects"];
                [_categoryView reloadData];
            }
            else {
                item_s = [[NSMutableArray alloc] init];
                item_s = response[@"objects"];
                [_itemView reloadData];
            }
        } else {
            [ProgressHUD showError:[response valueForKey:@"errorMsg"]];
        }
    }

}


@end
