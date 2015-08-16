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
            //save current user email address
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:email forKey:@"curUserEmail"];
            
            
            [response setObject:[NSNumber numberWithBool:YES] forKey:@"responseCode"];
        } else {
            [response setObject:[NSNumber numberWithBool:NO] forKey:@"responseCode"];
            [response setObject:[CommParse parseErrorMsgFromError:error] forKey:@"errorMsg"];
        }
        if ([delegate respondsToSelector:@selector(commsDidAction:)])
            [delegate commsDidAction:response];
    }];
}

//***** Response number *******
// 1: get, 2: add update, 3: delete

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
        [response setObject:menu_type forKey:@"menu_type"];
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


+ (void)updateQuoteRequest:(id<CommsDelegate>)delegate Quote:(PFObject *)quote
{
    NSLog(@"Comms update:");
    [quote saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        [response setObject:[NSNumber numberWithInt:2] forKey:@"action"];
        if (!error && succeeded) {
            [response setObject:[NSNumber numberWithBool:YES] forKey:@"responseCode"];
        } else {
            [response setObject:[NSNumber numberWithBool:NO] forKey:@"responseCode"];
            [response setObject:[CommParse parseErrorMsgFromError:error] forKey:@"errorMsg"];
        }
        if ([delegate respondsToSelector:@selector(commsDidAction:)])
            [delegate commsDidAction:response];
    }];
}

+ (void)deleteQuoteRequest:(id<CommsDelegate>)delegate Quote:(PFObject *)quote
{
    NSLog(@"Comms delete:");
    [quote deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        [response setObject:[NSNumber numberWithInt:3] forKey:@"action"];
        if (!error && succeeded) {
            [response setObject:[NSNumber numberWithBool:YES] forKey:@"responseCode"];
        } else {
            [response setObject:[NSNumber numberWithBool:NO] forKey:@"responseCode"];
            [response setObject:[CommParse parseErrorMsgFromError:error] forKey:@"errorMsg"];
        }
        if ([delegate respondsToSelector:@selector(commsDidAction:)])
            [delegate commsDidAction:response];
    }];
}

+ (void)getMenuItemsOfModifier:(id<CommsDelegate>) delegate ModifierObject:(PFObject*)modifierObject
{
    PFRelation *relation = [modifierObject relationForKey:@"menuItems"];
    PFQuery *query = [relation query];
    
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

// Get Analytics Datas
+ (void)getAnalyticsSalesView:(id<CommsDelegate>)delegate StartDate:(NSDate*) startDate EndDate:(NSDate*) endDate
{
    [ProgressHUD show:@"" Interaction:NO];
    
    // Get discounts(get menuitems price which orderitem's onthehouse is true)
    __block float discount_val;
    discount_val = 0;
    
    PFQuery *order_query = [PFQuery queryWithClassName:@"OrderItem"];
    [order_query whereKey:@"onTheHouse" equalTo:[NSNumber numberWithBool:YES]];
    [order_query whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
    [order_query whereKey:@"createdAt" lessThanOrEqualTo:endDate];
    [order_query includeKey:@"menuItem"];
    
    [order_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if(!error){
            PFObject *item_obj;
            for(PFObject *object in objects){
                item_obj =[object objectForKey:@"menuItem"];
                
                discount_val += [[item_obj objectForKey:@"price"] floatValue];
            }
            NSLog(@"%f", discount_val);
        }
        
    }];
    
    
    // Get Payments
    PFQuery *query = [PFQuery queryWithClassName:@"Payment"];
    [query whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
    [query whereKey:@"createdAt" lessThanOrEqualTo:endDate];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        [response setObject:[NSNumber numberWithInt:1] forKey:@"action"];
        if ( !error ) {
            [response setObject:[NSNumber numberWithBool:YES] forKey:@"responseCode"];
            [response setObject:objects forKey:@"objects"];
            [response setObject:[NSNumber numberWithFloat:discount_val] forKey:@"discount"];

        } else {
            [response setObject:[NSNumber numberWithBool:NO] forKey:@"responseCode"];
            [response setObject:[CommParse parseErrorMsgFromError:error] forKey:@"errorMsg"];
        }
        
        
        if ([delegate respondsToSelector:@selector(commsDidAction:)])
            [delegate commsDidAction:response];
    }];
    
}

