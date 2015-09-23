//
//  Payment.h
//  EntreeManage
//
//  Created by Tanner on 8/27/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>

@interface Payment : PFObject<PFSubclassing, EMQuerying>

@property (nonatomic) Restaurant *restaurant;
@property (nonatomic) NSString   *cardFlightChargeToken;
@property (nonatomic) NSString   *cardLastFour;
@property (nonatomic) NSString   *cardName;
@property (nonatomic) Order      *order;
@property (nonatomic) Party      *party;
@property (nonatomic) NSString   *type;
@property (nonatomic) CGFloat    cashAmountPaid;
@property (nonatomic) CGFloat    changeGiven;
@property (nonatomic) BOOL       charged;

@end
