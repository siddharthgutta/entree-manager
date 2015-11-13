//
//  Refund.m
//  Entreé Manager
//
//  Created by Tanner on 9/10/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "Refund.h"

@implementation Refund

PARSE_CLASS_NAME
PARSE_REGISTER_CLASS

@dynamic payment;

+ (PFQuery *)queryCurrentRestaurant {
    return [[self query] whereKey:@"payment" matchesQuery:[Payment queryCurrentRestaurant]];
}

@end
