//
//  BusinessViewController.m
//  EntreeManage
//
//  Created by Faraz on 7/30/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "BusinessViewController.h"

#import "BusinessMenuCategoryController.h"
#import "BusinessMenuAddController.h"
#import "BusinessMenuModifierAddController.h"
#import "BusinessEmployeeAddController.h"
#import "MGSwipeButton.h"

@implementation  BusinessViewController {
    NSMutableArray *quotes;
    NSIndexPath *selectedIndexPath;
    NSString *selectedMenuType;
    BOOL updateFlag;
}

@synthesize menuView;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueCategoryMenu"]) {
        BusinessMenuCategoryController *destController = segue.destinationViewController;
        destController.topMenuObj = quotes[selectedIndexPath.row];
    }
    //  go to add menu popup
    else if ([segue.identifier isEqualToString:@"segueBusinessMenuAdd"]) {
        
        BusinessMenuAddController *destController = segue.destinationViewController;
        destController.menuType = selectedMenuType;
        if (updateFlag) destController.menuOrCategory = quotes[selectedIndexPath.row];
        destController.parentDelegate = self;
    }
    //  go to add Menu Modifier popup
    else if ([segue.identifier isEqualToString:@"segueBusinessMenuModifierAdd"]) {
        
        BusinessMenuModifierAddController *destController = segue.destinationViewController;
        destController.menuType = selectedMenuType;
        if (updateFlag) destController.menuObj = quotes[selectedIndexPath.row];
        destController.parentDelegate = self;
    }
    //  go to add Menu Business popup
    else if ([segue.identifier isEqualToString:@"segueBusinessMenuEmployeeAdd"]) {
        
        BusinessEmployeeAddController *destController = segue.destinationViewController;
        destController.menuType = selectedMenuType;
        if (updateFlag) destController.employee = quotes[selectedIndexPath.row];
        destController.parentDelegate = self;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItemClicked)];
    
    self.navigationItem.rightBarButtonItems = @[addButton];
    
    self.title = @"Menu";
    [self showBusinessMenus:@"Menu"];
    
}

- (void)addItemClicked {
    updateFlag = false;
    if ([selectedMenuType isEqualToString:@"Menu"]) {
        [self performSegueWithIdentifier:@"segueBusinessMenuAdd" sender:self];
    }
    else if ([selectedMenuType isEqualToString:@"MenuItemModifier"]) {
        [self performSegueWithIdentifier:@"segueBusinessMenuModifierAdd" sender:self];
    }
    else if ([selectedMenuType isEqualToString:@"Employee"]) {
        [self performSegueWithIdentifier:@"segueBusinessMenuEmployeeAdd" sender:self];
    }
}

- (void)updateItemClicked {
    updateFlag = true;
    if ([selectedMenuType isEqualToString:@"Menu"]) {
        [self performSegueWithIdentifier:@"segueBusinessMenuAdd" sender:self];
    }
    else if ([selectedMenuType isEqualToString:@"MenuItemModifier"]) {
        [self performSegueWithIdentifier:@"segueBusinessMenuModifierAdd" sender:self];
    }
    else if ([selectedMenuType isEqualToString:@"Employee"]) {
        [self performSegueWithIdentifier:@"segueBusinessMenuEmployeeAdd" sender:self];
    }
}


//==================================================
// UITableView Methods
//==================================================
#pragma mark- UITableView DataSource Methods
//==================================================

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return quotes.count;
}


// table cell update
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"businessCell";
    
    // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    MGSwipeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    PFObject *menuObj = quotes[indexPath.row];
    
    NSString *name = menuObj[@"name"];
    cell.textLabel.text = name;
    cell.delegate = self;
    cell.allowsMultipleSwipe = FALSE;
    
    
    cell.leftSwipeSettings.transition = MGSwipeTransition3D;
    cell.rightSwipeSettings.transition = MGSwipeTransition3D;
    cell.leftExpansion.buttonIndex = -1;
    cell.leftExpansion.fillOnTrigger = NO;
    
    cell.rightExpansion.buttonIndex = -1;
    cell.rightExpansion.fillOnTrigger = YES;
    cell.rightButtons = [self createRightButtons:2];
    
    return cell;
}

-(NSArray *)swipeTableCell:(MGSwipeTableCell *)cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings *)swipeSettings expansionSettings:(MGSwipeExpansionSettings *)expansionSettings; {
    
    swipeSettings.transition = MGSwipeTransition3D;
    
    
    expansionSettings.buttonIndex = -1;
    expansionSettings.fillOnTrigger = YES;
    return [self createRightButtons:2];
    
}

-(NSArray *)createRightButtons: (int) number {
    NSMutableArray *result = [NSMutableArray array];
    NSString *titles[2] = {@"Delete", @"Edit"};
    UIColor *colors[2] = {[UIColor redColor], [UIColor lightGrayColor]};
    for (int i = 0; i < number; ++i) {
        MGSwipeButton *button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] callback:^BOOL(MGSwipeTableCell *sender){
            NSLog(@"Convenience callback received (right).");
            BOOL autoHide = i != 0;
            return autoHide; // Don't autohide in delete button to improve delete expansion animation
        }];
        [result addObject:button];
    }
    return result;
}


- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion {
    
    // delete button
    NSIndexPath *path = [menuView indexPathForCell:cell];
    if (index == 0) {
        // delete button
        [CommParse deleteQuoteRequest:self Quote:quotes[path.row]];
        
        [quotes removeObjectAtIndex:path.row];
        [menuView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
        return NO; // Don't autohide to improve delete expansion animation
    }
    // edit button
    else if (index==1){
        selectedIndexPath = path;
        [self updateItemClicked];
    }
    return YES;
}

// table cell tapping - click
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedIndexPath = indexPath;
    
    // sub menu show when menu Type = "Menu"
    if ([selectedMenuType isEqualToString:@"Menu"]) {
        [self performSegueWithIdentifier:@"segueCategoryMenu" sender:self];
    }
    // go to Edit Mode- Modifier
    else if ([selectedMenuType isEqualToString:@"MenuItemModifier"]) {
        updateFlag = true;
        [self performSegueWithIdentifier:@"segueBusinessMenuModifierAdd" sender:self];
    }
    // go to Edit Mode- Employee
    else if ([selectedMenuType isEqualToString:@"Employee"]) {
        updateFlag = true;
        [self performSegueWithIdentifier:@"segueBusinessMenuEmployeeAdd" sender:self];
    }
}


// show business Menus func
- (void)showBusinessMenus:(NSString *)MenuType {
    
    selectedMenuType = MenuType;
    
    [ProgressHUD show:@"" Interaction:NO];
    [CommParse getBusinessMenus:self menuType:MenuType topKey:@"" topObject:nil];
    
}


//==================================================
// Comms Methods
//==================================================
#pragma mark- Comms Delegate Methods
//==================================================
- (void)commsDidAction:(NSDictionary *)response {
    [ProgressHUD dismiss];
    if ([response[@"action"] intValue] == 1) {
        quotes = [NSMutableArray array];
        if ([response[@"responseCode"] boolValue]) {
            
            quotes = response[@"objects"];
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
