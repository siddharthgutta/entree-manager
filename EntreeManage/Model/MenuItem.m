//
//  MenuItem.m
//  EntreeManage
//
//  Created by Tanner on 8/29/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "MenuItem.h"

@implementation MenuItem

PARSE_CLASS_NAME
PARSE_REGISTER_CLASS

@dynamic name;
@dynamic price;
@dynamic menuCategory;
@dynamic alcoholic;
@dynamic colorIndex;

@synthesize saleCount = _saleCount;

- (CGFloat)netSales {
    return self.saleCount * self.price;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[MenuItem class]])
        return [self isEqualToMenuItem:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToMenuItem:(MenuItem *)item {
    return [self.name isEqualToString:item.name];
}

- (NSUInteger)hash {
    return self.name.hash;
}

@end
