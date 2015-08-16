//
//  PFUtils.h
//  BupVIP-Host
//
//  Created by Faraz on 7/25/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface PFUtils : NSObject

+ (BOOL)exists:(NSString *)key InObject:(PFObject *)object;
+ (id)getProperty:(NSString *)propertyName InObject:(PFObject *)object;
+ (id)getData:(NSString *)colName WithKey:(NSString *)key InObject:(PFObject *)object;

@end
