//
//  BusinessMenuItemController.m
//  EntreeManage
//
//  Created by Faraz on 7/30/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "BusinessMenuItemController.h"
#import "BusinessMenuModifierController.h"
#import "BusinessMenuItemAddController.h"

@interface BusinessMenuItemController ()<CommsDelegate>
{
    NSArray *quotes;
    NSIndexPath *selectedIndexPath;
}

@end

@implementation BusinessMenuItemController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"segueModifierMenu"]){
        BusinessMenuItemController *destController = segue.destinationViewController;
        destController.topMenuObj = quotes[selectedIndexPath.row];
    }
    //  go to add menu popup
    else if([segue.identifier isEqualToString:@"segueBusinessMenuItemAdd"]){
        
        BusinessMenuItemAddController *destController = segue.destinationViewController;
        destController.menuType = @"MenuItem";
    }

}


- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItemClicked)];
    
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.title = @"Menu Items";
    [ProgressHUD show:@"" Interaction:NO];
    [CommParse getBusinessMenus:self MenuType:@"MenuItem" TopKey:@"menuCategory" TopObject:self.topMenuObj];
}

-(void)addItemClicked{
    [self performSegueWithIdentifier:@"segueBusinessMenuItemAdd" sender:self];
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
    return [quotes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemMenuCell"];
    
    
    PFObject *menu_obj = [quotes objectAtIndex:indexPath.row];
    
    NSString *name = [PFUtils getProperty:@"name" InObject:menu_obj];
    cell.textLabel.text = name;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"segueModifierMenu" sender:self];
    
    
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
        [self.tableView reloadData];
    }
}

@end
