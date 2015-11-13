//
//  Restaurant.h
//  Entreé Manager
//
//  Created by Tanner on 9/6/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <Parse/Parse.h>

@interface Restaurant : PFObject<PFSubclassing>

@property (nonatomic, readonly) PFRelation *menus;
@property (nonatomic) CGFloat    alcoholTaxRate;
@property (nonatomic) NSString   *location;
@property (nonatomic) NSString   *name;
@property (nonatomic) NSString   *phone;
@property (nonatomic) CGFloat    salesTaxRate;

+ (PFQuery *)queryUnderCurrentRestaurant;

@end
