//
//  LeftMenuViewController.m
//  EntreeManage
//
//  Created by Faraz on 7/23/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "BusinessLeftMenuViewController.h"
#import "AppDelegate.h"
#import "DetailContentViewController.h"
#import "BusinessMenuModifierController.h"
#import "BusinessViewController.h"
#import "BusinessMenuItemController.h"
#import "EmployeeMenuModifierViewController.h"

@interface BusinessLeftMenuViewController (){
    NSMutableArray *menuItemss;
}

@end

@implementation BusinessLeftMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Left menu show for each tab
    menuItemss = [[NSMutableArray alloc] initWithObjects:@"Menu Builder", @"Menu Modifiers", @"Employees", nil];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return menuItemss.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"LeftMenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = menuItemss[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *menuType;
    UINavigationController *nc = (UINavigationController *)self.parentViewController;
    UISplitViewController *splitVC = (UISplitViewController *)nc.parentViewController;
    nc = (UINavigationController *)splitVC.viewControllers[1];
    BusinessViewController *viewInstance = (id)nc.childViewControllers[0];
    
    if (indexPath.row == 0)   {
        viewInstance.title = @"Menus";
        menuType = @"Menu";
        viewInstance->selectedMenuType = menuType;
        [viewInstance reloadMenus];
    }
    else {
        if (indexPath.row == 1) {
            menuType = @"MenuItemModifier";
            viewInstance.title = @"Menu Modifiers";
            viewInstance->selectedMenuType = menuType;
            [viewInstance reloadMenuModifiers];
        }
        else {
            menuType = @"Employee";
            viewInstance.title = @"Employees";
            viewInstance->selectedMenuType = menuType;
            [viewInstance reloadEmployees];
        }
    }
}


@end
