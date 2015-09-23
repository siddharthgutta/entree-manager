//
//  PFObject+QueryExtensions.m
//  EntreeManage
//
//  Created by Tanner on 8/30/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "PFObject+QueryExtensions.h"

@implementation PFObject (QueryExtensions)

+ (PFQuery *)queryForRestaurant {
    if ([self respondsToSelector:@selector(queryCurrentRestaurant)])
        return [(id)self queryCurrentRestaurant];
    return [self query];
}

+ (PFQuery *)queryWithCreatedAtFrom:(NSDate *)start to:(NSDate *)end {
    return [self queryWithCreatedAtFrom:start to:end includeKeys:nil];
}

+ (PFQuery *)queryWithCreatedAtFrom:(NSDate *)start to:(NSDate *)end includeKeys:(NSArray *)keys {
    return [self queryWithCreatedAtFrom:start to:end includeKeys:keys nonnullKeys:nil];
}

+ (PFQuery *)queryWithCreatedAtFrom:(NSDate *)start to:(NSDate *)end includeKeys:(NSArray *)keys nonnullKeys:(NSArray *)nonnullKeys {
    PFQuery *query = [[[self queryForRestaurant] whereKey:@"createdAt" greaterThanOrEqualTo:start] whereKey:@"createdAt" lessThanOrEqualTo:end];
    for (NSString *key in keys)
        [query includeKey:key];
    
    for (NSString *key in nonnullKeys)
        [query whereKeyExists:key];
    
    return query;
}

@end
