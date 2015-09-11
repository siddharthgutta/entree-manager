//
//  NSDateFormatter+Singleton.m
//  Entreé Manager
//
//  Created by Tanner on 9/10/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "NSDateFormatter+Singleton.h"

@implementation NSDateFormatter (Shared)

+ (instancetype)shared {
    static NSDateFormatter *sharedFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFormatter = [self new];
        sharedFormatter.dateFormat = @"dd-MM-yyyy";
        sharedFormatter.timeZone   = [NSTimeZone timeZoneWithName:@"GMT"];
    });
    
    return sharedFormatter;
}

@end
