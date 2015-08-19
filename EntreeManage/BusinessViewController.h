//
//  BusinessViewController.h
//  EntreeManage
//
//  Created by Faraz on 7/30/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@interface BusinessViewController : UIViewController<CommsDelegate, UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate, UIActionSheetDelegate>{
   

}
@property (strong, nonatomic) IBOutlet UITableView *menuView;

-(void)showBusinessMenus:(NSString*)MenuType;

@end
