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
    PFQuery *query = [self query];
    return query;
    if ([[self class] respondsToSelector:@selector(restaurantRelationPath)]) {
        [query includeKey:[(id<EMQuerying>)self restaurantRelationPath]];
                
        NSLog(@"%@: %@", NSStringFromClass(self), [(id<EMQuerying>)self restaurantRelationPath]);
        [query whereKey:[(id<EMQuerying>)self restaurantRelationPath] matchesQuery:[[Restaurant query] whereKey:@"objectId" equalTo:[CommParse currentRestaurant].objectId]];
    }
    
    return query;
}

+ (PFQuery *)queryWithCreatedAtFrom:(NSDate *)start to:(NSDate *)end {
    return [self queryWithCreatedAtFrom:start to:end includeKeys:nil];
}

+ (PFQuery *)queryWithCreatedAtFrom:(NSDate *)start to:(NSDate *)end includeKeys:(NSArray *)keys {
    PFQuery *query = [[[self queryForRestaurant] whereKey:@"createdAt" greaterThanOrEqualTo:start] whereKey:@"createdAt" lessThanOrEqualTo:end];
    for (NSString *key in keys)
        [query includeKey:key];
    
    return query;
}

@end
