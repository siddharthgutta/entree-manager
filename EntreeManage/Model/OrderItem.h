//
//  OrderItem.h
//  EntreeManage
//
//  Created by Tanner on 8/29/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <Parse/Parse.h>
@class MenuItem, Order;


@interface OrderItem : PFObject<PFSubclassing, EMQuerying>

@property (nonatomic) MenuItem  *menuItem;
@property (nonatomic) NSArray   *menuItemModifiers;
@property (nonatomic) NSString  *notes;
@property (nonatomic) BOOL      onTheHouse;
@property (nonatomic) Order     *order;
@property (nonatomic) Party     *party;
@property (nonatomic) NSInteger seatNumber;
@property (nonatomic) NSInteger timesPrinted;

@property (nonatomic, readonly) CGFloat netProfit;

@end
