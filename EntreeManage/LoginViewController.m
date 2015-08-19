//
//  LoginViewController.m
//  EntreeManage
//
//  Created by Faraz on 7/25/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "SummaryViewController.h"

@interface LoginViewController () <UITextFieldDelegate, CommsDelegate>{
    
    __weak IBOutlet UITextField *emailField;
    __weak IBOutlet UITextField *passField;    

    //UITabBarController * tabBarController;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    emailField.text = @"siddharthgutta@gmail.com";
    passField.text  = @"pass1";
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [[textField nextResponder] becomeFirstResponder];
    
    return YES;
}

- (IBAction)signBtnClicked:(id)sender {
    [ProgressHUD show:@"" Interaction:NO];

    NSString *email = [emailField text];
    NSCharacterSet *whiteSpace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    email = [email stringByTrimmingCharactersInSet:whiteSpace];
    if ([email length] == 0) {
        return;
    }
    
    NSString *pswd = [passField text];
    if ([pswd length] == 0) {
        return;
    }
    
    NSDictionary *userInfo = @{@"email":email, @"pswd":pswd};
    [CommParse emailLogin:self UserInfo:userInfo];
    
}

- (void)commsDidAction:(NSDictionary *)response
{
    if ([[response objectForKey:@"action"] intValue] == 1) {
        
        if ([[response objectForKey:@"responseCode"] boolValue]) {
            [ProgressHUD dismiss];
            
            UITabBarController    *tab       = [[UIStoryboard storyboardWithName:@"Login" bundle:nil]  instantiateViewControllerWithIdentifier:@"startTabBar"];
            UINavigationController *summary  = [[UIStoryboard storyboardWithName:@"Summary" bundle:nil]  instantiateViewControllerWithIdentifier:@"NavigationController"];
            UISplitViewController *business  = [[UIStoryboard storyboardWithName:@"Business" bundle:nil]  instantiateViewControllerWithIdentifier:@"SplitBusinessController"];
            UISplitViewController *analytics = [[UIStoryboard storyboardWithName:@"Analytics" bundle:nil]  instantiateViewControllerWithIdentifier:@"SplitAnalyticsController"];
            UIViewController      *settings  = [[UIStoryboard storyboardWithName:@"Settings" bundle:nil]  instantiateViewControllerWithIdentifier:@"SettingsController"];
            
            [summary pushViewController:[[SummaryViewController alloc] initWithCollectionViewLayout:[UICollectionViewFlowLayout new]] animated:NO];
            
            NSArray * controllers = [NSArray arrayWithObjects:summary, business, analytics, settings, nil]; //navController,
            tab.viewControllers = controllers;
            
            AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
            del.window.rootViewController = tab;
            
        } else {
            [ProgressHUD showError:@"Login Error"];
        }
        
    }
}


@end
