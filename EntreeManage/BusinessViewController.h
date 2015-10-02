//
//  BusinessViewController.h
//  EntreeManage
//
//  Created by Faraz on 7/30/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"
#import "EmployeeMenuModifierViewController.h"

@interface BusinessViewController : EmployeeMenuModifierViewController <UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate, UIActionSheetDelegate>

- (void)reloadMenus;
- (void)reloadMenuModifiers;
- (void)reloadEmployees;

@end
