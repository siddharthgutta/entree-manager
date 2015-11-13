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
<<<<<<< HEAD
  
    // Left menu show for each tab
    menuItemsArray =  [[NSMutableArray alloc] initWithObjects:@"Menu Builder", @"Menu Modifiers", @"Employees", nil];
=======
>>>>>>> origin/tanner
    
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
<<<<<<< HEAD
    // Configure the cell...
    cell.textLabel.text = menuItemsArray[indexPath.row];
=======
    
    cell.textLabel.text = menuItemss[indexPath.row];
>>>>>>> origin/tanner
    
    return cell;
}

<<<<<<< HEAD
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[self changeLeftMenuSel:self.tabBarController.tabBar.selectedItem.tag LeftMenuID:(NSInteger)indexPath.row];
    [self changeLeftMenuSel:(NSInteger)indexPath.row];
}


/*
    descript:   change view content for tab, left menu
    param:      tab ID, left menu ID
*/
-(void)changeLeftMenuSel:(NSInteger)leftMenuID{
    //Summary
    
        NSString * menuType;
        UINavigationController *nc = (UINavigationController *)self.parentViewController;
        UISplitViewController *splitVC = (UISplitViewController *)nc.parentViewController;
        nc = (UINavigationController *)splitVC.viewControllers[1];
        BusinessViewController *viewInstance = (BusinessViewController *)nc.childViewControllers[0];
        
        
        //BusinessViewController *viewInstance = [self.storyboard instantiateViewControllerWithIdentifier:@"businessDetailBoard"];
        
        if(leftMenuID==0)   {
            viewInstance.title = @"Menus";
            menuType = @"Menu";
            [viewInstance showBusinessMenus:menuType];
            
        }
        else if(leftMenuID==1){
=======
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
>>>>>>> origin/tanner
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
<<<<<<< HEAD
        
   
=======
    }
>>>>>>> origin/tanner
}


@end
