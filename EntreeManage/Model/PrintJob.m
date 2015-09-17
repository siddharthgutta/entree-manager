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

+ (NSString *)restaurantRelationPath {
    return @"printer.restaurant";
}

+ (NSString *)restaurantRelationPathByClassNames {
    return @"StarPrinter.Restaurant";
}

@end
