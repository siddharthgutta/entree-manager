//
//  PFRelation+Extensions.m
//  Entreé Manager
//
//  Created by Tanner on 9/11/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "PFRelation+Extensions.h"

@implementation PFRelation (Extensions)

- (void)removeAllObjectsBlocking {
    NSUInteger count = self.query.countObjects;
    if (count > 0)
        for(PFObject *object in [self.query findObjects])
            [self removeObject:object];
}

@end
