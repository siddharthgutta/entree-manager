//
//  Order.m
//  EntreeManage
//
//  Created by Tanner on 8/29/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "Order.h"

@implementation Order

PARSE_CLASS_NAME
PARSE_REGISTER_CLASS

@dynamic installation;
@dynamic orderItems;
@dynamic payment;
@dynamic party;
@dynamic server;
@dynamic restaurant;
@dynamic amountDue;
@dynamic subtotal;
@dynamic tax;
@dynamic tip;
@dynamic total;
@dynamic type;

+ (PFQuery *)queryCurrentRestaurant {
    return [[self query] whereKey:@"restaurant" matchesQuery:[Restaurant queryUnderCurrentRestaurant]];
}

@end
