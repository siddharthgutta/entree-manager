//
//  BusinessViewController.m
//  EntreeManage
//
//  Created by Faraz on 7/30/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "BusinessViewController.h"

#import "BusinessMenuCategoryController.h"
#import "BusinessMenuAddController.h"
#import "BusinessMenuModifierAddController.h"
#import "BusinessEmployeeAddController.h"
#import "MGSwipeButton.h"

@implementation  BusinessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Menu";
    selectedMenuType = @"Menu";
    [self reloadMenus];
}

- (void)reloadMenus {
    [ProgressHUD show:@"" Interaction:NO];
    [CommParse getMenus:^(NSArray *menus, NSError *error) {
        [ProgressHUD dismiss];
        [self handleResponse:menus error:error];
    }];
}

- (void)reloadMenuModifiers {
    [ProgressHUD show:@"" Interaction:NO];
    [CommParse getAllMenuItemModifiers:^(NSArray *modifiers, NSError *error) {
        [ProgressHUD dismiss];
        [self handleResponse:modifiers error:error];
    }];
}

- (void)reloadEmployees {
    [ProgressHUD show:@"" Interaction:NO];
    [[Employee queryCurrentRestaurant] findObjectsInBackgroundWithBlock:^(NSArray *employees, NSError *error) {
        [ProgressHUD dismiss];
        [self handleResponse:employees error:error];
    }];
}

- (void)handleResponse:(NSArray *)objects error:(NSError *)error {
    [ProgressHUD dismiss];
    if (!error) {
        quotes = objects.mutableCopy;
    } else {
        quotes = [NSMutableArray array];
    }
    
    [self.menuView reloadData];
    if (self.navigationController.visibleViewController != self)
        [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
