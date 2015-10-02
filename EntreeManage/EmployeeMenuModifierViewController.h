//
//  EmployeeMenuModifierViewController.h
//  Entreé Manager
//
//  Created by Tanner on 10/2/15.
//  Copyright © 2015 Faraz. All rights reserved.
//

#import "MGSwipeTableCell.h"

@interface EmployeeMenuModifierViewController : UIViewController < CommsDelegate, UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate, UIActionSheetDelegate> {
    @public
    NSMutableArray *quotes;
    NSIndexPath *selectedIndexPath;
    NSString *selectedMenuType;
    BOOL updateFlag;
}


@property (strong, nonatomic) IBOutlet UITableView *menuView;

- (void)showBusinessMenus:(NSString *)MenuType;

@end