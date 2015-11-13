//
//  StarPrinter.h
//  Entreé Manager
//
//  Created by Tanner on 9/10/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <Parse/Parse.h>

@interface StarPrinter : PFObject<PFSubclassing, EMQuerying>

@property (nonatomic) NSString   *mac;
@property (nonatomic) NSString   *nickname;
@property (nonatomic) Restaurant *restaurant;

@end
