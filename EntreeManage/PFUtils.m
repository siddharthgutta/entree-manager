//
//  PFUtils.m
//  BupVIP-Host
//
//  Created by Faraz on 7/25/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import "PFUtils.h"

@implementation PFUtils

+ (BOOL)exists:(NSString *)key InObject:(PFObject *)object
{
    return [[object allKeys] containsObject:key];
    
}

+ (id)getProperty:(NSString *)propertyName InObject:(PFObject *)object
{
    id value = nil;
    if ([PFUtils exists:propertyName InObject:object]) {
        value = object[propertyName];
    }
    
    return value;
}

+ (id)getData:(NSString *)colName WithKey:(NSString *)key InObject:(PFObject *)object
{
    id data = nil;
    NSArray *array = [PFUtils getProperty:colName InObject:object];
    for (NSDictionary *elementDict in array) {
        NSString *firstKey = [[elementDict allKeys] firstObject];
        if ([firstKey isEqualToString:key]) {
            data = elementDict[key];
            break;
        }
    }
    
    return data;
}

@end
