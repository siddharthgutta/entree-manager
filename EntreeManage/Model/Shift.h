//
//  Shift.h
//  EntreeManage
//
//  Created by Tanner on 8/30/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <Parse/Parse.h>
@class Employee;


@interface Shift : PFObject<PFSubclassing, EMQuerying>

@property (nonatomic) Employee *employee;
@property (nonatomic) NSDate   *startedAt;
@property (nonatomic) NSDate   *endedAt;
/** Defaults to using $2.15 / hour if employee's hourlyWage is inaccessible. */
@property (nonatomic, readonly) CGFloat laborCost;

@end
