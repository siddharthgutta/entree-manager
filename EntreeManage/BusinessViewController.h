//
//  BusinessViewController.h
//  EntreeManage
//
//  Created by Faraz on 7/30/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusinessViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>{

}
@property (strong, nonatomic) IBOutlet UITableView *menuView;

-(void)showBusinessMenus:(NSString*)MenuType;

@end
