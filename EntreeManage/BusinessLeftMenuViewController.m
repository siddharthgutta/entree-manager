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

@interface BusinessLeftMenuViewController (){
    NSMutableArray * menuItemsArray;
}

@end

@implementation BusinessLeftMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    // Left menu show for each tab
    menuItemsArray = [[NSMutableArray alloc]init];
    //NSMutableArray * menuAnalyticsArr = [[NSMutableArray alloc] initWithObjects:@"Sales Summary", @"Category Sales", @"Employee Shifts", @"Payroll", @"Order Report", @"By Payment Type", @"Modifier Sales", nil];
    NSMutableArray * menuBusinessArr = [[NSMutableArray alloc] initWithObjects:@"Menu Builder", @"Menu Modifiers", @"Employees", nil];
    
    //if(self.tabBarController.tabBar.selectedItem.tag==1){
        menuItemsArray =  menuBusinessArr;
    //}
    //else if(self.tabBarController.tabBar.selectedItem.tag==2) {
    //    menuItemsArray = menuAnalyticsArr;
    //}
    
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [menuItemsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * CellIdentifier = @"LeftMenuCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    // Configure the cell...
    cell.textLabel.text = menuItemsArray[indexPath.row];
 
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[self changeLeftMenuSel:self.tabBarController.tabBar.selectedItem.tag LeftMenuID:(NSInteger)indexPath.row];
    [self changeLeftMenuSel:1 LeftMenuID:(NSInteger)indexPath.row];
}


/*
    descript:   change view content for tab, left menu
    param:      tab ID, left menu ID
*/
-(void)changeLeftMenuSel:(NSInteger)tabId LeftMenuID:(NSInteger)leftMenuID{
    //Summary
    //if(tabId==0){
        
    //}
    //else if(tabId==1){
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
            menuType = @"MenuItemModifier";
            viewInstance.title = @"Menu Modifiers";
            [viewInstance showBusinessMenus:menuType];
        }
        else {
            menuType = @"Employee";
            viewInstance.title = @"Employees";
            [viewInstance showBusinessMenus:menuType];
        }
        
    //}
}


@end
