//
//  Table.h
//  Entreé Manager
//
//  Created by Tanner on 9/10/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <Parse/Parse.h>

@interface Table : PFObject<PFSubclassing, EMQuerying>

@property (nonatomic) NSInteger  capacity;
@property (nonatomic) Party      *currentParty;
@property (nonatomic) Restaurant *restaurant;
@property (nonatomic) NSString   *name;
@property (nonatomic) NSString   *shortName;
@property (nonatomic) NSInteger  type;
@property (nonatomic) NSInteger  x;
@property (nonatomic) NSInteger  y;

@end
