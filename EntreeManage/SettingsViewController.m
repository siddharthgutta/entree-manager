//
//  SettingsViewController.m
//  Entreé Manager
//
//  Created by Tanner on 9/15/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "SettingsViewController.h"


@implementation SettingsViewController

- (IBAction)logOut:(UIButton *)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if (!error) {
            [self presentViewController:[[UIStoryboard storyboardWithName:@"SignIn" bundle:[NSBundle mainBundle]] instantiateInitialViewController] animated:YES completion:nil];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.emailTextField.text = [[NSUserDefaults standardUserDefaults] valueForKey:kExportEmailPrefKey];
    self.emailTextField.delegate = self;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:kExportEmailPrefKey];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

@end
