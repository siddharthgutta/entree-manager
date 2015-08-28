//
//  AnalyticsLeftMenuController.m
//  EntreeManage
//
//  Created by Faraz on 8/6/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "AnalyticsLeftMenuController.h"
#import "AnalyticsViewController.h"

@interface AnalyticsLeftMenuController (){
    NSMutableArray *menuItemss;
    NSMutableArray *menuSegueIds;
    
}

@end

@implementation AnalyticsLeftMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.maximumPrimaryColumnWidth = 220;
    self.splitViewController.maximumPrimaryColumnWidth = self.maximumPrimaryColumnWidth;
    
    // Left menu show for each tab
    menuItemss = [[NSMutableArray alloc] initWithObjects:@"Sales Summary", @"Category Sales", @"Employee Shifts", @"Payroll", @"Order Report", @"Modifier Sales", nil];
    menuSegueIds =[[NSMutableArray alloc] initWithObjects:@"SalesSummary", @"CategorySales", @"EmployeeShifts", @"Payroll", @"OrderReport", @"ModifierSales", nil];
    [self.tableView reloadData];
    
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return menuItemss.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"LeftMenuCell";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    // Configure the cell...
    cell.textLabel.text = menuItemss[indexPath.row];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[self changeLeftMenuSel:self.tabBarController.tabBar.selectedItem.tag LeftMenuID:(NSInteger)indexPath.row];
    [self changeLeftMenuSel:(NSInteger)indexPath.row];
}


/*
 descript:   change view content for tab, left menu
 param:      tab ID, left menu ID
 */
- (void)changeLeftMenuSel:(NSInteger)leftMenuID {
    
    NSString *menuType;
    UINavigationController *nc = (UINavigationController *)self.parentViewController;
    UISplitViewController *splitVC = (UISplitViewController *)nc.parentViewController;
    
    nc = (UINavigationController *)splitVC.viewControllers[1];
    AnalyticsViewController *viewInstance = (AnalyticsViewController *)nc.childViewControllers[0];    
    
    // get segue id
    menuType = [@"segueAnalytics" stringByAppendingString:menuSegueIds[leftMenuID]];
    [viewInstance showAnalyticsPage:menuType];
    
}


@end
