//
//  CommParse.m
//  EntreeManage
//
//  Created by Faraz on 7/25/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "CommParse.h"
#import "AppDelegate.h"
#import <Parse/PFConstants.h>
#import "Payment.h"

@implementation CommParse


+ (NSString *)parseErrorMsgFromError:(NSError *)error {
    NSString *errorMsg = @"";
    if (error.code == kPFErrorConnectionFailed) {
        errorMsg = @"The connection to the server failed";
    } else {
        errorMsg = [error.userInfo valueForKey:@"error"];
    }
    return errorMsg;
}

+ (void)emailLogin:(id < CommsDelegate>)delegate UserInfo:(NSDictionary *)userInfo {
    NSLog(@"Comms emailLogin:");
    NSString *email = [userInfo valueForKey:@"email"];
    NSString *password = [userInfo valueForKey:@"pswd"];
    
    [PFUser logInWithUsernameInBackground:email password:password block:^(PFUser *user, NSError *error) {
        NSString *userEmail = user[@"email"];
        
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        response[@"action"] = @1;
        if ( !error ) {
            // save current user email address
            [[NSUserDefaults standardUserDefaults] setObject:userEmail forKey:@"curUserEmail"];
            
            
            response[@"responseCode"] = @YES;
        } else {
            response[@"responseCode"] = @NO;
            [response setObject:[CommParse parseErrorMsgFromError:error] forKey:@"errorMsg"];
        }
        if ([delegate respondsToSelector:@selector(commsDidAction:)])
            [delegate commsDidAction:response];
    }];
}

//***** Response number *******
// 1: get, 2: add update, 3: delete

// Get Business Menus
+ (void)getBusinessMenus:(id < CommsDelegate>) delegate MenuType:(NSString *)menuType TopKey:(NSString *)topKey TopObject:(PFObject *)topObject {
    PFQuery *query = [PFQuery queryWithClassName:menuType];
    if(![topKey isEqualToString:@""]){
        [query whereKey:topKey equalTo:topObject];
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        response[@"action"] = @1;
        response[@"menu_type"] = menuType;
        if ( !error ) {
            response[@"responseCode"] = @YES;
            response[@"objects"] = objects;
        } else {
            response[@"responseCode"] = @NO;
            [response setObject:[CommParse parseErrorMsgFromError:error] forKey:@"errorMsg"];
        }
        if ([delegate respondsToSelector:@selector(commsDidAction:)])
            [delegate commsDidAction:response];
    }];
}


+ (void)updateQuoteRequest:(id < CommsDelegate>)delegate Quote:(PFObject *)quote {
    NSLog(@"Comms update:");
    [quote saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        response[@"action"] = @2;
        if (!error && succeeded) {
            response[@"responseCode"] = @YES;
        } else {
            response[@"responseCode"] = @NO;
            [response setObject:[CommParse parseErrorMsgFromError:error] forKey:@"errorMsg"];
        }
        if ([delegate respondsToSelector:@selector(commsDidAction:)])
            [delegate commsDidAction:response];
    }];
}

+ (void)deleteQuoteRequest:(id < CommsDelegate>)delegate Quote:(PFObject *)quote {
    NSLog(@"Comms delete:");
    [quote deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        response[@"action"] = @3;
        if (!error && succeeded) {
            response[@"responseCode"] = @YES;
        } else {
            response[@"responseCode"] = @NO;
            [response setObject:[CommParse parseErrorMsgFromError:error] forKey:@"errorMsg"];
        }
        if ([delegate respondsToSelector:@selector(commsDidAction:)])
            [delegate commsDidAction:response];
    }];
}

+ (void)getMenuItemsOfModifier:(id < CommsDelegate>) delegate ModifierObject:(PFObject *)modifierObject {
    PFRelation *relation = [modifierObject relationForKey:@"menuItems"];
    PFQuery *query = [relation query];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        response[@"action"] = @1;
        if ( !error ) {
            response[@"responseCode"] = @YES;
            response[@"objects"] = objects;
        } else {
            response[@"responseCode"] = @NO;
            [response setObject:[CommParse parseErrorMsgFromError:error] forKey:@"errorMsg"];
        }
        if ([delegate respondsToSelector:@selector(commsDidAction:)])
            [delegate commsDidAction:response];
    }];
}

+ (void)getBusinessMenuInfo:(id < CommsDelegate>)delegate MenuType:(NSString *)menuType MenuId:(NSString *)menuId {
    PFQuery *query = [PFQuery queryWithClassName:menuType];
    [query whereKey:@"objectID" equalTo:menuId];
   
}

