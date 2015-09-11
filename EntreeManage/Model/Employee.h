//
//  Employee.h
//  EntreeManage
//
//  Created by Tanner on 8/30/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <Parse/Parse.h>
@class Shift;


@interface Employee : PFObject<PFSubclassing>

@property (nonatomic) NSInteger activePartyCount;
@property (nonatomic) BOOL      administrator;
@property (nonatomic) id        avatarFile;
@property (nonatomic) Shift     *currentShift;
@property (nonatomic) CGFloat   hourlyWage;
@property (nonatomic) NSString  *pinCode;
@property (nonatomic) id        restaurant;
@property (nonatomic) NSString  *role;
@property (nonatomic) NSString  *name;
@property (nonatomic) NSDate    *startDate;

@end
