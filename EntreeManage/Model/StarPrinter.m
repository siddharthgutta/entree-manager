//
//  StarPrinter.m
//  Entreé Manager
//
//  Created by Tanner on 9/10/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "StarPrinter.h"

@implementation StarPrinter

PARSE_CLASS_NAME
PARSE_REGISTER_CLASS

@dynamic mac;
@dynamic nickname;
@dynamic restaurant;

+ (PFQuery *)queryCurrentRestaurant {
    return [[self query] whereKey:@"restaurant" matchesQuery:[Restaurant queryUnderCurrentRestaurant]];
}

@end
