//
//  CommParse.m
//  EntreeManage
//
//  Created by Faraz on 7/25/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "CommParse.h"
#import <Parse/PFConstants.h>

@implementation CommParse

+ (NSString *)parseErrorMsgFromError:(NSError *)error
{
    NSString *errorMsg = @"";
    if (error.code == kPFErrorConnectionFailed) {
        errorMsg = @"The connection to the server failed";
    } else {
        errorMsg = [error.userInfo valueForKey:@"error"];
    }
    return errorMsg;
}

+ (void)emailLogin:(id<CommsDelegate>)delegate UserInfo:(NSDictionary *)userInfo
{
    NSLog(@"Comms emailLogin:");
    NSString *email = [userInfo valueForKey:@"email"];
    NSString *password = [userInfo valueForKey:@"pswd"];
    
    [PFUser logInWithUsernameInBackground:email password:password block:^(PFUser *user, NSError *error) {
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        [response setObject:[NSNumber numberWithInt:1] forKey:@"action"];
        if ( !error ) {
            [response setObject:[NSNumber numberWithBool:YES] forKey:@"responseCode"];
        } else {
            [response setObject:[NSNumber numberWithBool:NO] forKey:@"responseCode"];
            [response setObject:[CommParse parseErrorMsgFromError:error] forKey:@"errorMsg"];
        }
        if ([delegate respondsToSelector:@selector(commsDidAction:)])
            [delegate commsDidAction:response];
    }];
}

// Get Business Menus
+ (void)getBusinessMenus:(id<CommsDelegate>) delegate MenuType:(NSString*) menu_type TopKey:(NSString*)topKey TopObject:(PFObject*)topObject
{
    PFQuery *query = [PFQuery queryWithClassName:menu_type];
    if(![topKey isEqualToString:@""]){
        [query whereKey:topKey equalTo:topObject];
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        [response setObject:[NSNumber numberWithInt:1] forKey:@"action"];
        if ( !error ) {
            [response setObject:[NSNumber numberWithBool:YES] forKey:@"responseCode"];
            [response setObject:objects forKey:@"objects"];
        } else {
            [response setObject:[NSNumber numberWithBool:NO] forKey:@"responseCode"];
            [response setObject:[CommParse parseErrorMsgFromError:error] forKey:@"errorMsg"];
        }
        if ([delegate respondsToSelector:@selector(commsDidAction:)])
            [delegate commsDidAction:response];
    }];
}

+ (void)getBusinessMenuInfo:(id<CommsDelegate>)delegate MenuType:(NSString*) menu_type MenuId:(NSString*) menu_id
{
    PFQuery *query = [PFQuery queryWithClassName:menu_type];
    [query whereKey:@"objectID" equalTo:menu_id];
    

    
}

// Add Business Menus
+ (void)addBusinessMenu:(id<CommsDelegate>)delegate MenuType:(NSString*) menu_type MenuInfo:(NSDictionary *)menuInfo
{
    
}

// Update Business Menus
+ (void)updateBusinessMenu:(id<CommsDelegate>)delegate MenuType:(NSString*) menu_type MenuInfo:(NSDictionary *)menuInfo{
    
}

// Get Business Employee
+ (void)getBusinessEmployees:(id<CommsDelegate>)delegate{
    
}

+ (void)getBusinessEmployeeInfo:(id<CommsDelegate>)delegate EmployeeId:(NSString*) employee_id{
    
}

// Add Business Employee
+ (void)addBusinessEmployee:(id<CommsDelegate>)delegate EmployeeInfo:(NSDictionary *)employeeInfo{
    
}

// Update Business Employee
+ (void)updateBusinessEmployee:(id<CommsDelegate>)delegate EmployeeInfo:(NSDictionary *)employeeInfo{
    
}

@end
