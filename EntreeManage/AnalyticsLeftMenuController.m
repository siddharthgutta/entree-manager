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
<<<<<<< HEAD
    NSMutableArray * menuItemsArray;
    NSMutableArray * menuSegueIdArray;
=======
    NSMutableArray *menuItemss;
    NSMutableArray *menuSegueIds;
>>>>>>> origin/tanner
    
}

@end

@implementation AnalyticsLeftMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.maximumPrimaryColumnWidth = 220;
    self.splitViewController.maximumPrimaryColumnWidth = self.maximumPrimaryColumnWidth;
    
    // Left menu show for each tab
<<<<<<< HEAD
    menuItemsArray = [[NSMutableArray alloc] initWithObjects:@"Sales Summary", @"Category Sales", @"Employee Shifts", @"Payroll", @"Order Report", @"By Payment Type", @"Modifier Sales", nil];
    menuSegueIdArray= [[NSMutableArray alloc] initWithObjects:@"SalesSummary", @"CategorySales", @"EmployeeShifts", @"Payroll", @"OrderReport", @"ByPaymentType", @"ModifierSales", nil];
=======
    menuItemss = [[NSMutableArray alloc] initWithObjects:@"Sales Summary", @"Category Sales", @"Employee Shifts", @"Payroll", @"Order Report", @"Modifier Sales", nil];
    menuSegueIds =[[NSMutableArray alloc] initWithObjects:@"SalesSummary", @"CategorySales", @"EmployeeShifts", @"Payroll", @"OrderReport", @"ModifierSales", nil];
>>>>>>> origin/tanner
    [self.tableView reloadData];
    
}

<<<<<<< HEAD
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
=======

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return menuItemss.count;
>>>>>>> origin/tanner
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
<<<<<<< HEAD
    static NSString * CellIdentifier = @"LeftMenuCell";
    
    UITableViewCell *cell =  [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    // Configure the cell...
    cell.textLabel.text = menuItemsArray[indexPath.row];
=======
    static NSString *CellIdentifier = @"LeftMenuCell";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    // Configure the cell...
    cell.textLabel.text = menuItemss[indexPath.row];
>>>>>>> origin/tanner
    
    
    return cell;
}

<<<<<<< HEAD
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
=======
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
>>>>>>> origin/tanner
    //[self changeLeftMenuSel:self.tabBarController.tabBar.selectedItem.tag LeftMenuID:(NSInteger)indexPath.row];
    [self changeLeftMenuSel:(NSInteger)indexPath.row];
}


/*
 descript:   change view content for tab, left menu
 param:      tab ID, left menu ID
 */
<<<<<<< HEAD
-(void)changeLeftMenuSel:(NSInteger)leftMenuID{
    
    NSString * menuType;
=======
- (void)changeLeftMenuSel:(NSInteger)leftMenuID {
    
    NSString *menuType;
>>>>>>> origin/tanner
    UINavigationController *nc = (UINavigationController *)self.parentViewController;
    UISplitViewController *splitVC = (UISplitViewController *)nc.parentViewController;
    
    nc = (UINavigationController *)splitVC.viewControllers[1];
    AnalyticsViewController *viewInstance = (AnalyticsViewController *)nc.childViewControllers[0];    
    
<<<<<<< HEAD
    //get segue id
    menuType = [@"segueAnalytics" stringByAppendingString:menuSegueIdArray[leftMenuID]];
=======
    // get segue id
    menuType = [@"segueAnalytics" stringByAppendingString:menuSegueIds[leftMenuID]];
>>>>>>> origin/tanner
    [viewInstance showAnalyticsPage:menuType];
    
}


@end
