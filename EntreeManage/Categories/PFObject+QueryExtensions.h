//
//  PFObject+QueryExtensions.h
//  EntreeManage
//
//  Created by Tanner on 8/30/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface PFObject (QueryExtensions)

+ (PFQuery *)queryWithCreatedAtFrom:(NSDate *)start to:(NSDate *)end;
+ (PFQuery *)queryWithCreatedAtFrom:(NSDate *)start to:(NSDate *)end includeKeys:(nullable NSArray *)keys;
+ (PFQuery *)queryWithCreatedAtFrom:(NSDate *)start to:(NSDate *)end includeKeys:(nullable NSArray *)keys nonnullKeys:(nullable NSArray *)nonnullKeys;

@end

NS_ASSUME_NONNULL_END