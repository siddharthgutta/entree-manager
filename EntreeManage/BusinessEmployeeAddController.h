//
//  BusinessEmployeeAddController.h
//  EntreeManage
//
//  Created by Faraz on 8/1/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusinessEmployeeAddController : UIViewController
    @property (nonatomic) Employee *employee;
    @property (nonatomic) NSString *menuType;

    @property (nonatomic, assign) id parentDelegate;
@end


