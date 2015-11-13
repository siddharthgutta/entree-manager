//
//  AppDelegate.m
//  EntreeManage
//
//  Created by Faraz on 7/23/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "AppDelegate.h"
#import "FLEXManager.h"
#import "ProgressHUD.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Parse setApplicationId:ParseSetApplicationID clientKey:ParseClientKey];
    // [PFUser enableAutomaticUser];
    [PFUser logOut];
    
    [UINavigationBar appearance].translucent         = NO;
    [UINavigationBar appearance].barTintColor        = [UIColor colorWithRed:0.121 green:0.406 blue:0.872 alpha:1.000];
    [UINavigationBar appearance].tintColor           = [UIColor whiteColor];
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
//    [[FLEXManager sharedManager] showExplorer];
    
    return YES;
}

@end
