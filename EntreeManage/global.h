//
//  global.h
//  EntreeManage
//
//  Created by Faraz on 7/25/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#ifndef EntreeManage_global_h
#define EntreeManage_global_h

#import <Parse/Parse.h>


@protocol EMQuerying <NSObject>

+ (PFQuery *)queryCurrentRestaurant;

@end

#import "PFObject+copyShallow.h"
#import "CommParse.h"
<<<<<<< HEAD
=======
#import "Entree-Model.h"
>>>>>>> origin/tanner

#define ParseSetApplicationID  @"siTMH1dC5Qk84JvfZ3U5xfRfKwqb5jQv4CnCQGZn"
#define ParseClientKey         @"rKr1TeMyRNFNhx4zI4guhzk39Uap7MoHYfxdHvQo"

#define COLOR_ARRAY [NSArray arrayWithObjects:@"Amber", @"Blue", @"Blue Gray", @"Brown", @"Cyan", @"Deep Orange", @"Deep Purple", @"Entrée Blue", @"Green", @"Indigo", @"Light Blue", @"Light Green", @"Lime", @"Orange", @"Pink", @"Purple", @"Red", @"Teal",nil]


#endif

#define PARSE_REGISTER_CLASS + (void)load { \
    [self registerSubclass]; \
}

#define PARSE_CLASS_NAME + (NSString *)parseClassName { \
    return NSStringFromClass([self class]); \
}
