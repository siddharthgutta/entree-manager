//
//  BusinessMenuModifierController.m
//  EntreeManage
//
//  Created by Faraz on 7/30/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "BusinessMenuModifierController.h"

@interface BusinessMenuModifierController ()<CommsDelegate> {
    NSArray *quotes;
    NSIndexPath *selectedIndexPath;
}


@end

@implementation BusinessMenuModifierController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.title = @"Menu Modifiers";
    [ProgressHUD show:@"" Interaction:NO];
    [CommParse getBusinessMenus:self menuType:@"MenuItemModifier" topKey:@"" topObject:nil];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return quotes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"modifierMenuCell"];
    
    PFObject *menuObj = quotes[indexPath.row];
    
    cell.textLabel.text = menuObj[@"name"];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedIndexPath = indexPath;
}

//==================================================
// Comms Methods
//==================================================
#pragma mark- Comms Delegate Methods
//==================================================
- (void)commsDidAction:(NSDictionary *)response {
    [ProgressHUD dismiss];
    if ([response[@"action"] intValue] == 1) {
        
        quotes = @[];
        if ([response[@"responseCode"] boolValue]) {
            
            quotes = response[@"objects"];
        } else {
            [ProgressHUD showError:[response valueForKey:@"errorMsg"]];
        }
        [self.tableView reloadData];
    }
}

@end
