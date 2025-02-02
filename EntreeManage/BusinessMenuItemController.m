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
#import "MGSwipeButton.h"

@interface BusinessMenuItemController ()<MGSwipeTableCellDelegate, UIActionSheetDelegate> {
    NSMutableArray *quotes;
    NSIndexPath *selectedIndexPath;
    BOOL updateFlag;
}

@end

@implementation BusinessMenuItemController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //  go to add menu popup
    if ([segue.identifier isEqualToString:@"segueBusinessMenuItemAdd"]) {
        
        BusinessMenuItemAddController *destController = segue.destinationViewController;
        destController.menuType = @"MenuItem";
        destController.menuCategory = (id)self.topMenuObj;
        if (updateFlag) destController.menuObj = quotes[selectedIndexPath.row];
        destController.parentDelegate = self;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItemClicked)];
    
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.title = @"Menu Items";
    [self reloadMenuItems];
}

- (void)reloadMenuItems {
    [ProgressHUD show:@"" Interaction:NO];
    [CommParse getMenuItemsOfMenuCategory:self.topMenuObj callback:^(NSArray *objects, NSError *error) {
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
    [self performSegueWithIdentifier:@"segueBusinessMenuItemAdd" sender:self];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return quotes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MGSwipeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemMenuCell"];
    
    PFObject *menuObj = quotes[indexPath.row];
    
    NSString *name = menuObj[@"name"];
    cell.textLabel.text = name;
    
    cell.delegate = self;
    cell.allowsMultipleSwipe = FALSE;
    
<<<<<<< HEAD
    cell.leftSwipeSettings.transition = MGSwipeTransition3D;
=======
    cell.leftSwipeSettings.transition  = MGSwipeTransition3D;
>>>>>>> origin/tanner
    cell.rightSwipeSettings.transition = MGSwipeTransition3D;
    cell.leftExpansion.buttonIndex     = -1;
    cell.leftExpansion.fillOnTrigger   = NO;
    
    cell.rightExpansion.buttonIndex   = -1;
    cell.rightExpansion.fillOnTrigger = YES;
    cell.rightButtons = [self createRightButtons:2];
    
    return cell;
}


- (NSArray *)swipeTableCell:(MGSwipeTableCell *)cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings *)swipeSettings expansionSettings:(MGSwipeExpansionSettings *)expansionSettings; {
    
    swipeSettings.transition = MGSwipeTransition3D;
    
    expansionSettings.buttonIndex = -1;
    expansionSettings.fillOnTrigger = YES;
    int buttonNums = 1;
    // if (selectedmodifier) buttonNums = 2;
    return [self createRightButtons:buttonNums];
    
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
    else if (index == 1){
        selectedIndexPath = path;
        updateFlag = true;
        [self performSegueWithIdentifier:@"segueBusinessMenuItemAdd" sender:self];
    }
    return YES;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedIndexPath = indexPath;
    updateFlag = true;
    [self performSegueWithIdentifier:@"segueBusinessMenuItemAdd" sender:self];
}

@end
