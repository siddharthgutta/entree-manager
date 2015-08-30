//
//  OrderItem.h
//  EntreeManage
//
//  Created by Tanner on 8/29/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <Parse/Parse.h>
@class MenuItem, Order;


@interface OrderItem : PFObject<PFSubclassing>

@property (nonatomic) MenuItem  *menuItem;
@property (nonatomic) NSArray   *menuModifiers;
@property (nonatomic) NSString  *notes;
@property (nonatomic) BOOL      onTheHouse;
@property (nonatomic) Order     *order;
@property (nonatomic) id        party;
@property (nonatomic) NSInteger seatNumber;
@property (nonatomic) NSInteger timesPrinted;

@end
