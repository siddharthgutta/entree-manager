//
//  PFObject+copyShallow.m
//  BupVIP-Host
//
//  Created by Ping Ahn(Alex) on 7/24/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import "PFObject+copyShallow.h"

@implementation PFObject (copyShallow)

- (PFObject *)copyShallow {
    PFObject *clone = [PFObject objectWithoutDataWithClassName:self.parseClassName objectId:self.objectId];
    NSArray *keys = [self allKeys];
    for (NSString *key in keys) {
        if ([[key lowercaseString] rangeOfString:@"_ptr"].location == NSNotFound)
            [clone setObject:[self[key] copy] forKey:key];
        else
            [clone setObject:self[key] forKey:key];
    }
    return clone;
}

@end
