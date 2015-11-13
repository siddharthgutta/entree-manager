//
//  Payment.m
//  EntreeManage
//
//  Created by Tanner on 8/27/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "Payment.h"

@implementation Payment

PARSE_CLASS_NAME
PARSE_REGISTER_CLASS

@dynamic restaurant;
@dynamic cardFlightChargeToken;
@dynamic cardLastFour;
@dynamic cardName;
@dynamic order;
@dynamic party;
@dynamic type;
@dynamic cashAmountPaid;
@dynamic changeGiven;
@dynamic charged;

+ (PFQuery *)queryCurrentRestaurant {
    return [[self query] whereKey:@"restaurant" matchesQuery:[Restaurant queryUnderCurrentRestaurant]];
}

@end
