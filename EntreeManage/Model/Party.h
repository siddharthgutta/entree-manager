//
//  Party.h
//  EntreeManage
//
//  Created by Tanner on 8/30/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <Parse/Parse.h>
@class Restaurant, Table;

@interface Party : PFObject<PFSubclassing, EMQuerying>

@property (nonatomic) NSString   *name;
@property (nonatomic) NSInteger  size;
@property (nonatomic) NSDate     *arrivedAt;
@property (nonatomic) NSDate     *seatedAt;
@property (nonatomic) NSDate     *leftAt;
@property (nonatomic) Restaurant *restaurant;
@property (nonatomic) Employee   *server;
@property (nonatomic) Table      *table;

@end
