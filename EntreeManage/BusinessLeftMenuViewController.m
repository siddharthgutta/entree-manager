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
    //[self changeLeftMenuSel:self.tabBarController.tabBar.selectedItem.tag LeftMenuID:(NSInteger)indexPath.row];
    [self changeLeftMenuSel:(NSInteger)indexPath.row];
}

/*
 descript:   change view content for tab, left menu
 param:      tab ID, left menu ID
 */
- (void)changeLeftMenuSel:(NSInteger)leftMenuID {
    // Summary
    
    NSString *menuType;
    UINavigationController *nc = (UINavigationController *)self.parentViewController;
    UISplitViewController *splitVC = (UISplitViewController *)nc.parentViewController;
    nc = (UINavigationController *)splitVC.viewControllers[1];
    BusinessMenuItemController *viewInstance = (id)nc.childViewControllers[0];
    
    if (leftMenuID==0)   {
        viewInstance.title = @"Menus";
        menuType = @"Menu";
        [(id)viewInstance reloadMenus];
    }
    else if (leftMenuID==1) {
        menuType = @"MenuItemModifier";
        viewInstance.title = @"Menu Modifiers";
        [(id)viewInstance reloadMenus];
    }
    else {
        menuType = @"Employee";
        viewInstance.title = @"Employees";
        [(id)viewInstance reloadMenus];
    }
    
    
}


@end
