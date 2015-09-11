//
//  BusinessMenuItemAddController.h
//  EntreeManage
//
//  Created by Faraz on 8/1/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusinessMenuItemAddController : UIViewController

@property (nonatomic) MenuItem *menuObj;
@property (nonatomic) NSString *menuType;
@property (nonatomic) MenuCategory *menuCategory;
@property (nonatomic, assign) id parentDelegate;

@end
