//
//  Party.h
//  EntreeManage
//
//  Created by Tanner on 8/30/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <Parse/Parse.h>

@interface Party : PFObject<PFSubclassing>

@property (nonatomic) NSString  *name;
@property (nonatomic) NSInteger size;
@property (nonatomic) NSDate    *arrivedAt;
@property (nonatomic) NSDate    *seatedAt;
@property (nonatomic) NSDate    *leftAt;
@property (nonatomic) id        restaurant;
@property (nonatomic) id        server;
@property (nonatomic) id        table;

@end
