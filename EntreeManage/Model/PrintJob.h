//
//  PrintJob.h
//  Entreé Manager
//
//  Created by Tanner on 9/10/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <Parse/Parse.h>
@class StarPrinter;

@interface PrintJob : PFObject<PFSubclassing, EMQuerying>

@property (nonatomic) StarPrinter *printer;
@property (nonatomic) NSString    *text;

@end
