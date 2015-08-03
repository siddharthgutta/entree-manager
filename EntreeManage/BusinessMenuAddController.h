//
//  BusinessMenuAddController.h
//  EntreeManage
//
//  Created by Faraz on 7/31/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommParse.h"

@interface BusinessMenuAddController : UIViewController
    @property (nonatomic, weak) PFObject *menuObj;
    @property (nonatomic, weak) NSString *menuType;
@end