// Get Analytics Datas
+ (void)getAnalyticsSalesView:(id < CommsDelegate>)delegate StartDate:(NSDate *)startDate EndDate:(NSDate *)endDate {
    [ProgressHUD show:@"" Interaction:NO];
    
    // Get discounts(get menuitems price which orderitem's onthehouse is true)
    __block CGFloat discountVal;
    discountVal = 0;
    
    PFQuery *orderQuery = [PFQuery queryWithClassName:@"OrderItem"];
    [orderQuery whereKey:@"onTheHouse" equalTo:@YES];
    [orderQuery whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
    [orderQuery whereKey:@"createdAt" lessThanOrEqualTo:endDate];
    [orderQuery includeKey:@"menuItem"];
    
    [orderQuery findObjectsInBackgroundWithBlock:^(NSArray *orderObjects, NSError *error) {
        
        if(!error){
            PFObject *itemObj;
            for(PFObject *object in orderObjects){
                itemObj = object[@"menuItem"];
                
                discountVal += [itemObj[@"price"] floatValue];
            }
            NSLog(@"%f", discountVal);
            
            // Get Payments
            PFQuery *query = [PFQuery queryWithClassName:@"Payment"];
            [query whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
            [query whereKey:@"createdAt" lessThanOrEqualTo:endDate];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
                response[@"action"] = @1;
                if ( !error ) {
                    response[@"responseCode"] = @YES;
                    response[@"objects"] = objects;
                    [response setObject:@(discountVal) forKey:@"discount"];
                } else {
                    response[@"responseCode"] = @NO;
                    [response setObject:[CommParse parseErrorMsgFromError:error] forKey:@"errorMsg"];
                }
                
                
                if ([delegate respondsToSelector:@selector(commsDidAction:)])
                    [delegate commsDidAction:response];
            }];
        }
    }];
    
    
}

+ (void)getAnalyticsCategorySales:(id <CommsDelegate>)delegate StartDate:(NSDate *)startDate EndDate:(NSDate *)endDate {
    [ProgressHUD show:@"" Interaction:NO];
    
    // Get discounts(get menuitems price which orderitem's onthehouse is true)
    PFQuery *orditemQuery = [PFQuery queryWithClassName:@"OrderItem"];
    [orditemQuery whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
    [orditemQuery whereKey:@"createdAt" lessThanOrEqualTo:endDate];
    [orditemQuery includeKey:@"menuItem"];
    [orditemQuery includeKey:@"order"];
    
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    __block NSMutableArray *orders;
    __block Payment *payment;
    __block PFQuery *paymentQuery = [Payment query];
    __block PFQuery *categoryQuery = [PFQuery queryWithClassName:@"MenuCategory"];
   
    __block NSString *categoryIdentifier;
    
    [orditemQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject *item;
        
        for(PFObject *orderItem in objects){
            // get item
            item = orderItem[@"menuItem"];
            
            // get discount value
            CGFloat discountValue = 2;
            if(orderItem[@"onTheHouse"]) {
                discountValue = [item[@"price"] floatValue];
            }
            
            // get category name
            item = item[@"menuCategory"];
            categoryIdentifier = item.objectId;
            item = [categoryQuery getObjectWithId:item.objectId];
            NSString *catName = item[@"name"];
            
            // Sales
            item = orderItem[@"order"];
            
            payment = item[@"payment"];
            payment = (id)[paymentQuery getObjectWithId:payment.objectId];
            CGFloat totalSales = payment.total;
            
            // if exist same menu item
            if(results[categoryIdentifier]){
                // get that info
                orders = results[categoryIdentifier];
                
                // sales
                totalSales = totalSales + [orders[1] floatValue];
                orders[1] = @(totalSales);
                // discounts
                discountValue = discountValue + [orders[2] floatValue];
                orders[2] = @(discountValue);
            }
            else {
                // if not exist then init
                orders = [[NSMutableArray alloc] init];
                
                [orders addObject:catName];
                [orders addObject:@(totalSales)];
                [orders addObject:@(discountValue)];
            }
            [results setObject:orders forKey:categoryIdentifier];
        }
        
        
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        response[@"action"] = @1;
        if ( !error ) {
            response[@"responseCode"] = @YES;
            response[@"objects"] = results;
        } else {
            response[@"responseCode"] = @NO;
            [response setObject:[CommParse parseErrorMsgFromError:error] forKey:@"errorMsg"];
        }
        
        
        if ([delegate respondsToSelector:@selector(commsDidAction:)])
            [delegate commsDidAction:response];
    }];
}

