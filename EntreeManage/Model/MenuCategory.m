//
//  MenuCategory.m
//  EntreeManage
//
//  Created by Tanner on 8/30/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "MenuCategory.h"

@implementation MenuCategory

@synthesize saleCount = _saleCount;

PARSE_CLASS_NAME
PARSE_REGISTER_CLASS

@dynamic menu;
@dynamic name;

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[MenuCategory class]])
        return [self isEqualToCategory:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToCategory:(MenuCategory *)mc {
    return [mc.objectId isEqualToString:self.objectId];
}

- (NSUInteger)hash {
    return self.objectId.hash;
}

@end
