//
//  Shift.m
//  EntreeManage
//
//  Created by Tanner on 8/30/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "Shift.h"

@implementation Shift

PARSE_CLASS_NAME
PARSE_REGISTER_CLASS

@dynamic employee;
@dynamic startedAt;
@dynamic endedAt;

+ (NSString *)restaurantRelationPath {
    return @"employee.restaurant";
}

+ (NSString *)restaurantRelationPathByClassNames {
    return @"Employee.Restaurant";
}

- (CGFloat)laborCost {
    CGFloat hoursWorked = (CGFloat)[self.endedAt minutesAfterDate:self.startedAt] / 60.f;
    CGFloat wage = self.employee.hourlyWage;
    if (wage == 0.f) wage = 2.15;
    
    return hoursWorked * wage;
}

@end
