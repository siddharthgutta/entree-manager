//
//  PrintJob.m
//  Entreé Manager
//
//  Created by Tanner on 9/10/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "PrintJob.h"

@implementation PrintJob

PARSE_CLASS_NAME
PARSE_REGISTER_CLASS

@dynamic printer;
@dynamic text;

+ (PFQuery *)queryCurrentRestaurant {
    return [[self query] whereKey:@"printer" matchesQuery:[StarPrinter queryCurrentRestaurant]];
}

@end
