//
//  MenuItemModifier.h
//  Entreé Manager
//
//  Created by Tanner on 9/10/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <Parse/Parse.h>

@interface MenuItemModifier : PFObject<PFSubclassing>

@property (nonatomic) PFRelation *menuItems;
@property (nonatomic) NSString   *name;
@property (nonatomic) NSString   *printText;
@property (nonatomic) CGFloat    price;

@end
