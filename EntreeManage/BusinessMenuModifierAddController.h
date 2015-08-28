//
//  BusinessMenuModifierAddController.h
//  EntreeManage
//
//  Created by Faraz on 8/3/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusinessMenuModifierAddController : UIViewController
    @property (nonatomic, weak) PFObject *menuObj;
    @property (nonatomic, weak) NSString *menuType;
    @property (nonatomic, assign) id parentDelegate;

- (void)returnSelectedItems:(NSMutableArray *)returns;
@end
