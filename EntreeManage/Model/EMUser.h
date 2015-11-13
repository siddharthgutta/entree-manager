//
//  EMUser.h
//  Entreé Manager
//
//  Created by Tanner on 9/10/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <Parse/Parse.h>

@interface EMUser : PFUser<PFSubclassing>

@property (nonatomic) NSString   *name;
@property (nonatomic) BOOL       emailVerified;
@property (nonatomic, readonly) PFRelation *restaurants;

@end
