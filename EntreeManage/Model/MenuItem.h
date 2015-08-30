//
//  MenuItem.h
//  EntreeManage
//
//  Created by Tanner on 8/29/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <Parse/Parse.h>

@interface MenuItem : PFObject<PFSubclassing>

@property (nonatomic) NSString *name;
@property (nonatomic) CGFloat price;
@property (nonatomic) id menuCategory;
@property (nonatomic) BOOL alcoholic;
@property (nonatomic) NSInteger colorIndex;

@end
