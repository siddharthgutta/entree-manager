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
    // Do any additional setup after loading the view.
    [CommParse getBusinessMenus:self MenuType:@"Menu" TopKey:@"" TopObject:nil];
    
    // init key array
    selectedKey_s = [[NSMutableArray alloc] init];
    for(PFObject *itemObj in self.selectedItems){
        [selectedKey_s addObject:itemObj.objectId];
    }
    
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger nums;
    if(tableView == _menuView) nums = menuS.count;
    else if(tableView == _categoryView) nums = categoryS.count;
    else if(tableView == _itemView) nums = itemS.count;
    
    return nums;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId;
    NSMutableArray *cellS;
    
    if(tableView == _menuView) {
        cellId = @"cellMenuInModifier";
        cellS = menuS;
    }
    else if(tableView == _categoryView) {
        cellId = @"cellCategoryInModifier";
        cellS = categoryS;
    }
    else if(tableView == _itemView) {
        cellId = @"cellItemInModifier";
        cellS = itemS;
        
    }
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];

    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }

    PFObject *itemObj = cellS[indexPath.row];
    
    // Item Table Multi select with Check Accessory Type
    if(tableView==_itemView){
        
        // NSString *keyString = [NSString stringWithFormat:@"%ld-%ld-%ld", selectedIndex1, selectedIndex2, indexPath.row];
        NSString *keyString = itemObj.objectId;
        
        BOOL isContain = [selectedKey_s containsObject:keyString];
        if(isContain) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSString *name = [PFUtils getProperty:@"name" InObject:itemObj];
    cell.textLabel.text = name;
    
    
    return cell;
}
// table cell tapping - click
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == _menuView) {
        [CommParse getBusinessMenus:self MenuType:@"MenuCategory" TopKey:@"menu" TopObject:menuS[indexPath.row]];
    }
    else if(tableView == _categoryView) {
        [CommParse getBusinessMenus:self MenuType:@"MenuItem" TopKey:@"menuCategory" TopObject:categoryS[indexPath.row]];
    }
    else if(tableView == _itemView) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        PFObject *itemObj = itemS[indexPath.row];
        
        
        NSString *keyString = itemObj.objectId;
        
        if([selectedKey_s containsObject:keyString]){
            [selectedKey_s removeObject:keyString];
            [self.selectedItems removeObject:itemObj];
        }
        else {
            [selectedKey_s addObject:keyString];
            [self.selectedItems addObject:itemObj];
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
    [_parent_delegate returnSelectedItems:self.selectedItems];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)commsDidAction:(NSDictionary *)response {
    [ProgressHUD dismiss];
    if ([response[@"action"] intValue] == 1) {
        
       
        if ([response[@"responseCode"] boolValue]) {
            if([response[@"menu_type"] isEqualToString:@"Menu"]) {
                menuS = [[NSMutableArray alloc] init];
                menuS = response[@"objects"];
                [_menuView reloadData];
            }
            else if([response[@"menu_type"] isEqualToString:@"MenuCategory"]) {
                categoryS = [[NSMutableArray alloc] init];
                categoryS = response[@"objects"];
                [_categoryView reloadData];
            }
            else {
                itemS = [[NSMutableArray alloc] init];
                itemS = response[@"objects"];
                [_itemView reloadData];
            }
        } else {
            [ProgressHUD showError:[response valueForKey:@"errorMsg"]];
        }
    }

}


@end
