//
//  Refund.h
//  Entreé Manager
//
//  Created by Tanner on 9/10/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <Parse/Parse.h>

@interface Refund : PFObject<PFSubclassing>

@property (nonatomic) Payment *payment;

@end
