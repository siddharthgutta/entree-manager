//
//  Order.h
//  EntreeManage
//
//  Created by Tanner on 8/29/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <Parse/Parse.h>
@class Payment;


@interface Order : PFObject<PFSubclassing>

@property (nonatomic) NSArray *orderItems;
@property (nonatomic) Payment *payment;
@property (nonatomic) id      party;
@property (nonatomic) id      server;

@end
