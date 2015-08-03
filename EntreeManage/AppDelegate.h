//
//  AppDelegate.h
//  EntreeManage
//
//  Created by Faraz on 7/23/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "global.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>{
  
}

@property (nonatomic, strong) IBOutlet UITabBarController *tabBarController;

@property (strong, nonatomic) UIWindow *window;


@end

