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
    NSMutableArray *menuS;
    NSMutableArray *categoryS;
    NSMutableArray *itemS;
    
    // tableviews' selected index key string save
    NSMutableArray *selectedKey_s;
    
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
    [CommParse getBusinessMenus:self menuType:@"Menu" topKey:@"" topObject:nil];
    
    // init key array
    selectedKey_s = [NSMutableArray array];
    for(PFObject *item in self.selectedItems){
        [selectedKey_s addObject:item.objectId];
    }
    
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger nums;
    if (tableView == _menuView) nums = menuS.count;
    else if (tableView == _categoryView) nums = categoryS.count;
    else if (tableView == _itemView) nums = itemS.count;
    
    return nums;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId;
    NSMutableArray *cellS;
    
    if (tableView == _menuView) {
        cellId = @"cellMenuInModifier";
        cellS = menuS;
    }
    else if (tableView == _categoryView) {
        cellId = @"cellCategoryInModifier";
        cellS = categoryS;
    }
    else if (tableView == _itemView) {
        cellId = @"cellItemInModifier";
        cellS = itemS;
        
    }
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }

    PFObject *item = cellS[indexPath.row];
    
    // Item Table Multi select with Check Accessory Type
    if (tableView==_itemView) {
        
        // NSString *keyString = [NSString stringWithFormat:@"%ld-%ld-%ld", selectedIndex1, selectedIndex2, indexPath.row];
        NSString *keyString = item.objectId;
        
        BOOL isContain = [selectedKey_s containsObject:keyString];
        if (isContain) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSString *name = item[@"name"];
    cell.textLabel.text = name;
    
    
    return cell;
}
// table cell tapping - click
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == _menuView) {
        [CommParse getBusinessMenus:self menuType:@"MenuCategory" topKey:@"menu" topObject:menuS[indexPath.row]];
    }
    else if (tableView == _categoryView) {
        [CommParse getBusinessMenus:self menuType:@"MenuItem" topKey:@"menuCategory" topObject:categoryS[indexPath.row]];
    }
    else if (tableView == _itemView) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        PFObject *item = itemS[indexPath.row];
        
        
        NSString *keyString = item.objectId;
        
        if ([selectedKey_s containsObject:keyString]) {
            [selectedKey_s removeObject:keyString];
            [self.selectedItems removeObject:item];
        }
        else {
            [selectedKey_s addObject:keyString];
            [self.selectedItems addObject:item];
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
    [_parentDelegate returnSelectedItems:self.selectedItems];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)commsDidAction:(NSDictionary *)response {
    [ProgressHUD dismiss];
    if ([response[@"action"] intValue] == 1) {
        
       
        if ([response[@"responseCode"] boolValue]) {
            if ([response[@"menu_type"] isEqualToString:@"Menu"]) {
                menuS = [NSMutableArray array];
                menuS = response[@"objects"];
                [_menuView reloadData];
            }
            else if ([response[@"menu_type"] isEqualToString:@"MenuCategory"]) {
                categoryS = [NSMutableArray array];
                categoryS = response[@"objects"];
                [_categoryView reloadData];
            }
            else {
                itemS = [NSMutableArray array];
                itemS = response[@"objects"];
                [_itemView reloadData];
            }
        } else {
            [ProgressHUD showError:[response valueForKey:@"errorMsg"]];
        }
    }

}


@end
