//
//  PFObject+QueryExtensions.m
//  EntreeManage
//
//  Created by Tanner on 8/30/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "PFObject+QueryExtensions.h"

@implementation PFObject (QueryExtensions)

+ (PFQuery *)queryWithCreatedAtFrom:(NSDate *)start to:(NSDate *)end {
    return [self queryWithCreatedAtFrom:start to:end includeKeys:nil];
}

+ (PFQuery *)queryWithCreatedAtFrom:(NSDate *)start to:(NSDate *)end includeKeys:(NSArray *)keys {
    NSParameterAssert([[self class] respondsToSelector:@selector(query)]);
    PFQuery *query = [[[self query] whereKey:@"createdAt" greaterThanOrEqualTo:start] whereKey:@"createdAt" lessThanOrEqualTo:end];
    for (NSString *key in keys)
        [query includeKey:key];
    
    return query;
}

@end
