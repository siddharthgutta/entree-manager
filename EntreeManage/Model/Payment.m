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

@dynamic cardFlightChargeToken;
@dynamic cardLastFour;
@dynamic cardName;
@dynamic order;
@dynamic party;
@dynamic restaurant;
@dynamic subtotal;
@dynamic tax;
@dynamic tip;
@dynamic total;
@dynamic type;

+ (NSString *)restaurantRelationPath {
    return @"restaurant";
}

+ (NSString *)restaurantRelationPathByClassNames {
    return @"Restaurant";
}

@end
