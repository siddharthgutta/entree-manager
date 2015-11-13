//
//  BusinessMenuItemController.h
//  EntreeManage
//
//  Created by Faraz on 7/30/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@interface BusinessMenuItemController : UITableViewController

@property (nonatomic) MenuCategory *topMenuObj;
- (void)reloadMenuItems;

@end