+ (void)getAnalyticsCategorySales:(id<CommsDelegate>)delegate StartDate:(NSDate*) startDate EndDate:(NSDate*) endDate
{
    [ProgressHUD show:@"" Interaction:NO];
    
    // Get discounts(get menuitems price which orderitem's onthehouse is true)
    PFQuery *orditem_query = [PFQuery queryWithClassName:@"OrderItem"];
    [orditem_query whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
    [orditem_query whereKey:@"createdAt" lessThanOrEqualTo:endDate];
    [orditem_query includeKey:@"menuItem"];
    [orditem_query includeKey:@"order"];
    
    NSMutableDictionary *resultArray;
    resultArray = [[NSMutableDictionary alloc] init];
    
    __block NSMutableArray *orderArray;
    __block PFObject *pay_obj;
    __block PFQuery *pay_query = [PFQuery queryWithClassName:@"Payment"];
    __block PFQuery *category_query = [PFQuery queryWithClassName:@"MenuCategory"];
   
    __block NSString *cat_id;
    
    [orditem_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject *item_obj;
        
        for(PFObject *orditem_obj in objects){
            //get item
            item_obj =[orditem_obj objectForKey:@"menuItem"];
            
            //get discount value
            float discount_val = 0;
            if([orditem_obj objectForKey:@"onTheHouse"]){
                discount_val = [[item_obj objectForKey:@"price"] floatValue];
            }
            
            //get category name
            item_obj =[item_obj objectForKey:@"menuCategory"];
            cat_id = item_obj.objectId;
            item_obj =[category_query getObjectWithId:item_obj.objectId];
            NSString *cat_name =[item_obj objectForKey:@"name"];
            
            //Sales
            item_obj =[orditem_obj objectForKey:@"order"];
            
            pay_obj =[item_obj objectForKey:@"payment"];
            pay_obj =[pay_query getObjectWithId:pay_obj.objectId];
            float total_sales =[[pay_obj objectForKey:@"total"] floatValue];
            
            //if exist same menu item
            if([resultArray objectForKey:cat_id]){
                //get that info
                orderArray = [resultArray objectForKey:cat_id];
                
                //sales
                total_sales = total_sales + [[orderArray objectAtIndex:1] floatValue];
                [orderArray replaceObjectAtIndex:1 withObject: [NSNumber numberWithFloat:total_sales]];
                //discounts
                discount_val = discount_val + [[orderArray objectAtIndex:2] floatValue];
                [orderArray replaceObjectAtIndex:2 withObject: [NSNumber numberWithFloat:discount_val]];
                
            }
            else{
                //if not exist then init
                orderArray = [[NSMutableArray alloc] init];
                
                [orderArray addObject:cat_name];
                [orderArray addObject:[NSNumber numberWithFloat:total_sales]];
                [orderArray addObject:[NSNumber numberWithFloat:discount_val]];
            }
            [resultArray  setObject:orderArray forKey:cat_id];
        }
        
        
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        [response setObject:[NSNumber numberWithInt:1] forKey:@"action"];
        if ( !error ) {
            [response setObject:[NSNumber numberWithBool:YES] forKey:@"responseCode"];
            [response setObject:resultArray forKey:@"objects"];
            
        } else {
            [response setObject:[NSNumber numberWithBool:NO] forKey:@"responseCode"];
            [response setObject:[CommParse parseErrorMsgFromError:error] forKey:@"errorMsg"];
        }
        
        
        if ([delegate respondsToSelector:@selector(commsDidAction:)])
            [delegate commsDidAction:response];
    }];
}

