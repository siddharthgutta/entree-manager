//
//  BusinessMenuCategoryController.m
//  EntreeManage
//
//  Created by Faraz on 7/30/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "BusinessMenuCategoryController.h"
#import "BusinessMenuItemController.h"
#import "BusinessMenuAddController.h"
#import "MGSwipeButton.h"

@interface BusinessMenuCategoryController ()<CommsDelegate, MGSwipeTableCellDelegate, UIActionSheetDelegate> {
    NSMutableArray *quotes;
    NSIndexPath *selectedIndexPath;
    BOOL updateFlag;
}

@end

@implementation BusinessMenuCategoryController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //  go to category menu view
    if ([segue.identifier isEqualToString:@"segueItemMenu"]) {
    
        BusinessMenuItemController *destController = segue.destinationViewController;
        destController.topMenuObj = quotes[selectedIndexPath.row];
    }
    //  go to add menu popup
    else if ([segue.identifier isEqualToString:@"segueBusinessMenuCategoryAdd"]) {
        
        BusinessMenuAddController *destController = segue.destinationViewController;
        if (updateFlag) destController.menuOrCategory = quotes[selectedIndexPath.row];
        destController.menuForCategory = (id)self.topMenuObj;
        destController.menuType = @"MenuCategory";
        destController.parentDelegate = self;
    }

}


- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItemClicked)];
    
    self.navigationItem.rightBarButtonItems = @[addButton];
    
    self.title = @"Menu Categories";
    [self reloadMenuCategories];
}

- (void)reloadMenuCategories {
    [ProgressHUD show:@"" Interaction:NO];
    [CommParse getMenuCategoriesOfMenu:self.topMenuObj callback:^(NSArray *objects, NSError *error) {
        [ProgressHUD dismiss];
        if (!error) {
            quotes = objects.mutableCopy;
            [self.tableView reloadData];
        } else {
            [ProgressHUD showError:error.localizedDescription];
        }
    }];
}

- (void)addItemClicked {
    updateFlag = false;
    [self performSegueWithIdentifier:@"segueBusinessMenuCategoryAdd" sender:self];
    
}

- (void)updateItemClicked {
    updateFlag = true;
    [self performSegueWithIdentifier:@"segueBusinessMenuCategoryAdd" sender:self];
    
}


#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return quotes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MGSwipeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categoryMenuCell"];
    
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

- (NSArray *)swipeTableCell:(MGSwipeTableCell *)cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings *)swipeSettings expansionSettings:(MGSwipeExpansionSettings *)expansionSettings; {
    
    swipeSettings.transition = MGSwipeTransition3D;
    
    expansionSettings.buttonIndex = -1;
    expansionSettings.fillOnTrigger = YES;
    return [self createRightButtons:2];
    
}

- (NSArray *)createRightButtons:(int)number {
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


- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion {
    // delete button
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    if (index == 0) {
        // delete button
        [CommParse deleteQuoteRequest:self Quote:quotes[path.row]];
        
        [quotes removeObjectAtIndex:path.row];
        [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
        return NO; // Don't autohide to improve delete expansion animation
    }
    // edit button
    else if (index==1){
        selectedIndexPath = path;
        [self updateItemClicked];
    }
    return YES;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"segueItemMenu" sender:self];
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
        [self.tableView reloadData];
    }
}


@end
