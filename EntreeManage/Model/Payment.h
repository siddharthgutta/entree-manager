//
//  Payment.h
//  EntreeManage
//
//  Created by Tanner on 8/27/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>

@interface Payment : PFObject<PFSubclassing>

@property (nonatomic) NSString *cardFlightChargeToken;
@property (nonatomic) NSString *cardLastFour;
@property (nonatomic) NSString *cardName;
@property (nonatomic) id order;
@property (nonatomic) id party;
@property (nonatomic) CGFloat subtotal;
@property (nonatomic) CGFloat tax;
@property (nonatomic) CGFloat tip;
@property (nonatomic) CGFloat total;
@property (nonatomic) NSString *type;

@end
