//
//  NSNumberFormatter+Dollars.m
//  EntreeManage
//
//  Created by Tanner on 8/8/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "NSNumberFormatter+Dollars.h"

@implementation NSNumberFormatter (Singleton)

+ (instancetype)dollarFormatter {
    static NSNumberFormatter *sharedFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFormatter = [self new];
        sharedFormatter.numberStyle  = NSNumberFormatterCurrencyStyle;
        sharedFormatter.currencyCode = @"USD";
    });
    
    return sharedFormatter;
}

@end
