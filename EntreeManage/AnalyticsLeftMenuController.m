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
    NSMutableArray * menuItemsArray;
    NSMutableArray * menuSegueIdArray;
    
}

@end

@implementation AnalyticsLeftMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.maximumPrimaryColumnWidth = 220;
    self.splitViewController.maximumPrimaryColumnWidth = self.maximumPrimaryColumnWidth;
    
    // Left menu show for each tab
    menuItemsArray = [[NSMutableArray alloc] initWithObjects:@"Sales Summary", @"Category Sales", @"Employee Shifts", @"Payroll", @"Order Report", @"Modifier Sales", nil];
    menuSegueIdArray= [[NSMutableArray alloc] initWithObjects:@"SalesSummary", @"CategorySales", @"EmployeeShifts", @"Payroll", @"OrderReport", @"ModifierSales", nil];
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
    
    UITableViewCell *cell =  [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    // Configure the cell...
    cell.textLabel.text = menuItemsArray[indexPath.row];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[self changeLeftMenuSel:self.tabBarController.tabBar.selectedItem.tag LeftMenuID:(NSInteger)indexPath.row];
    [self changeLeftMenuSel:(NSInteger)indexPath.row];
}


/*
 descript:   change view content for tab, left menu
 param:      tab ID, left menu ID
 */
-(void)changeLeftMenuSel:(NSInteger)leftMenuID{
    
    NSString * menuType;
    UINavigationController *nc = (UINavigationController *)self.parentViewController;
    UISplitViewController *splitVC = (UISplitViewController *)nc.parentViewController;
    
    nc = (UINavigationController *)splitVC.viewControllers[1];
    AnalyticsViewController *viewInstance = (AnalyticsViewController *)nc.childViewControllers[0];    
    
    //get segue id
    menuType = [@"segueAnalytics" stringByAppendingString:menuSegueIdArray[leftMenuID]];
    [viewInstance showAnalyticsPage:menuType];
    
}


@end