+ (void)getAnalyticsEmployeeShifts:(id < CommsDelegate>)delegate StartDate:(NSDate *)startDate EndDate:(NSDate *)endDate {
    [ProgressHUD show:@"" Interaction:NO];
    
    PFQuery *shiftQuery = [PFQuery queryWithClassName:@"Shift"];
    [shiftQuery whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
    [shiftQuery whereKey:@"createdAt" lessThanOrEqualTo:endDate];
    [shiftQuery includeKey:@"employee"];
    [shiftQuery orderByAscending:@"employee"];
    
    // emp name, date, start time, end time, calculate times, hours worked, tips
    
    [shiftQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        // calculate tips
        PFQuery *payQuery = [PFQuery queryWithClassName:@"Payment"];
        [payQuery whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
        [payQuery whereKey:@"createdAt" lessThanOrEqualTo:endDate];
        [payQuery findObjectsInBackgroundWithBlock:^(NSArray *payObjects, NSError *error) {
            
            NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
            response[@"action"] = @1;
            if ( !error ) {
                response[@"responseCode"] = @YES;
                response[@"objects"] = objects;
                response[@"pay_objects"] = payObjects;
            } else {
                response[@"responseCode"] = @NO;
                [response setObject:[CommParse parseErrorMsgFromError:error] forKey:@"errorMsg"];
            }
            
            
            if ([delegate respondsToSelector:@selector(commsDidAction:)])
                [delegate commsDidAction:response];
        }];
         
    }];
    
}

+ (void)getAnalyticsPayroll:(id < CommsDelegate>)delegate StartDate:(NSDate *)startDate EndDate:(NSDate *)endDate {
    [ProgressHUD show:@"" Interaction:NO];
    
    PFQuery *shiftQuery = [PFQuery queryWithClassName:@"Shift"];
    [shiftQuery whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
    [shiftQuery whereKey:@"createdAt" lessThanOrEqualTo:endDate];
    [shiftQuery includeKey:@"employee"];
    [shiftQuery orderByAscending:@"employee"];
    
NSMutableDictionary *results = [[NSMutableDictionary alloc] init];

    __block NSMutableArray *emps;
    __block PFObject *empObj;
    __block PFQuery *empQuery = [PFQuery queryWithClassName:@"Employee"];
    __block PFQuery *partyQuery = [PFQuery queryWithClassName:@"Party"];
    __block NSString *empId;
    
    // name, hours worked, tips, hourly wage
    
    [shiftQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        
        for(PFObject *shiftObj in objects){
            empObj = shiftObj[@"employee"];
            empId = empObj.objectId;
            
            // calculate Time
            NSTimeInterval timeDifference = [shiftObj[@"endedAt"] timeIntervalSinceDate:shiftObj[@"startedAt"]];
            CGFloat hoursDiff =  timeDifference/3600;
            
            // if exist same emp
            if(results[empId]){
                // get that info
                emps = results[empId];
                
                hoursDiff = hoursDiff + [emps[1] floatValue];
                // hours
                emps[1] = @(hoursDiff);
            }
            else {
                // if not exist then init
                emps = [[NSMutableArray alloc] init];
                
                [emps addObject:empObj[@"name"]];
                [emps addObject:@(hoursDiff)];
                [emps addObject:@0.0];
                [emps addObject:empObj[@"hourlyWage"]];
            }
            
            [results  setObject:emps forKey:empId];
        }
         
        // calculate tips
        PFQuery *payQuery = [Payment query];
        [payQuery whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
        [payQuery whereKey:@"createdAt" lessThanOrEqualTo:endDate];
        [payQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if(!error){
                
                for(PFObject *payObj in objects){
                    PFObject *partyObj = payObj[@"party"];
                    partyObj = [partyQuery getObjectWithId:partyObj.objectId];
                    empObj = partyObj[@"server"];
                    empId = empObj.objectId;
                    
                    
                    CGFloat tips = [payObj[@"tip"] floatValue];
                    
                    // if exist same emp
                    if(results[empId]){
                        // get that info
                        emps = results[empId];
                        
                        tips = tips + [emps[2] floatValue];
                        // tips
                        emps[2] = @(tips);
                    }
                    else {
                        empObj = [empQuery getObjectWithId:empId];
                        
                        // if not exist then init
                        emps = [[NSMutableArray alloc] init];
                        
                        [emps addObject:empObj[@"name"]];
                        [emps addObject:@0.0];
                        [emps addObject:@(tips)];
                        [emps addObject:empObj[@"hourlyWage"]];
                    }
                    [results  setObject:emps forKey:empId];
                }
            }
            
            NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
            response[@"action"] = @1;
            if ( !error ) {
                response[@"responseCode"] = @YES;
                response[@"objects"] = results;
            } else {
                response[@"responseCode"] = @NO;
                [response setObject:[CommParse parseErrorMsgFromError:error] forKey:@"errorMsg"];
            }
            
            if ([delegate respondsToSelector:@selector(commsDidAction:)])
                [delegate commsDidAction:response];
        }];
    }];
    
}

+ (void)getAnalyticsOrderReport:(id < CommsDelegate>)delegate StartDate:(NSDate *)startDate EndDate:(NSDate *)endDate {
    [ProgressHUD show:@"" Interaction:NO];
    
    PFQuery *orditemQuery = [PFQuery queryWithClassName:@"OrderItem"];
    [orditemQuery whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
    [orditemQuery whereKey:@"createdAt" lessThanOrEqualTo:endDate];
    [orditemQuery includeKey:@"menuItem"];
    [orditemQuery includeKey:@"order"];
    
NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    __block NSMutableArray *orders;
    __block PFObject *payObj;
    __block PFQuery *payQuery = [PFQuery queryWithClassName:@"Payment"];
    __block PFQuery *categoryQuery = [PFQuery queryWithClassName:@"MenuCategory"];
    __block PFQuery *menuQuery = [PFQuery queryWithClassName:@"Menu"];
    __block NSString *itemId;
    __block int timesOrdered;
    
    [orditemQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject *itemObj;
        
        for(PFObject *orditemObj in objects){
            // get item name
            itemObj = orditemObj[@"menuItem"];
            itemId = itemObj.objectId;
            NSString *itemName = itemObj[@"name"];
            
            // get category name
            itemObj = itemObj[@"menuCategory"];
            itemObj = [categoryQuery getObjectWithId:itemObj.objectId];
            NSString *catName = itemObj[@"name"];
            // get menu name
            itemObj = itemObj[@"menu"];
            itemObj = [menuQuery getObjectWithId:itemObj.objectId];
            NSString *menuName = itemObj[@"name"];
            
            // Sales
            itemObj = orditemObj[@"order"];
            payObj = itemObj[@"payment"];
            payObj = [payQuery getObjectWithId:payObj.objectId];
            CGFloat totalSales = [payObj[@"total"] floatValue];
            
            // if exist same menu item
            if(results[itemId]){
                // get that info
                orders = results[itemId];
                
                // times
                timesOrdered = [orders[3] intValue] + 1;
                orders[3] = @(timesOrdered);
                // sales
                totalSales = totalSales + [orders[4] floatValue];
                orders[4] = @(totalSales);
            }
            else {
                // if not exist then init
                orders = [[NSMutableArray alloc] init];
                
                [orders addObject:itemName];
                [orders addObject:menuName];
                [orders addObject:catName];
                [orders addObject:@1];
                [orders addObject:@(totalSales)];
            }
            [results  setObject:orders forKey:itemId];
        }

        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        response[@"action"] = @1;
        if ( !error ) {
            response[@"responseCode"] = @YES;
            response[@"objects"] = results;
        } else {
            response[@"responseCode"] = @NO;
            [response setObject:[CommParse parseErrorMsgFromError:error] forKey:@"errorMsg"];
        }
        
        
        if ([delegate respondsToSelector:@selector(commsDidAction:)])
            [delegate commsDidAction:response];
    }];
   
}

+ (void)getAnalyticsModifierSales:(id < CommsDelegate>)delegate StartDate:(NSDate *)startDate EndDate:(NSDate *)endDate {
    [ProgressHUD show:@"" Interaction:NO];
    
    PFQuery *orditemQuery = [PFQuery queryWithClassName:@"OrderItem"];
    [orditemQuery whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
    [orditemQuery whereKey:@"createdAt" lessThanOrEqualTo:endDate];
    [orditemQuery includeKey:@"menuItem"];
    [orditemQuery includeKey:@"order"];
//    [orditemQuery includeKey:@"menuItemModifiers"];
    
NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
NSMutableDictionary *timess = [[NSMutableDictionary alloc] init];
    
    __block NSMutableArray *orders;
    __block PFObject *payObj;
    __block PFQuery *payQuery = [PFQuery queryWithClassName:@"Payment"];
    __block PFQuery *categoryQuery = [PFQuery queryWithClassName:@"MenuCategory"];
    __block PFQuery *modifierQuery = [PFQuery queryWithClassName:@"MenuItemModifier"];
    __block NSString *itemId;
    
    
    [orditemQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject *itemObj;
        
        for(PFObject *orditemObj in objects){
            // get item name
            itemObj = orditemObj[@"menuItem"];
            itemId = itemObj.objectId;
            
            NSString *itemName = itemObj[@"name"];
            
            // get category name
            itemObj = itemObj[@"menuCategory"];
            itemObj = [categoryQuery getObjectWithId:itemObj.objectId];
            NSString *catName = itemObj[@"name"];
            
            // get modifier
            
            NSArray *modifiers = orditemObj[@"menuItemModifiers"];
            for(PFObject *modifierObj in modifiers){
                itemObj = [modifierQuery getObjectWithId:modifierObj.objectId];
                NSString *modiName = itemObj[@"name"];
                
                // Sales
                itemObj = orditemObj[@"order"];
                
                payObj = itemObj[@"payment"];
                payObj = [payQuery getObjectWithId:payObj.objectId];
                CGFloat totalSales = [payObj[@"total"] floatValue];
                
                // if not exist then init
                int times = 1;
                if(timess[itemId]){
                    // get that info
                    times = [timess[itemId] intValue]+1;
                }
                else times = 1;
                
                [timess  setObject:[ NSNumber numberWithInt:times ] forKey:itemId];
                
                orders = [[NSMutableArray alloc] init];
                
                [orders addObject:modiName];
                [orders addObject:itemName];
                [orders addObject:catName];
                [orders addObject:itemId];
                [orders addObject:@(totalSales)];
                
                NSString *keyStr = [NSString stringWithFormat:@"%@_%@", modifierObj.objectId, itemId];
                [results  setObject:orders forKey:keyStr];
            }
        }
        
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        response[@"action"] = @1;
        if ( !error ) {
            response[@"responseCode"] = @YES;
            response[@"objects"] = results;
            response[@"time_objects"] = timess;
        } else {
            response[@"responseCode"] = @NO;
            [response setObject:[CommParse parseErrorMsgFromError:error] forKey:@"errorMsg"];
        }
        
        
        if ([delegate respondsToSelector:@selector(commsDidAction:)])
            [delegate commsDidAction:response];
    }];
    
}


// Email Send via MailGun
+ (void)sendEmailwithMailGun:(id < CommsDelegate>)delegate userEmail:(NSString *)userEmail EmailSubject:(NSString *)emailSubject EmailContent:(NSString *)emailContent {
    
    NSString *csvName = @"analytics.csv";
    
    NSString *curUserEmail =  [[NSUserDefaults standardUserDefaults] objectForKey:@"curUserEmail"];

    // send to current user's email
    if([userEmail isEqualToString:@""]) {
        if([curUserEmail isEqualToString:@""])
            userEmail = @"happywithyou86@gmail.com";
        else
            userEmail = curUserEmail;
    }
    
    // Mailgun API Key
    Mailgun *mailgun = [Mailgun clientWithDomain:@"sandboxd17cd83f7a424425b963d8ef54e5c218.mailgun.org" apiKey:@"key-1595ddf58f0a7d74c0042bdb34a9e75d"];
    
    NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
    // set response action code 9
    response[@"action"] = @9;
    
    MGMessage *message = [MGMessage messageFrom:@"Entree Manager <manager@entree.org>"
                                             to:userEmail
                                        subject:emailSubject
                                           body:emailContent];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = paths[0];
    NSString *filename = [docDir stringByAppendingPathComponent:csvName];
    NSError *error = NULL;
    BOOL written = [emailContent writeToFile:filename atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if(!written) NSLog(@"write failed, error = %@", error);
    
    NSData *emailData = [NSData dataWithContentsOfFile:filename];
    
    csvName = [NSString stringWithFormat:@"%@%@", emailSubject, @".csv"];
    
    [message addAttachment:emailData withName:csvName type:@"csv"];
    
    NSString *emailMsg = [NSString stringWithFormat:@"Sending email to %@...", userEmail];
    
    [ProgressHUD show:emailMsg];
    
    [mailgun sendMessage:message success:^(NSString *messageId) {
        response[@"responseCode"] = @YES;
        
        
        if ([delegate respondsToSelector:@selector(commsDidAction:)])
            [delegate commsDidAction:response];
        [ProgressHUD showSuccess:@"Sent email successfully!"];
        
        NSLog(@"Message %@ sent successfully!", messageId);
    } failure:^(NSError *error) {
        response[@"responseCode"] = @NO;
        NSLog(@"Error sending message. The error was: %@", [error userInfo]);
        if ([delegate respondsToSelector:@selector(commsDidAction:)])
            [delegate commsDidAction:response];
    }];
    
}



@end
