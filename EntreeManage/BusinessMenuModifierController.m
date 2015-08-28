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
    [CommParse getBusinessMenus:self MenuType:@"MenuItemModifier" TopKey:@"" TopObject:nil];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return quotes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"modifierMenuCell"];
    
    PFObject *menu_obj = quotes[indexPath.row];
    
    NSString *name = [PFUtils getProperty:@"name" InObject:menu_obj];
    cell.textLabel.text = name;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
        
        quotes = [[NSArray alloc] init];
        if ([response[@"responseCode"] boolValue]) {
            
            quotes = response[@"objects"];
        } else {
            [ProgressHUD showError:[response valueForKey:@"errorMsg"]];
        }
        [self.tableView reloadData];
    }
}

@end
