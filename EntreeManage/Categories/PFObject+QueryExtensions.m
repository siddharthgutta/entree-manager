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
        NSString *relationPath = [(id<EMQuerying>)self restaurantRelationPath];
        NSString *classPath    = [(id<EMQuerying>)self restaurantRelationPathByClassNames];
        
        NSArray *pathComponents = [relationPath componentsSeparatedByString:@"."]; // last object should be "restaurant"
        NSArray *classes        = [classPath componentsSeparatedByString:@"."]; // last object should be "Restaurant"
        
        PFQuery *lastQuery;
        if (classes.count > 1) {
            for (NSUInteger i = classes.count-1; i > 0; i--) {
                NSString *class = classes[i-1];
                NSString *keyPathComponent = pathComponents[i];
                if ([keyPathComponent isEqualToString:@"restaurant"])
                    lastQuery = [[Restaurant query] whereKey:@"objectId" equalTo:[CommParse currentRestaurant].objectId];
                lastQuery = [[NSClassFromString(class) query] whereKey:keyPathComponent matchesQuery:lastQuery];
            }
        } else {
            lastQuery = [[Restaurant query] whereKey:@"objectId" equalTo:[CommParse currentRestaurant].objectId];
        }
        
        [query includeKey:relationPath];
        [query whereKey:pathComponents.firstObject matchesQuery:lastQuery];
    }
    
    return query;
}

+ (PFQuery *)queryWithCreatedAtFrom:(NSDate *)start to:(NSDate *)end {
    return [self queryWithCreatedAtFrom:start to:end includeKeys:nil];
}

+ (PFQuery *)queryWithCreatedAtFrom:(NSDate *)start to:(NSDate *)end includeKeys:(NSArray *)keys {
    PFQuery *query = [[[self queryForRestaurant] whereKey:@"createdAt" greaterThanOrEqualTo:start] whereKey:@"createdAt" lessThanOrEqualTo:end];
    for (NSString *key in keys) {
        [query includeKey:key];
    }
    
    return query;
}

@end
