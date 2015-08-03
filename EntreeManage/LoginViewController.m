//
//  LoginViewController.m
//  EntreeManage
//
//  Created by Faraz on 7/25/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "LoginViewController.h"
#import "CommParse.h"
#import "AppDelegate.h"
#import <UIKit/UIKit.h>

@interface LoginViewController () <UITextFieldDelegate, CommsDelegate>{
    
    __weak IBOutlet UITextField *emailField;
    __weak IBOutlet UITextField *passField;    
   
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    emailField.text = @"email@email.com";
    passField.text = @"pass1";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
            del.window.rootViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TabStorybardId"];
        } else {
            [ProgressHUD showError:@"Login Error"];
        }
        
    }
}


@end
