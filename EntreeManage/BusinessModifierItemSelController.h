//
//  BusinessModifierItemSelController.h
//  EntreeManage
//
//  Created by Faraz on 8/3/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusinessModifierItemSelController : UIViewController
    @property (nonatomic, assign) id parentDelegate;
    // array is object lists of selected items
    @property (nonatomic, assign) NSMutableArray *selectedItems;
@end
