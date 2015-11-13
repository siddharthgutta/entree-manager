//
//  BusinessMenuAddController.h
//  EntreeManage
//
//  Created by Faraz on 7/31/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusinessMenuAddController : UIViewController
@property (nonatomic) PFObject *menuOrCategory;
@property (nonatomic) Menu *menuForCategory;
@property (nonatomic) NSString *menuType;

@property (nonatomic, assign) id parentDelegate;
@end
