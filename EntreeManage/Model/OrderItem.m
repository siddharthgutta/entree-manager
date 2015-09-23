//
//  OrderItem.m
//  EntreeManage
//
//  Created by Tanner on 8/29/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "OrderItem.h"

@implementation OrderItem

PARSE_CLASS_NAME
PARSE_REGISTER_CLASS

@dynamic menuItem;
@dynamic menuItemModifiers;
@dynamic notes;
@dynamic onTheHouse;
@dynamic order;
@dynamic party;
@dynamic seatNumber;
@dynamic timesPrinted;

+ (PFQuery *)queryCurrentRestaurant {
    return [[self query] whereKey:@"order" matchesQuery:[Order queryCurrentRestaurant]];
}

- (CGFloat)netProfit {
    if (self.onTheHouse) return 0;
    return self.menuItem.price;
}

@end
