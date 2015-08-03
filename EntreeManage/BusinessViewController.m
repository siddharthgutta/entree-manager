//
//  BusinessViewController.m
//  EntreeManage
//
//  Created by Faraz on 7/30/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "BusinessViewController.h"
#import "CommParse.h"
#import "BusinessMenuCategoryController.h"
#import "BusinessMenuAddController.h"

@interface BusinessViewController ()<CommsDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSArray *quotes;
    NSIndexPath *selectedIndexPath;
    NSString *selectedMenuType;
}

@end

@implementation BusinessViewController
@synthesize menuView;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   if([segue.identifier isEqualToString:@"segueCategoryMenu"]){
        BusinessMenuCategoryController *destController = segue.destinationViewController;
        destController.topMenuObj = quotes[selectedIndexPath.row];
   }
    //  go to add menu popup
   else if([segue.identifier isEqualToString:@"segueBusinessMenuAdd"]){
       
       BusinessMenuAddController *destController = segue.destinationViewController;
       destController.menuType = @"Menu";
   }
    
}
    
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItemClicked)];
    
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.title = @"Menu";
    [self showBusinessMenus:@"Menu"];
    
}

- (void)addItemClicked {
    if([selectedMenuType isEqualToString:@"Menu"]){
        [self performSegueWithIdentifier:@"segueBusinessMenuAdd" sender:self];
    }
    else if([selectedMenuType isEqualToString:@"MenuItemModifier"]){
        
    }
    else if([selectedMenuType isEqualToString:@"Employee"]){
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//==================================================
// UITableView Methods
//==================================================
#pragma mark- UITableView DataSource Methods
//==================================================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [quotes count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"businessCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    PFObject *menu_obj = [quotes objectAtIndex:indexPath.row];
    
    NSString *name = [PFUtils getProperty:@"name" InObject:menu_obj];
    cell.textLabel.text = name;
    
    return cell;
}

#pragma mark- UITableView Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndexPath = indexPath;
    
    //sub menu show when menu Type = "Menu"
    if([selectedMenuType isEqualToString:@"Menu"]) {
        [self performSegueWithIdentifier:@"segueCategoryMenu" sender:self];
    }
}


// show business Menus func
-(void)showBusinessMenus:(NSString*)MenuType{
    
    selectedMenuType = MenuType;
    
    [ProgressHUD show:@"" Interaction:NO];
    [CommParse getBusinessMenus:self MenuType:MenuType TopKey:@"" TopObject:nil];
    
}


//==================================================
// Comms Methods
//==================================================
#pragma mark- Comms Delegate Methods
//==================================================
- (void)commsDidAction:(NSDictionary *)response
{
    [ProgressHUD dismiss];
    if ([[response objectForKey:@"action"] intValue] == 1) {
        quotes = [[NSArray alloc] init];
        if ([[response objectForKey:@"responseCode"] boolValue]) {
            
            quotes = [response objectForKey:@"objects"];
        } else {
            [ProgressHUD showError:[response valueForKey:@"errorMsg"]];
            
        }
        
        [menuView reloadData];
        UINavigationController *nc = (UINavigationController *)self.navigationController;
        if ([nc visibleViewController] != self) {
            [nc popToRootViewControllerAnimated:YES];
        }
    }
}


@end
