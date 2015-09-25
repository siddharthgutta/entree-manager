
#import "SignInViewController.h"

@interface SignInViewController ()

- (IBAction)signIn:(UIButton *)sender;

@end

@implementation SignInViewController

- (IBAction)signIn:(UIButton *)sender {
    UIAlertController *signInAlertController = [UIAlertController alertControllerWithTitle:@"Sign In" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [signInAlertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeEmailAddress;
        textField.placeholder = @"Email";
    }];
    [signInAlertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Password";
        textField.secureTextEntry = YES;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [signInAlertController addAction:cancelAction];
    
    UIAlertAction *signInAction = [UIAlertAction actionWithTitle:@"Sign In" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSArray<UITextField *>*textFields = signInAlertController.textFields;
        
        NSString *email = textFields.firstObject.text;
        NSString *password = textFields.lastObject.text;
        
        [PFUser logInWithUsernameInBackground:email password:password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
            if (user) {
                [self performSegueWithIdentifier:@"SelectRestaurant" sender:nil];
            } else {
                UIAlertController *errorAlertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                              message:error.localizedDescription
                                                                                       preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
                [errorAlertController addAction:okayAction];
                
                [self presentViewController:errorAlertController animated:YES completion:nil];
            }
        }];
    }];
    [signInAlertController addAction:signInAction];
    
    [self presentViewController:signInAlertController animated:YES completion:nil];
}

@end
