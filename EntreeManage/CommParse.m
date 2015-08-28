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
        NSString *user_email = user[@"email"];
        
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        response[@"action"] = @1;
        if ( !error ) {
            // save current user email address
            [[NSUserDefaults standardUserDefaults] setObject:user_email forKey:@"curUserEmail"];
            
            
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
+ (void)getBusinessMenus:(id < CommsDelegate>) delegate MenuType:(NSString *)menu_type TopKey:(NSString *)topKey TopObject:(PFObject *)topObject {
    PFQuery *query = [PFQuery queryWithClassName:menu_type];
    if(![topKey isEqualToString:@""]){
        [query whereKey:topKey equalTo:topObject];
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        response[@"action"] = @1;
        response[@"menu_type"] = menu_type;
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

+ (void)getBusinessMenuInfo:(id < CommsDelegate>)delegate MenuType:(NSString *)menu_type MenuId:(NSString *)menu_id {
    PFQuery *query = [PFQuery queryWithClassName:menu_type];
    [query whereKey:@"objectID" equalTo:menu_id];
   
}

// Get Analytics Datas
+ (void)getAnalyticsSalesView:(id < CommsDelegate>)delegate StartDate:(NSDate *)startDate EndDate:(NSDate *)endDate {
    [ProgressHUD show:@"" Interaction:NO];
    
    // Get discounts(get menuitems price which orderitem's onthehouse is true)
    __block CGFloat discount_val;
    discount_val = 0;
    
    PFQuery *order_query = [PFQuery queryWithClassName:@"OrderItem"];
    [order_query whereKey:@"onTheHouse" equalTo:@YES];
    [order_query whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
    [order_query whereKey:@"createdAt" lessThanOrEqualTo:endDate];
    [order_query includeKey:@"menuItem"];
    
    [order_query findObjectsInBackgroundWithBlock:^(NSArray *order_objects, NSError *error) {
        
        if(!error){
            PFObject *item_obj;
            for(PFObject *object in order_objects){
                item_obj = object[@"menuItem"];
                
                discount_val += [item_obj[@"price"] floatValue];
            }
            NSLog(@"%f", discount_val);
            
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
                    [response setObject:@(discount_val) forKey:@"discount"];
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
    PFQuery *orditem_query = [PFQuery queryWithClassName:@"OrderItem"];
    [orditem_query whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
    [orditem_query whereKey:@"createdAt" lessThanOrEqualTo:endDate];
    [orditem_query includeKey:@"menuItem"];
    [orditem_query includeKey:@"order"];
    
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    __block NSMutableArray *orders;
    __block Payment *payment;
    __block PFQuery *paymentQuery = [Payment query];
    __block PFQuery *categoryQuery = [PFQuery queryWithClassName:@"MenuCategory"];
   
    __block NSString *categoryIdentifier;
    
    [orditem_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
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
            NSString *cat_name = item[@"name"];
            
            // Sales
            item = orderItem[@"order"];
            
            payment = item[@"payment"];
            payment = [paymentQuery getObjectWithId:payment.objectId];
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
                
                [orders addObject:cat_name];
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
    
    PFQuery *shift_query = [PFQuery queryWithClassName:@"Shift"];
    [shift_query whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
    [shift_query whereKey:@"createdAt" lessThanOrEqualTo:endDate];
    [shift_query includeKey:@"employee"];
    [shift_query orderByAscending:@"employee"];
    
    // emp name, date, start time, end time, calculate times, hours worked, tips
    
    [shift_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        // calculate tips
        PFQuery *pay_query = [PFQuery queryWithClassName:@"Payment"];
        [pay_query whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
        [pay_query whereKey:@"createdAt" lessThanOrEqualTo:endDate];
        [pay_query findObjectsInBackgroundWithBlock:^(NSArray *pay_objects, NSError *error) {
            
            NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
            response[@"action"] = @1;
            if ( !error ) {
                response[@"responseCode"] = @YES;
                response[@"objects"] = objects;
                response[@"pay_objects"] = pay_objects;
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
    
    PFQuery *shift_query = [PFQuery queryWithClassName:@"Shift"];
    [shift_query whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
    [shift_query whereKey:@"createdAt" lessThanOrEqualTo:endDate];
    [shift_query includeKey:@"employee"];
    [shift_query orderByAscending:@"employee"];
    
NSMutableDictionary *results = [[NSMutableDictionary alloc] init];

    __block NSMutableArray *emps;
    __block PFObject *emp_obj;
    __block PFQuery *emp_query = [PFQuery queryWithClassName:@"Employee"];
    __block PFQuery *party_query = [PFQuery queryWithClassName:@"Party"];
    __block NSString *emp_id;
    
    // name, hours worked, tips, hourly wage
    
    [shift_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        
        for(PFObject *shift_obj in objects){
            emp_obj = shift_obj[@"employee"];
            emp_id = emp_obj.objectId;
            
            // calculate Time
            NSTimeInterval timeDifference = [shift_obj[@"endedAt"] timeIntervalSinceDate:shift_obj[@"startedAt"]];
            CGFloat hoursDiff =  timeDifference/3600;
            
            // if exist same emp
            if(results[emp_id]){
                // get that info
                emps = results[emp_id];
                
                hoursDiff = hoursDiff + [emps[1] floatValue];
                // hours
                emps[1] = @(hoursDiff);
            }
            else {
                // if not exist then init
                emps = [[NSMutableArray alloc] init];
                
                [emps addObject:emp_obj[@"name"]];
                [emps addObject:@(hoursDiff)];
                [emps addObject:@0.0];
                [emps addObject:emp_obj[@"hourlyWage"]];
            }
            
            [results  setObject:emps forKey:emp_id];
        }
        
        // calculate tips
        PFQuery *pay_query = [Payment query];
        [pay_query whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
        [pay_query whereKey:@"createdAt" lessThanOrEqualTo:endDate];
        [pay_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if(!error){
                
                for(PFObject *pay_obj in objects){
                    PFObject *party_obj = pay_obj[@"party"];
                    party_obj = [party_query getObjectWithId:party_obj.objectId];
                    emp_obj = party_obj[@"server"];
                    emp_id = emp_obj.objectId;
                    
                    
                    CGFloat tips = [pay_obj[@"tip"] floatValue];
                    
                    // if exist same emp
                    if(results[emp_id]){
                        // get that info
                        emps = results[emp_id];
                        
                        tips = tips + [emps[2] floatValue];
                        // tips
                        emps[2] = @(tips);
                    }
                    else {
                        emp_obj = [emp_query getObjectWithId:emp_id];
                        
                        // if not exist then init
                        emps = [[NSMutableArray alloc] init];
                        
                        [emps addObject:emp_obj[@"name"]];
                        [emps addObject:@0.0];
                        [emps addObject:@(tips)];
                        [emps addObject:emp_obj[@"hourlyWage"]];
                    }
                    [results  setObject:emps forKey:emp_id];
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
    
    PFQuery *orditem_query = [PFQuery queryWithClassName:@"OrderItem"];
    [orditem_query whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
    [orditem_query whereKey:@"createdAt" lessThanOrEqualTo:endDate];
    [orditem_query includeKey:@"menuItem"];
    [orditem_query includeKey:@"order"];
    
NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    __block NSMutableArray *orders;
    __block PFObject *pay_obj;
    __block PFQuery *pay_query = [PFQuery queryWithClassName:@"Payment"];
    __block PFQuery *category_query = [PFQuery queryWithClassName:@"MenuCategory"];
    __block PFQuery *menu_query = [PFQuery queryWithClassName:@"Menu"];
    __block NSString *item_id;
    __block int timesOrdered;
    
    [orditem_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject *item_obj;
        
        for(PFObject *orditem_obj in objects){
            // get item name
            item_obj = orditem_obj[@"menuItem"];
            item_id = item_obj.objectId;
            NSString *item_name = item_obj[@"name"];
            
            // get category name
            item_obj = item_obj[@"menuCategory"];
            item_obj = [category_query getObjectWithId:item_obj.objectId];
            NSString *cat_name = item_obj[@"name"];
            // get menu name
            item_obj = item_obj[@"menu"];
            item_obj = [menu_query getObjectWithId:item_obj.objectId];
            NSString *menu_name = item_obj[@"name"];
            
            // Sales
            item_obj = orditem_obj[@"order"];
            pay_obj = item_obj[@"payment"];
            pay_obj = [pay_query getObjectWithId:pay_obj.objectId];
            CGFloat total_sales = [pay_obj[@"total"] floatValue];
            
            // if exist same menu item
            if(results[item_id]){
                // get that info
                orders = results[item_id];
                
                // times
                timesOrdered = [orders[3] intValue] + 1;
                orders[3] = @(timesOrdered);
                // sales
                total_sales = total_sales + [orders[4] floatValue];
                orders[4] = @(total_sales);
            }
            else {
                // if not exist then init
                orders = [[NSMutableArray alloc] init];
                
                [orders addObject:item_name];
                [orders addObject:menu_name];
                [orders addObject:cat_name];
                [orders addObject:@1];
                [orders addObject:@(total_sales)];
            }
            [results  setObject:orders forKey:item_id];
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
    
    PFQuery *orditem_query = [PFQuery queryWithClassName:@"OrderItem"];
    [orditem_query whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
    [orditem_query whereKey:@"createdAt" lessThanOrEqualTo:endDate];
    [orditem_query includeKey:@"menuItem"];
    [orditem_query includeKey:@"order"];
//    [orditem_query includeKey:@"menuItemModifiers"];
    
NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
NSMutableDictionary *timess = [[NSMutableDictionary alloc] init];
    
    __block NSMutableArray *orders;
    __block PFObject *pay_obj;
    __block PFQuery *pay_query = [PFQuery queryWithClassName:@"Payment"];
    __block PFQuery *category_query = [PFQuery queryWithClassName:@"MenuCategory"];
    __block PFQuery *modifier_query = [PFQuery queryWithClassName:@"MenuItemModifier"];
    __block NSString *item_id;
    
    
    [orditem_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject *item_obj;
        
        for(PFObject *orditem_obj in objects){
            // get item name
            item_obj = orditem_obj[@"menuItem"];
            item_id = item_obj.objectId;
            
            NSString *item_name = item_obj[@"name"];
            
            // get category name
            item_obj = item_obj[@"menuCategory"];
            item_obj = [category_query getObjectWithId:item_obj.objectId];
            NSString *cat_name = item_obj[@"name"];
            
            // get modifier
            
            NSArray *modifiers = orditem_obj[@"menuItemModifiers"];
            for(PFObject *modifier_obj in modifiers){
                item_obj = [modifier_query getObjectWithId:modifier_obj.objectId];
                NSString *modi_name = item_obj[@"name"];
                
                // Sales
                item_obj = orditem_obj[@"order"];
                
                pay_obj = item_obj[@"payment"];
                pay_obj = [pay_query getObjectWithId:pay_obj.objectId];
                CGFloat total_sales = [pay_obj[@"total"] floatValue];
                
                // if not exist then init
                int times = 1;
                if(timess[item_id]){
                    // get that info
                    times = [timess[item_id] intValue]+1;
                }
                else times = 1;
                
                [timess  setObject:[ NSNumber numberWithInt:times ] forKey:item_id];
                
                orders = [[NSMutableArray alloc] init];
                
                [orders addObject:modi_name];
                [orders addObject:item_name];
                [orders addObject:cat_name];
                [orders addObject:item_id];
                [orders addObject:@(total_sales)];
                
                NSString *key_str = [NSString stringWithFormat:@"%@_%@", modifier_obj.objectId, item_id];
                [results  setObject:orders forKey:key_str];
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
    
    NSString *csv_name = @"analytics.csv";
    
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
    NSString *filename = [docDir stringByAppendingPathComponent:csv_name];
    NSError *error = NULL;
    BOOL written = [emailContent writeToFile:filename atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if(!written) NSLog(@"write failed, error = %@", error);
    
    NSData *emailData = [NSData dataWithContentsOfFile:filename];
    
    csv_name = [NSString stringWithFormat:@"%@%@", emailSubject, @".csv"];
    
    [message addAttachment:emailData withName:csv_name type:@"csv"];
    
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
