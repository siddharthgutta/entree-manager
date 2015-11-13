//
//  Menu.h
//  Entreé Manager
//
//  Created by Tanner on 9/6/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <Parse/Parse.h>
@class Restaurant;

@interface Menu : PFObject <PFSubclassing>

@property (nonatomic) NSString *name;
@property (nonatomic) NSInteger colorIndex;
@property (nonatomic) Restaurant *restaurant;

@end
