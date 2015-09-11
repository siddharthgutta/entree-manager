//
//  MenuCategory.h
//  EntreeManage
//
//  Created by Tanner on 8/30/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <Parse/Parse.h>

@interface MenuCategory : PFObject<PFSubclassing>

@property (nonatomic) Menu *menu;
@property (nonatomic) NSString *name;

/** Temporary assignable value */
@property (nonatomic) NSInteger saleCount;

@end
