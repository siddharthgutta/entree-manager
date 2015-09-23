//
//  Order.h
//  EntreeManage
//
//  Created by Tanner on 8/29/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <Parse/Parse.h>
@class Party, Payment;

@interface Order : PFObject<PFSubclassing, EMQuerying>

@property (nonatomic) id         installation;
@property (nonatomic) NSArray    *orderItems;
@property (nonatomic) Payment    *payment;
@property (nonatomic) Party      *party;
@property (nonatomic) Employee   *server;
@property (nonatomic) Restaurant *restaurant;

@property (nonatomic) CGFloat    amountDue;
@property (nonatomic) CGFloat    subtotal;
@property (nonatomic) CGFloat    tax;
@property (nonatomic) CGFloat    tip;
@property (nonatomic) CGFloat    total;
@property (nonatomic) NSString   *type;


@end
