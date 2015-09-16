//
//  Table.m
//  Entreé Manager
//
//  Created by Tanner on 9/10/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "Table.h"

@implementation Table

PARSE_CLASS_NAME
PARSE_REGISTER_CLASS

@dynamic capacity;
@dynamic currentParty;
@dynamic restaurant;
@dynamic name;
@dynamic shortName;
@dynamic type;
@dynamic x;
@dynamic y;

+ (NSString *)restaurantRelationPath {
    return @"restaurant";
}

@end
