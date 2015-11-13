//
//  MenuItemModifier.m
//  Entreé Manager
//
//  Created by Tanner on 9/10/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "MenuItemModifier.h"

@implementation MenuItemModifier

PARSE_CLASS_NAME
PARSE_REGISTER_CLASS

@dynamic menuItems;
@dynamic name;
@dynamic printText;
@dynamic price;

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[MenuItemModifier class]])
        return [self isEqualToMenuItemModifier:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToMenuItemModifier:(MenuItemModifier *)mim {
    return [self.objectId isEqualToString:mim.objectId];
}

- (NSUInteger)hash {
    return self.objectId.hash;
}

@end
