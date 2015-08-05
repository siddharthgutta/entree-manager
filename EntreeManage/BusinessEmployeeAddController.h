//
//  BusinessEmployeeAddController.h
//  EntreeManage
//
//  Created by Faraz on 8/1/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommParse.h"

@interface BusinessEmployeeAddController : UIViewController
    @property (nonatomic, weak) PFObject *menuObj;
    @property (nonatomic, weak) NSString *menuType;

    @property (nonatomic, assign) id parent_delegate;
@end


