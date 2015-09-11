//
//  MenuItem.h
//  EntreeManage
//
//  Created by Tanner on 8/29/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <Parse/Parse.h>

@interface MenuItem : PFObject<PFSubclassing>

@property (nonatomic) NSString     *name;
@property (nonatomic) CGFloat      price;
@property (nonatomic) MenuCategory *menuCategory;
@property (nonatomic) BOOL         alcoholic;
@property (nonatomic) NSInteger    colorIndex;

/** Temporary assignable value */
@property (nonatomic          ) NSInteger saleCount;
/** saleCount x price */
@property (nonatomic, readonly) CGFloat   netSales;

@end