+ (void)getAnalyticsEmployeeShifts:(id<CommsDelegate>)delegate StartDate:(NSDate*) startDate EndDate:(NSDate*) endDate
{
    [ProgressHUD show:@"" Interaction:NO];
    
    PFQuery *shift_query = [PFQuery queryWithClassName:@"Shift"];
    [shift_query whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
    [shift_query whereKey:@"createdAt" lessThanOrEqualTo:endDate];
    [shift_query includeKey:@"employee"];
    [shift_query orderByAscending:@"employee"];
    
    //emp name, date, start time, end time, calculate times, hours worked, tips
    
    [shift_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        //calculate tips
        PFQuery *pay_query = [PFQuery queryWithClassName:@"Payment"];
        [pay_query whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
        [pay_query whereKey:@"createdAt" lessThanOrEqualTo:endDate];
        [pay_query findObjectsInBackgroundWithBlock:^(NSArray *pay_objects, NSError *error) {
            
            NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
            [response setObject:[NSNumber numberWithInt:1] forKey:@"action"];
            if ( !error ) {
                [response setObject:[NSNumber numberWithBool:YES] forKey:@"responseCode"];
                [response setObject:objects forKey:@"objects"];
                [response setObject:pay_objects forKey:@"pay_objects"];
                
            } else {
                [response setObject:[NSNumber numberWithBool:NO] forKey:@"responseCode"];
                [response setObject:[CommParse parseErrorMsgFromError:error] forKey:@"errorMsg"];
            }
            
            
            if ([delegate respondsToSelector:@selector(commsDidAction:)])
                [delegate commsDidAction:response];
        }];
         
       
    }];
    
}

+ (void)getAnalyticsPayroll:(id<CommsDelegate>)delegate StartDate:(NSDate*) startDate EndDate:(NSDate*) endDate
{
    [ProgressHUD show:@"" Interaction:NO];
    
    PFQuery *shift_query = [PFQuery queryWithClassName:@"Shift"];
    [shift_query whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
    [shift_query whereKey:@"createdAt" lessThanOrEqualTo:endDate];
    [shift_query includeKey:@"employee"];
    [shift_query orderByAscending:@"employee"];
    
    NSMutableDictionary *resultArray;
    resultArray = [[NSMutableDictionary alloc] init];

    __block NSMutableArray *empArray;
    __block PFObject *emp_obj;
    __block PFQuery *emp_query = [PFQuery queryWithClassName:@"Employee"];
    __block PFQuery *party_query = [PFQuery queryWithClassName:@"Party"];
    __block NSString *emp_id;
    
    //name, hours worked, tips, hourly wage
    
    [shift_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        
        for(PFObject *shift_obj in objects){
            emp_obj =[shift_obj objectForKey:@"employee"];
            emp_id = emp_obj.objectId;
            
            //calculate Time
            NSTimeInterval timeDifference = [[shift_obj objectForKey:@"endedAt"] timeIntervalSinceDate:[shift_obj objectForKey:@"startedAt"]];
            float hoursDiff =  timeDifference/3600;
            
            //if exist same emp
            if([resultArray objectForKey:emp_id]){
                //get that info
                empArray = [resultArray objectForKey:emp_id];
                
                hoursDiff = hoursDiff + [[empArray objectAtIndex:1] floatValue];
                //hours
                [empArray replaceObjectAtIndex:1 withObject: [NSNumber numberWithFloat:hoursDiff]];
            }
            else{
                //if not exist then init
                empArray = [[NSMutableArray alloc] init];
                
                [empArray addObject:[emp_obj objectForKey:@"name"]];
                [empArray addObject:[NSNumber numberWithFloat:hoursDiff]];
                [empArray addObject:@0.0];
                [empArray addObject:[emp_obj objectForKey:@"hourlyWage"]];
                
            }
            [resultArray  setObject:empArray forKey:emp_id];
        }
        
        //calculate tips
        PFQuery *pay_query = [PFQuery queryWithClassName:@"Payment"];
        [pay_query whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
        [pay_query whereKey:@"createdAt" lessThanOrEqualTo:endDate];
        [pay_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if(!error){
                
                for(PFObject *pay_obj in objects){
                    PFObject *party_obj =[pay_obj objectForKey:@"party"];
                    party_obj =[party_query getObjectWithId:party_obj.objectId];
                    emp_obj = [party_obj objectForKey:@"server"];
                    emp_id = emp_obj.objectId;
                    
                    
                    float tips = [[pay_obj objectForKey:@"tip"] floatValue];
                    
                    //if exist same emp
                    if([resultArray objectForKey:emp_id]){
                        //get that info
                        empArray = [resultArray objectForKey:emp_id];
                        
                        tips = tips + [[empArray objectAtIndex:2] floatValue];
                        //tips
                        [empArray replaceObjectAtIndex:2 withObject: [NSNumber numberWithFloat:tips]];
                    }
                    else{
                        emp_obj =[emp_query getObjectWithId:emp_id];
                        
                        //if not exist then init
                        empArray = [[NSMutableArray alloc] init];
                        
                        [empArray addObject:[emp_obj objectForKey:@"name"]];
                        [empArray addObject:@0.0];
                        [empArray addObject:[NSNumber numberWithFloat:tips]];
                        [empArray addObject:[emp_obj objectForKey:@"hourlyWage"]];
                        
                    }
                    [resultArray  setObject:empArray forKey:emp_id];
                }
                
            }
            
            NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
            [response setObject:[NSNumber numberWithInt:1] forKey:@"action"];
            if ( !error ) {
                [response setObject:[NSNumber numberWithBool:YES] forKey:@"responseCode"];
                [response setObject:resultArray forKey:@"objects"];
                
            } else {
                [response setObject:[NSNumber numberWithBool:NO] forKey:@"responseCode"];
                [response setObject:[CommParse parseErrorMsgFromError:error] forKey:@"errorMsg"];
            }
            
            
            if ([delegate respondsToSelector:@selector(commsDidAction:)])
                [delegate commsDidAction:response];
        
        }];
        
        
        
    }];
    
}

+ (void)getAnalyticsOrderReport:(id<CommsDelegate>)delegate StartDate:(NSDate*) startDate EndDate:(NSDate*) endDate
{
    [ProgressHUD show:@"" Interaction:NO];
    
    PFQuery *orditem_query = [PFQuery queryWithClassName:@"OrderItem"];
    [orditem_query whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
    [orditem_query whereKey:@"createdAt" lessThanOrEqualTo:endDate];
    [orditem_query includeKey:@"menuItem"];
    [orditem_query includeKey:@"order"];
    
    NSMutableDictionary *resultArray;
    resultArray = [[NSMutableDictionary alloc] init];
    
    __block NSMutableArray *orderArray;
    __block PFObject *pay_obj;
    __block PFQuery *pay_query = [PFQuery queryWithClassName:@"Payment"];
    __block PFQuery *category_query = [PFQuery queryWithClassName:@"MenuCategory"];
    __block PFQuery *menu_query = [PFQuery queryWithClassName:@"Menu"];
    __block NSString *item_id;

    [orditem_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject *item_obj;
        
        for(PFObject *orditem_obj in objects){
            //get item name
            item_obj =[orditem_obj objectForKey:@"menuItem"];
            item_id = item_obj.objectId;
            NSString *item_name = item_obj[@"name"];
            
            //get category name
            item_obj =[item_obj objectForKey:@"menuCategory"];
            item_obj =[category_query getObjectWithId:item_obj.objectId];
            NSString *cat_name =item_obj[@"name"];
            //get menu name
            item_obj =[item_obj objectForKey:@"menu"];
            item_obj =[menu_query getObjectWithId:item_obj.objectId];
            NSString *menu_name =[item_obj objectForKey:@"name"];
            
            //Times Ordered
            float timesOrdered =[[orditem_obj objectForKey:@"timesPrinted"] floatValue];
            
            //Sales
            item_obj =[orditem_obj objectForKey:@"order"];
            pay_obj =[item_obj objectForKey:@"payment"];
            pay_obj =[pay_query getObjectWithId:pay_obj.objectId];
            float total_sales =[[pay_obj objectForKey:@"total"] floatValue];
            
            //if exist same menu item
            if([resultArray objectForKey:item_id]){
                //get that info
                orderArray = [resultArray objectForKey:item_id];
                
                //times
                timesOrdered = timesOrdered + [[orderArray objectAtIndex:3] floatValue];
                [orderArray replaceObjectAtIndex:3 withObject: [NSNumber numberWithFloat:timesOrdered]];
                //sales
                total_sales = total_sales + [[orderArray objectAtIndex:4] floatValue];
                [orderArray replaceObjectAtIndex:4 withObject: [NSNumber numberWithFloat:timesOrdered]];
                
            }
            else{
                //if not exist then init
                orderArray = [[NSMutableArray alloc] init];
                
                [orderArray addObject:item_name];
                [orderArray addObject:menu_name];
                [orderArray addObject:cat_name];
                [orderArray addObject:[NSNumber numberWithFloat:timesOrdered]];
                [orderArray addObject:[NSNumber numberWithFloat:total_sales]];
            }
            [resultArray  setObject:orderArray forKey:item_id];
        }

        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        [response setObject:[NSNumber numberWithInt:1] forKey:@"action"];
        if ( !error ) {
            [response setObject:[NSNumber numberWithBool:YES] forKey:@"responseCode"];
            [response setObject:resultArray forKey:@"objects"];
            
        } else {
            [response setObject:[NSNumber numberWithBool:NO] forKey:@"responseCode"];
            [response setObject:[CommParse parseErrorMsgFromError:error] forKey:@"errorMsg"];
        }
        
        
        if ([delegate respondsToSelector:@selector(commsDidAction:)])
            [delegate commsDidAction:response];
    }];
   
}

+ (void)getAnalyticsModifierSales:(id<CommsDelegate>)delegate StartDate:(NSDate*) startDate EndDate:(NSDate*) endDate
{
    [ProgressHUD show:@"" Interaction:NO];
    
    PFQuery *orditem_query = [PFQuery queryWithClassName:@"OrderItem"];
    [orditem_query whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
    [orditem_query whereKey:@"createdAt" lessThanOrEqualTo:endDate];
    [orditem_query includeKey:@"menuItem"];
    [orditem_query includeKey:@"order"];
//    [orditem_query includeKey:@"menuItemModifiers"];
    
    NSMutableDictionary *resultArray;
    resultArray = [[NSMutableDictionary alloc] init];
    
    __block NSMutableArray *orderArray;
    __block PFObject *pay_obj;
    __block PFQuery *pay_query = [PFQuery queryWithClassName:@"Payment"];
    __block PFQuery *category_query = [PFQuery queryWithClassName:@"MenuCategory"];
    __block PFQuery *modifier_query = [PFQuery queryWithClassName:@"MenuItemModifier"];
    __block NSString *item_id;
    
    [orditem_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject *item_obj;
        
        for(PFObject *orditem_obj in objects){
            //get item name
            item_obj =[orditem_obj objectForKey:@"menuItem"];
            item_id = item_obj.objectId;
            
            NSString *item_name =[item_obj objectForKey:@"name"];
            
            //get category name
            item_obj =[item_obj objectForKey:@"menuCategory"];
            item_obj =[category_query getObjectWithId:item_obj.objectId];
            NSString *cat_name =[item_obj objectForKey:@"name"];
            
            //get modifier
            NSString *modifier_names = @"";
            NSArray *modifierArray =[orditem_obj objectForKey:@"menuItemModifiers"];
            for(PFObject *modifier_obj in modifierArray){
                item_obj =[modifier_query getObjectWithId:modifier_obj.objectId];
                NSString *modi_name = [item_obj objectForKey:@"name"];
                if([modifier_names isEqualToString:@""])
                    modifier_names = modi_name;
                else
                    modifier_names = [NSString stringWithFormat:@"%@, %@", modifier_names, modi_name ];
            }
            
            //Times Ordered
            float timesOrdered =[[orditem_obj objectForKey:@"timesPrinted"] floatValue];
            
            //Sales
            item_obj =[orditem_obj objectForKey:@"order"];
            
            pay_obj =[item_obj objectForKey:@"payment"];
            pay_obj =[pay_query getObjectWithId:pay_obj.objectId];
            float total_sales =[[pay_obj objectForKey:@"total"] floatValue];
            
            //if exist same menu item
            if([resultArray objectForKey:item_id]){
                //get that info
                orderArray = [resultArray objectForKey:item_id];
                
                //times
                timesOrdered = timesOrdered + [[orderArray objectAtIndex:3] floatValue];
                [orderArray replaceObjectAtIndex:3 withObject: [NSNumber numberWithFloat:timesOrdered]];
                //sales
                total_sales = total_sales + [[orderArray objectAtIndex:4] floatValue];
                [orderArray replaceObjectAtIndex:4 withObject: [NSNumber numberWithFloat:timesOrdered]];
                
            }
            else{
                //if not exist then init
                orderArray = [[NSMutableArray alloc] init];

                [orderArray addObject:modifier_names];
                [orderArray addObject:item_name];
                [orderArray addObject:cat_name];
                [orderArray addObject:[NSNumber numberWithFloat:timesOrdered]];
                [orderArray addObject:[NSNumber numberWithFloat:total_sales]];
            }
            [resultArray  setObject:orderArray forKey:item_id];
        }

        
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        [response setObject:[NSNumber numberWithInt:1] forKey:@"action"];
        if ( !error ) {
            [response setObject:[NSNumber numberWithBool:YES] forKey:@"responseCode"];
            [response setObject:resultArray forKey:@"objects"];
            
        } else {
            [response setObject:[NSNumber numberWithBool:NO] forKey:@"responseCode"];
            [response setObject:[CommParse parseErrorMsgFromError:error] forKey:@"errorMsg"];
        }
        
        
        if ([delegate respondsToSelector:@selector(commsDidAction:)])
            [delegate commsDidAction:response];
    }];
    
}


//Email Send via MailGun
+ (void)sendEmailwithMailGun:(id<CommsDelegate>)delegate userEmail:(NSString*) userEmail EmailSubject:(NSString*) emailSubject EmailContent:(NSString*) emailContent{
    
    NSString *csv_name = @"analytics.csv";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *curUserEmail = [defaults objectForKey:@"curUserEmail"];

    //send to current user's email
    if([userEmail isEqualToString:@""]) {
        if([curUserEmail isEqualToString:@""])
            userEmail = @"happywithyou86@gmail.com";
        else
            userEmail = curUserEmail;
        
    }
    
    //Mailgun API Key
    Mailgun *mailgun = [Mailgun clientWithDomain:@"sandboxd17cd83f7a424425b963d8ef54e5c218.mailgun.org" apiKey:@"key-1595ddf58f0a7d74c0042bdb34a9e75d"];
    
    NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
    //set response action code 9
    [response setObject:[NSNumber numberWithInt:9] forKey:@"action"];
    
    MGMessage *message = [MGMessage messageFrom:@"Entree Manager <manager@entree.org>"
                                             to:userEmail
                                        subject:emailSubject
                                           body:emailContent];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *filename = [docDir stringByAppendingPathComponent:csv_name];
    NSError *error = NULL;
    BOOL written = [emailContent writeToFile:filename atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if(!written) NSLog(@"write failed, error=%@", error);
    
    NSData *emailData = [NSData dataWithContentsOfFile:filename];
    
    csv_name = [NSString stringWithFormat:@"%@%@", emailSubject, @".csv"];
    
    [message addAttachment:emailData withName:csv_name type:@"csv"];
    
    NSString *emailMsg = [NSString stringWithFormat:@"Sending email to %@...", userEmail];
    
    [ProgressHUD show:emailMsg];
    
    [mailgun sendMessage:message success:^(NSString *messageId)
    {
        [response setObject:[NSNumber numberWithBool:YES] forKey:@"responseCode"];
        
        
        if ([delegate respondsToSelector:@selector(commsDidAction:)])
            [delegate commsDidAction:response];
        [ProgressHUD showSuccess:@"Sent email successfully!"];
        
        NSLog(@"Message %@ sent successfully!", messageId);
    } failure:^(NSError *error) {
        [response setObject:[NSNumber numberWithBool:NO] forKey:@"responseCode"];
        NSLog(@"Error sending message. The error was: %@", [error userInfo]);
        if ([delegate respondsToSelector:@selector(commsDidAction:)])
            [delegate commsDidAction:response];
    }];
    
}



@end
