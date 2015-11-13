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

<<<<<<< HEAD

+ (NSString *)parseErrorMsgFromError:(NSError *)error
{
=======
static Restaurant *currentRestaurant;

+ (Restaurant *)currentRestaurant {
    @synchronized(self) { return currentRestaurant; }
}

+ (void)setCurrentRestaurant:(Restaurant *)restaurant {
    @synchronized(self) { currentRestaurant = restaurant; }
}

+ (void)getNetSalesForInterval:(NSDate *)start end:(NSDate *)end callback:(ParseObjectResponseBlock)callback {
    PFQuery *query = [Payment queryWithCreatedAtFrom:start.dateAtStartOfDay to:end.dateAtStartOfDay.nextDay includeKeys:@[@"order.orderItems", @"order.orderItems.menuItem"]];
    [query whereKeyExists:@"order"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *payments, NSError *error) {
        if (!error) {
            NSArray *orderItems  = [[payments valueForKeyPath:@"order.orderItems"] valueForKeyPath:@"@unionOfArrays.self"];
            orderItems = [orderItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self != nil"]];
            NSArray *discounted  = [orderItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"onTheHouse = YES"]];
            CGFloat allSubtotals = [[orderItems valueForKeyPath:@"@sum.menuItem.price"] floatValue];
            CGFloat allDiscounts = [[discounted valueForKeyPath:@"@sum.menuItem.price"] floatValue];
            callback(@(allSubtotals - allDiscounts), nil);
        } else {
            callback(nil, error);
        }
    }];
}

+ (void)getNetSalesForPastWeek:(NSDate *)day callback:(ParseArrayResponseBlock)callback {
    PFQuery *query = [Payment queryWithCreatedAtFrom:[day.dateAtStartOfDay dateBySubtractingDays:6] to:day.dateAtStartOfDay.nextDay includeKeys:@[@"order.orderItems", @"order.orderItems.menuItem"]];
    [query whereKeyExists:@"order"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *payments, NSError *error) {
        if (!error) {
            NSArray *orderItems = [[payments valueForKeyPath:@"order.orderItems"] valueForKeyPath:@"@unionOfArrays.self"];
            NSArray *discounted = [orderItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"onTheHouse = YES"]];
            
            NSMutableArray *numbers = [NSMutableArray array];
            for (int i = 6; i >= 0; i--)
                [numbers addObject:[self netSalesOnDay:[day dateBySubtractingDays:i] withOrders:orderItems discounts:discounted]];
            
            callback(numbers, nil);
        } else {
            callback(nil, error);
        }
    }];
}

+ (NSNumber *)netSalesOnDay:(NSDate *)date withOrders:(NSArray *)orderItems discounts:(NSArray *)discounted {
    orderItems = [orderItems.mutableCopy objectsPassingTest:^BOOL(Payment *p, BOOL *stop) {
        if ((id)p == [NSNull null]) return NO;
        return [date isEqualToDateIgnoringTime:p.createdAt];
    }].allObjects;
    discounted = [discounted.mutableCopy objectsPassingTest:^BOOL(Payment *p, BOOL *stop) {
        if ((id)p == [NSNull null]) return NO;
        return [date isEqualToDateIgnoringTime:p.createdAt];
    }].allObjects;
    
    CGFloat allSubtotals = [[orderItems valueForKeyPath:@"@sum.menuItem.price"] floatValue];
    CGFloat allDiscounts = [[discounted valueForKeyPath:@"@sum.menuItem.price"] floatValue];
    
    return @(allSubtotals - allDiscounts);
}

+ (void)getPopularItemsForInterval:(NSDate *)start end:(NSDate *)end callback:(ParseArrayResponseBlock)callback {
    PFQuery *query = [OrderItem queryWithCreatedAtFrom:start.dateAtStartOfDay to:end.dateAtStartOfDay.nextDay includeKeys:@[@"menuItem"]];
    [query whereKeyExists:@"menuItem"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *items, NSError *error) {
        if (!error) {
            items = [items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"menuItem != nil"]];
            // Count the occurences of each menu item (counted set to count them, regular set to get a unique list)
            NSArray *menuItemsWithDuplicates = [items valueForKeyPath:@"menuItem"];
            NSCountedSet *menuItemsCounted   = [[NSCountedSet alloc] initWithArray:menuItemsWithDuplicates];
            NSSet *menuItems                 = [NSSet setWithArray:menuItemsWithDuplicates];
            
            
            // Sort the menu items by their count and take the top 5
            NSArray *sortedByPopularity = [[menuItems.allObjects sortedArrayUsingComparator:^NSComparisonResult(MenuItem *obj1, MenuItem *obj2) {
                NSInteger c1 = [menuItemsCounted countForObject:obj1];
                NSInteger c2 = [menuItemsCounted countForObject:obj2];
                if (c1 > c2)
                    return NSOrderedAscending;
                if (c1 < c2)
                    return NSOrderedDescending;
                
                return [obj1.name compare:obj2.name];
            }] subarrayWithRange:NSMakeRange(0, 6)];
            
            // Set order count (used in summary view)
            for (MenuItem *mi in sortedByPopularity)
                mi.saleCount = [menuItemsCounted countForObject:mi];
            
            callback(sortedByPopularity, nil);
        } else {
            callback(nil, error);
        }
    }];
}

+ (void)getPopularCategoriesForInterval:(NSDate *)start end:(NSDate *)end callback:(ParseArrayResponseBlock)callback {
    PFQuery *query = [OrderItem queryWithCreatedAtFrom:start.dateAtStartOfDay to:end.dateAtStartOfDay.nextDay includeKeys:@[@"menuItem.menuCategory"]];
    [query whereKeyExists:@"menuItem"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *items, NSError *error) {
        if (!error) {
            items = [items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"menuItem != nil"]];
            // Count the occurences of each category
            NSArray *categoriesWithDuplicates = [items valueForKeyPath:@"menuItem.menuCategory"];
            NSCountedSet *categoriesCounted   = [[NSCountedSet alloc] initWithArray:categoriesWithDuplicates];
            NSSet *categories                 = [NSSet setWithArray:categoriesWithDuplicates];
            
            // Sort the categories by their count and take the top 5
            NSArray *sortedByPopularity = [[categories.allObjects sortedArrayUsingComparator:^NSComparisonResult(MenuCategory *obj1, MenuCategory *obj2) {
                NSInteger c1 = [categoriesCounted countForObject:obj1];
                NSInteger c2 = [categoriesCounted countForObject:obj2];
                if (c1 < c2)
                    return NSOrderedAscending;
                if (c1 > c2)
                    return NSOrderedDescending;
                
                return [obj1.name compare:obj2.name];
            }] subarrayWithRange:NSMakeRange(0, 4)];
            
            // Set order count (used in summary view)
            for (MenuCategory *mc in sortedByPopularity)
                mc.saleCount = [categoriesCounted countForObject:mc];
            
            callback(sortedByPopularity, nil);
        } else {
            callback(nil, error);
        }
    }];
}

+ (void)getAveragePaymentForInterval:(NSDate *)start end:(NSDate *)end callback:(ParseTwoObjectResponseBlock)callback {
    [self getTransactionsForInterval:start end:end callback:^(NSArray *orders, NSError *error) {
        if (!error) {
            callback(@([[orders valueForKeyPath:@"@sum.total"] floatValue]/orders.count), @(orders.count), nil);
        } else {
            callback(nil, nil, error);
        }
    }];
}

+ (void)getGuestCountForInterval:(NSDate *)start end:(NSDate *)end callback:(ParseObjectResponseBlock)callback {
    PFQuery *query = [Party queryWithCreatedAtFrom:start.dateAtStartOfDay to:end.dateAtStartOfDay.nextDay includeKeys:nil];
    [query whereKey:@"arrivedAt" greaterThanOrEqualTo:start];
    [query findObjectsInBackgroundWithBlock:^(NSArray *parties, NSError *error) {
        if (!error) {
            callback([parties valueForKeyPath:@"@sum.size"], nil);
        } else {
            callback(nil, error);
        }
    }];
}

+ (void)getLaborCostForInterval:(NSDate *)start end:(NSDate *)end callback:(ParseObjectResponseBlock)callback {
    PFQuery *query = [Shift queryWithCreatedAtFrom:start.dateAtStartOfDay to:end.dateAtStartOfDay.nextDay includeKeys:@[@"employee"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *shifts, NSError *error) {
        if (!error) {
            shifts = [shifts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"employee.restaurant.objectId = %@", currentRestaurant.objectId]];
            
            callback([shifts valueForKeyPath:@"@sum.laborCost"], nil);
        } else {
            callback(nil, error);
        }
    }];
}

+ (void)getTransactionsForInterval:(NSDate *)start end:(NSDate *)end callback:(ParseArrayResponseBlock)callback {
    PFQuery *query = [Order queryWithCreatedAtFrom:start.dateAtStartOfDay to:end.dateAtStartOfDay.nextDay includeKeys:nil];
    [query whereKeyExists:@"payment"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *orders, NSError *error) {
        if (!error) {
            callback(orders, nil);
        } else {
            callback(nil, error);
        }
    }];
}

+ (void)getMenus:(ParseArrayResponseBlock)callback {
    [currentRestaurant.menus.query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        callback(error ? nil : objects, error);
    }];
}

+ (void)getMenuCategoriesOfMenu:(Menu *)menu callback:(ParseArrayResponseBlock)callback {
    PFQuery *query = [[MenuCategory query] whereKey:@"menu" equalTo:menu];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        callback(error ? nil : objects, error);
    }];
}

+ (void)getAllMenuCategories:(ParseArrayResponseBlock)callback {
    [self getMenus:^(NSArray *menus, NSError *error) {
        if (!error) {
            
            NSMutableArray *categories = [NSMutableArray array];
            __block NSError *lastError = nil; // Shaky solution to error handling when making several requests like this. TODO: refactor
            for (Menu *menu in menus) {
                [self getMenuCategoriesOfMenu:menu callback:^(NSArray *someCategories, NSError *catError) {
                    if (!catError) {
                        [categories addObject:someCategories];
                    } else {
                        lastError = catError;
                        [categories addObject:@[]];
                    }
                    
                    // When we finally have every category...
                    if (categories.count == menus.count) {
                        callback([categories valueForKeyPath:@"@unionOfArrays.self"], lastError);
                    }
                }];
            }
        } else {
            callback(nil, error);
        }
    }];
}

+ (void)getAllMenuItems:(ParseArrayResponseBlock)callback {
    [self getAllMenuCategories:^(NSArray *categories, NSError *error) {
        if (!error) {
            
            NSMutableArray *menuItems = [NSMutableArray array];
            __block NSError *lastError = nil; // Shaky solution to error handling when making several requests like this. TODO: refactor
            for (MenuCategory *cat in categories) {
                [self getMenuItemsOfMenuCategory:cat callback:^(NSArray *someMenuItems, NSError *miError) {
                    if (!miError) {
                        [menuItems addObject:someMenuItems];
                    } else {
                        lastError = miError;
                        [menuItems addObject:@[]];
                    }
                    
                    // When we finally have every menu item...
                    if (menuItems.count == categories.count) {
                        callback([menuItems valueForKeyPath:@"@unionOfArrays.self"], lastError);
                    }
                }];
            }
        } else {
            callback(nil, error);
        }
    }];
}

+ (void)getMenuItemsOfMenuCategory:(MenuCategory *)category callback:(ParseArrayResponseBlock)callback {
    PFQuery *query = [[MenuItem query] whereKey:@"menuCategory" equalTo:category];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        callback(error ? nil : objects, error);
    }];
}

+ (void)getAllMenuItemModifiers:(ParseArrayResponseBlock)callback {
    [self getAllMenuItems:^(NSArray *menuItems, NSError *error) {
        if (!error) {
            
            NSMutableArray *modifiers = [NSMutableArray array];
            __block NSError *lastError = nil; // Shaky solution to error handling when making several requests like this. TODO: refactor
            for (MenuItem *mi in menuItems) {
                
                PFQuery *query = [[MenuItemModifier query] whereKey:@"menuItems" equalTo:mi];
                [query findObjectsInBackgroundWithBlock:^(NSArray *someModifiers, NSError *modError) {
                    if (!modError) {
                        [modifiers addObject:someModifiers];
                    } else {
                        lastError = modError;
                        [modifiers addObject:@[]];
                    }
                    
                    // When we finally have every menu item modifier...
                    if (modifiers.count == menuItems.count) {
                        // There could be duplicates. There almost certainly will be.
                        NSSet *allUniqueModifiers = [NSSet setWithArray:[modifiers valueForKeyPath:@"@unionOfArrays.self"]];
                        callback(allUniqueModifiers.allObjects, lastError);
                    }
                }];
            }
        } else {
            callback(nil, error);
        }
    }];
}






+ (NSString *)parseErrorMsgFromError:(NSError *)error {
>>>>>>> origin/tanner
    NSString *errorMsg = @"";
    if (error.code == kPFErrorConnectionFailed) {
        errorMsg = @"The connection to the server failed";
    } else {
        errorMsg = [error.userInfo valueForKey:@"error"];
    }
    return errorMsg;
}

+ (void)emailLogin:(id<CommsDelegate>)delegate userInfo:(NSDictionary *)userInfo {
    NSString *email = [userInfo valueForKey:@"email"];
    NSString *password = [userInfo valueForKey:@"pswd"];
    
    [PFUser logInWithUsernameInBackground:email password:password block:^(PFUser *user, NSError *error) {
<<<<<<< HEAD
        NSString *user_email = [user objectForKey:@"email"];
        
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        [response setObject:[NSNumber numberWithInt:1] forKey:@"action"];
        if ( !error ) {
            //save current user email address
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:user_email forKey:@"curUserEmail"];
            
            
            [response setObject:[NSNumber numberWithBool:YES] forKey:@"responseCode"];
=======
        EMUser *userr = (id)user;
        
        NSMutableDictionary *response = [NSMutableDictionary dictionary];
        response[@"action"] = @1;
        if ( !error ) {
            // save current user email address
            [[NSUserDefaults standardUserDefaults] setObject:user.email forKey:@"curUserEmail"];
            
            response[@"responseCode"] = @YES;
>>>>>>> origin/tanner
        } else {
            response[@"responseCode"] = @NO;
            response[@"errorMsg"] = [CommParse parseErrorMsgFromError:error];
        }
        
        PFQuery *findRestaurant = [userr.restaurants query];
        [findRestaurant findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error && objects.count) {
                currentRestaurant = objects.firstObject;
                if ([delegate respondsToSelector:@selector(commsDidAction:)])
                    [delegate commsDidAction:response];
            } else {
                [ProgressHUD showError:@"Failed to load restaurant data"];
            }
        }];
    }];
}

//***** Response number *******
// 1: get, 2: add update, 3: delete

+ (void)getBusinessMenus:(id<CommsDelegate>)delegate menuType:(NSString *)menuType topKey:(NSString *)topKey topObject:(PFObject *)topObject {
    if ([menuType isEqualToString:@"MenuItemModifier"]) {
        [self getAllMenuItemModifiers:^(NSArray *objects, NSError *error) {
            NSMutableDictionary *response = [NSMutableDictionary dictionary];
            response[@"action"] = @1;
            response[@"menu_type"] = menuType;
            if ( !error ) {
                response[@"responseCode"] = @YES;
                response[@"objects"] = objects;
            } else {
                response[@"responseCode"] = @NO;
                response[@"errorMsg"] = [CommParse parseErrorMsgFromError:error];
            }
            if ([delegate respondsToSelector:@selector(commsDidAction:)])
                [delegate commsDidAction:response];
        }];
        return;
    } else if ([menuType isEqualToString:@"Employee"]) {
        
    }
    
    // Get class query if possible
    PFQuery *query;
    id cls = NSClassFromString(menuType);
    query = cls ? [(id)cls queryCurrentRestaurant] : [PFQuery queryWithClassName:menuType];
    
    if (topKey.length)
        [query whereKey:topKey equalTo:topObject];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        NSMutableDictionary *response = [NSMutableDictionary dictionary];
        response[@"action"] = @1;
        response[@"menu_type"] = menuType;
        if ( !error ) {
            response[@"responseCode"] = @YES;
            response[@"objects"] = objects;
        } else {
            response[@"responseCode"] = @NO;
            response[@"errorMsg"] = [CommParse parseErrorMsgFromError:error];
        }
        if ([delegate respondsToSelector:@selector(commsDidAction:)])
            [delegate commsDidAction:response];
    }];
}


+ (void)updateQuoteRequest:(id<CommsDelegate>)delegate Quote:(PFObject *)quote {
    NSLog(@"Comms update:");
    [quote saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSMutableDictionary *response = [NSMutableDictionary dictionary];
        response[@"action"] = @2;
        if (!error && succeeded) {
            response[@"responseCode"] = @YES;
        } else {
            response[@"responseCode"] = @NO;
            response[@"errorMsg"] = [CommParse parseErrorMsgFromError:error];
        }
        if ([delegate respondsToSelector:@selector(commsDidAction:)])
            [delegate commsDidAction:response];
    }];
}

+ (void)deleteQuoteRequest:(id<CommsDelegate>)delegate Quote:(PFObject *)quote {
    [quote deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSMutableDictionary *response = [NSMutableDictionary dictionary];
        response[@"action"] = @3;
        if (!error && succeeded) {
            response[@"responseCode"] = @YES;
        } else {
            response[@"responseCode"] = @NO;
            response[@"errorMsg"] = [CommParse parseErrorMsgFromError:error];
        }
        if ([delegate respondsToSelector:@selector(commsDidAction:)])
            [delegate commsDidAction:response];
    }];
}

+ (void)getMenuItemsOfModifier:(id<CommsDelegate>)delegate modifierect:(PFObject *)modifierect {
    PFRelation *relation = [modifierect relationForKey:@"menuItems"];
    PFQuery *query = [relation query];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableDictionary *response = [NSMutableDictionary dictionary];
        response[@"action"] = @1;
        if ( !error ) {
            response[@"responseCode"] = @YES;
            response[@"objects"] = objects;
        } else {
            response[@"responseCode"] = @NO;
            response[@"errorMsg"] = [CommParse parseErrorMsgFromError:error];
        }
        if ([delegate respondsToSelector:@selector(commsDidAction:)])
            [delegate commsDidAction:response];
    }];
}

+ (void)getBusinessMenuInfo:(id<CommsDelegate>)delegate menuType:(NSString *)menuType MenuId:(NSString *)menuId {
    PFQuery *query = [PFQuery queryWithClassName:menuType];
    [query whereKey:@"objectId" equalTo:menuId];
    
}

// Get Analytics Datas
+ (void)getAnalyticsSalesView:(id<CommsDelegate>)delegate startDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    [ProgressHUD show:@"" Interaction:NO];
    
    PFQuery *query = [OrderItem queryWithCreatedAtFrom:startDate to:endDate includeKeys:@[@"menuItem"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *orderItems, NSError *error) {
        if (!error) {
            CGFloat discountVal = 0;
            for(OrderItem *order in [orderItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"onTheHouse = YES"]])
                discountVal += order.menuItem.price;
            
            // Get Payments
            PFQuery *query = [Payment queryWithCreatedAtFrom:startDate to:endDate includeKeys:@[@"order"]];
            [query whereKeyExists:@"order"];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *payments, NSError *error) {
                NSMutableDictionary *response = [NSMutableDictionary dictionary];
                response[@"action"] = @1;
                if ( !error ) {
                    response[@"responseCode"] = @YES;
                    response[@"objects"] = payments;
                    response[@"discount"] = @(discountVal);
                } else {
                    response[@"responseCode"] = @NO;
                    response[@"errorMsg"] = [CommParse parseErrorMsgFromError:error];
                }
                
                if ([delegate respondsToSelector:@selector(commsDidAction:)])
                    [delegate commsDidAction:response];
            }];
        }
    }];
}

+ (void)getAnalyticsCategorySales:(id<CommsDelegate>)delegate startDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    [ProgressHUD show:@"" Interaction:NO];
    
    // Get discounts(get menuitems price which orderitem's onthehouse is true)
    PFQuery *orderItemQuery = [OrderItem queryWithCreatedAtFrom:startDate to:endDate includeKeys:@[@"menuItem", @"menuItem.menuCategory", @"order", @"order.payment"]];
    [orderItemQuery whereKeyExists:@"menuItem"];
    [orderItemQuery whereKeyExists:@"order"];
    
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    
    __block NSMutableArray *orders;
    
    [orderItemQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for(OrderItem *orderItem in objects) {
                NSString *categoryIdentifier = orderItem.menuItem.menuCategory.objectId;
                
                // get discount value
                CGFloat discountValue = 2;
                if (orderItem.onTheHouse) {
                    discountValue = orderItem.menuItem.price;
                }
                
                // Sales
                CGFloat totalSales = orderItem.order.total;
                
                // if exist same menu item
                if (results[categoryIdentifier]) {
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
                    orders = [NSMutableArray array];
                    
                    [orders addObject:orderItem.menuItem.menuCategory.name];
                    [orders addObject:@(totalSales)];
                    [orders addObject:@(discountValue)];
                }
                results[categoryIdentifier] = orders;
            }
            
            
            NSMutableDictionary *response = [NSMutableDictionary dictionary];
            response[@"action"] = @1;
            if ( !error ) {
                response[@"responseCode"] = @YES;
                response[@"objects"] = results;
            } else {
                response[@"responseCode"] = @NO;
                response[@"errorMsg"] = [CommParse parseErrorMsgFromError:error];
            }
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([delegate respondsToSelector:@selector(commsDidAction:)])
                    [delegate commsDidAction:response];
            });
        });
    }];
}

+ (void)getAnalyticsEmployeeShifts:(id<CommsDelegate>)delegate startDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    [ProgressHUD show:@"" Interaction:NO];
    
    PFQuery *shiftQuery = [Shift queryWithCreatedAtFrom:startDate to:endDate includeKeys:@[@"employee"]];
    [shiftQuery orderByAscending:@"employee"];
    
    // emp name, date, start time, end time, calculate times, hours worked, tips
    
    [shiftQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        // calculate tips
        PFQuery *paymentQuery = [Payment queryWithCreatedAtFrom:startDate to:endDate];
        [paymentQuery findObjectsInBackgroundWithBlock:^(NSArray *paymentects, NSError *error) {
            
            NSMutableDictionary *response = [NSMutableDictionary dictionary];
            response[@"action"] = @1;
            if ( !error ) {
                response[@"responseCode"] = @YES;
                response[@"objects"] = objects;
                response[@"pay_objects"] = paymentects;
            } else {
                response[@"responseCode"] = @NO;
                response[@"errorMsg"] = [CommParse parseErrorMsgFromError:error];
            }
            
            if ([delegate respondsToSelector:@selector(commsDidAction:)])
                [delegate commsDidAction:response];
        }];
        
    }];
    
}

+ (void)getAnalyticsPayroll:(id<CommsDelegate>)delegate startDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    [ProgressHUD show:@"" Interaction:NO];
    
    PFQuery *shiftQuery = [Shift queryWithCreatedAtFrom:startDate to:endDate includeKeys:@[@"employee"]];
    [shiftQuery orderByAscending:@"employee"];
    
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    
    // name, hours worked, tips, hourly wage
    
    [shiftQuery findObjectsInBackgroundWithBlock:^(NSArray *shifts, NSError *error) {
        NSMutableArray *employees;
        NSString *employeeIdentifier;
        
        // This is how you'd get the labor cost by employee,                   //
        // such that results[@"bob"] holds bob's wages for the given interval. //
        // I've left it commented out as it looks like it's going to take a    //
        // lot more work to ge the view to display this info properly because  //
        // of the weird way the freelancer is packaging the data.              //
        
//        shifts = [shifts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"employee.restaurant.objectId = %@", currentRestaurant.objectId]];
//        NSArray *employees = [shifts valueForKeyPath:@"@unionOfObjects.employee.objectId"];
//        for (NSString *employeeIdentifier in employees) {
//            NSArray *employeesShifts = [shifts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"employee.objectId = %@", employeeIdentifier]];
//            results[employeeIdentifier] = [employeesShifts valueForKeyPath:@"@sum.laborCost"];
//        }
        
        // The rest is the old, shitty code.
        
        for(Shift *shift in shifts) {
            employeeIdentifier = shift.employee.objectId;
            
            // calculate Time
            NSTimeInterval timeDifference = [shift.endedAt timeIntervalSinceDate:shift.startedAt];
            CGFloat hoursDiff = timeDifference/3600;
            
            // if exist same emp
            if (results[employeeIdentifier]) {
                // get that info
                employees = results[employeeIdentifier];
                
                hoursDiff = hoursDiff + [employees[1] floatValue];
                // hours
                employees[1] = @(hoursDiff);
            }
            else {
                // if not exist then init
                employees = [NSMutableArray array];
                
                [employees addObject:shift.employee.name];
                [employees addObject:@(hoursDiff)];
                [employees addObject:@0];
                [employees addObject:@(shift.employee.hourlyWage)];
            }
            
            results[employeeIdentifier] = employees;
        }
        
        // calculate tips
        PFQuery *paymentQuery = [Payment queryWithCreatedAtFrom:startDate to:endDate includeKeys:@[@"order", @"party", @"party.server"]];
        [paymentQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                for(Payment *payment in objects){
                    CGFloat tips = payment.order.tip;
                    
                    // if exist same emp
                    if (results[employeeIdentifier]) {
                        // get that info
                        [employees setArray:results[employeeIdentifier]];
                        
                        tips = tips + [employees[2] floatValue];
                        // tips
                        employees[2] = @(tips);
                    }
                    else {
                        // if not exist then init
                        [employees removeAllObjects];
                       // NSParameterAssert(employees);
                        [employees addObject:payment.party.server.name];
                        [employees addObject:@0.0];
                        [employees addObject:@(tips)];
                        [employees addObject:@(payment.party.server.hourlyWage)];
                    }
                    results[employeeIdentifier] = employees;
                }
            }
            
            NSMutableDictionary *response = [NSMutableDictionary dictionary];
            response[@"action"] = @1;
            if ( !error ) {
                response[@"responseCode"] = @YES;
                response[@"objects"] = results;
            } else {
                response[@"responseCode"] = @NO;
                response[@"errorMsg"] = [CommParse parseErrorMsgFromError:error];
            }
            
            if ([delegate respondsToSelector:@selector(commsDidAction:)])
                [delegate commsDidAction:response];
        }];
    }];
    
}

+ (void)getAnalyticsOrderReport:(id<CommsDelegate>)delegate startDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    [ProgressHUD show:@"" Interaction:NO];
    
    PFQuery *orderItemQuery = [OrderItem queryWithCreatedAtFrom:startDate to:endDate includeKeys:@[@"menuItem", @"menuItem.menuCategory", @"menuItem.menuCategory.menu", @"order", @"order.payment"]];
    [orderItemQuery whereKey:@"menuItem" matchesQuery:[[MenuItem query] whereKey:@"menuCategory" matchesQuery:[[MenuCategory query] whereKeyExists:@"menu"]]];
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    
    [orderItemQuery findObjectsInBackgroundWithBlock:^(NSArray *orderItems, NSError *error) {
        NSMutableArray *orders;
        NSInteger timesOrdered;
        for(OrderItem *orderItem in orderItems){
            // Sales
            CGFloat totalSales = orderItem.order.total;
            
            // if exist same menu item
            if (results[orderItem.menuItem.objectId]) {
                // get that info
                orders = results[orderItem.menuItem.objectId];
                
                // times
                timesOrdered = [orders[3] intValue] + 1;
                orders[3] = @(timesOrdered);
                // sales
                totalSales = totalSales + [orders[4] floatValue];
                orders[4] = @(totalSales);
            }
            else {
                // if not exist then init
                orders = [NSMutableArray array];
                
                [orders addObject:orderItem.menuItem.name];
                [orders addObject:orderItem.menuItem.menuCategory.menu.name];
                [orders addObject:orderItem.menuItem.menuCategory.name];
                [orders addObject:@1];
                [orders addObject:@(totalSales)];
            }
            results[orderItem.menuItem.objectId] = orders;
        }
        
        NSMutableDictionary *response = [NSMutableDictionary dictionary];
        response[@"action"] = @1;
        if ( !error ) {
            response[@"responseCode"] = @YES;
            response[@"objects"] = results;
        } else {
            response[@"responseCode"] = @NO;
            response[@"errorMsg"] = [CommParse parseErrorMsgFromError:error];
        }
        
        
        if ([delegate respondsToSelector:@selector(commsDidAction:)])
            [delegate commsDidAction:response];
    }];
}

<<<<<<< HEAD
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
    
    [order_query findObjectsInBackgroundWithBlock:^(NSArray *order_objects, NSError *error) {
        
        if(!error){
            PFObject *item_obj;
            for(PFObject *object in order_objects){
                item_obj =[object objectForKey:@"menuItem"];
                
                discount_val += [[item_obj objectForKey:@"price"] floatValue];
            }
            NSLog(@"%f", discount_val);
            
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
        
    }];
    
=======
+ (void)getAnalyticsModifierSales:(id<CommsDelegate>)delegate startDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    [ProgressHUD show:@"" Interaction:NO];
    
    PFQuery *orderItemQuery = [OrderItem queryWithCreatedAtFrom:startDate to:endDate includeKeys:@[@"menuItem", @"menuItem.menuCategory", @"menuItemModifiers", @"order", @"order.payment"]];
    [orderItemQuery whereKeyExists:@"menuItem"];
    [orderItemQuery whereKeyExists:@"menuItemModifiers"];
    [orderItemQuery whereKeyExists:@"order"];
    
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    NSMutableDictionary *timess = [NSMutableDictionary dictionary];
    
    __block NSMutableArray *orders;
    
    [orderItemQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for(OrderItem *orderItem in objects) {
            for(MenuItemModifier *modifier in orderItem.menuItemModifiers) {
                if (![modifier isKindOfClass:[MenuItemModifier class]]) break; // <null> in the arrays from dead pointers
                
                NSString *menuItemID = orderItem.menuItem.objectId;
                
                // if not exist then init
                int times = [timess[menuItemID] intValue]+1;
                
                timess[menuItemID] = @(times);
                
                orders = [NSMutableArray array];
                
                [orders addObject:modifier.name];
                [orders addObject:orderItem.menuItem.name];
                [orders addObject:orderItem.menuItem.menuCategory.name];
                [orders addObject:orderItem.menuItem.objectId];
                [orders addObject:@(modifier.price)];
                
                NSString *keyStr = [NSString stringWithFormat:@"%@_%@", modifier.objectId, menuItemID];
                results[keyStr] = orders;
            }
        }
        
        NSMutableDictionary *response = [NSMutableDictionary dictionary];
        response[@"action"] = @1;
        if ( !error ) {
            response[@"responseCode"] = @YES;
            response[@"objects"] = results;
            response[@"time_objects"] = timess;
        } else {
            response[@"responseCode"] = @NO;
            response[@"errorMsg"] = [CommParse parseErrorMsgFromError:error];
        }
        
        
        if ([delegate respondsToSelector:@selector(commsDidAction:)])
            [delegate commsDidAction:response];
    }];
    
}


// Email Send via MailGun
+ (void)sendEmailwithMailGun:(id<CommsDelegate>)delegate userEmail:(NSString *)userEmail emailSubject:(NSString *)emailSubject emailContent:(NSString *)emailContent {
    
    NSString *csvName = @"analytics.csv";
    
    NSString *curUserEmail = [[NSUserDefaults standardUserDefaults] objectForKey:kExportEmailPrefKey];
    if (!curUserEmail)
        return;
    
    // Mailgun API Key
    Mailgun *mailgun = [Mailgun clientWithDomain:@"sandboxd17cd83f7a424425b963d8ef54e5c218.mailgun.org" apiKey:@"key-1595ddf58f0a7d74c0042bdb34a9e75d"];
    
    NSMutableDictionary *response = [NSMutableDictionary dictionary];
    // set response action code 9
    response[@"action"] = @9;
    
    MGMessage *message = [MGMessage messageFrom:@"Entree Manager <manager@entree.org>"
                                             to:curUserEmail
                                        subject:emailSubject
                                           body:emailContent];
    
    NSArray *paths     = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir   = paths.firstObject;
    NSString *filename = [docDir stringByAppendingPathComponent:csvName];
    NSError *error     = NULL;
    BOOL written       = [emailContent writeToFile:filename atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!written)
        NSLog(@"write failed, error = %@", error.localizedDescription);
    
    NSData *emailData = [NSData dataWithContentsOfFile:filename];
    [message addAttachment:emailData withName:[emailSubject stringByAppendingString:@".csv"] type:@"csv"];
    
    [ProgressHUD show:[NSString stringWithFormat:@"Sending email to %@...", userEmail]];
    [mailgun sendMessage:message success:^(NSString *messageId) {
        response[@"responseCode"] = @YES;
        
        
        if ([delegate respondsToSelector:@selector(commsDidAction:)])
            [delegate commsDidAction:response];
        [ProgressHUD showSuccess:@"Sent email successfully!"];
        
        NSLog(@"Message %@ sent successfully!", messageId);
    } failure:^(NSError *error) {
        response[@"responseCode"] = @NO;
        NSLog(@"Error sending message:%@", error.localizedDescription);
        if ([delegate respondsToSelector:@selector(commsDidAction:)])
            [delegate commsDidAction:response];
    }];
>>>>>>> origin/tanner
    
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
    __block int timesOrdered;
    
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
                timesOrdered = [[orderArray objectAtIndex:3] intValue] + 1;
                [orderArray replaceObjectAtIndex:3 withObject: [NSNumber numberWithInt:timesOrdered]];
                //sales
                total_sales = total_sales + [[orderArray objectAtIndex:4] floatValue];
                [orderArray replaceObjectAtIndex:4 withObject: [NSNumber numberWithFloat:total_sales]];
                
            }
            else{
                //if not exist then init
                orderArray = [[NSMutableArray alloc] init];
                
                [orderArray addObject:item_name];
                [orderArray addObject:menu_name];
                [orderArray addObject:cat_name];
                [orderArray addObject:[NSNumber numberWithInt:1]];
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
    
    NSMutableDictionary *timesArray;
    timesArray = [[NSMutableDictionary alloc] init];
    
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
            
            NSArray *modifierArray =[orditem_obj objectForKey:@"menuItemModifiers"];
            for(PFObject *modifier_obj in modifierArray){
                item_obj =[modifier_query getObjectWithId:modifier_obj.objectId];
                NSString *modi_name = [item_obj objectForKey:@"name"];
                
                //Sales
                item_obj =[orditem_obj objectForKey:@"order"];
                
                pay_obj =[item_obj objectForKey:@"payment"];
                pay_obj =[pay_query getObjectWithId:pay_obj.objectId];
                float total_sales =[[pay_obj objectForKey:@"total"] floatValue];
                
                //if not exist then init
                int times = 1;
                if([timesArray objectForKey:item_id]){
                    //get that info
                    times = [[timesArray objectForKey:item_id] intValue]+1;
                }
                else times=1;
                
                [timesArray  setObject:[ NSNumber numberWithInt:times ] forKey:item_id];
                
                orderArray = [[NSMutableArray alloc] init];
                
                [orderArray addObject:modi_name];
                [orderArray addObject:item_name];
                [orderArray addObject:cat_name];
                [orderArray addObject:item_id];
                [orderArray addObject:[NSNumber numberWithFloat:total_sales]];
                
                NSString *key_str = [NSString stringWithFormat:@"%@_%@", modifier_obj.objectId, item_id];
                [resultArray  setObject:orderArray forKey:key_str];
            }
            
        }
        
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        [response setObject:[NSNumber numberWithInt:1] forKey:@"action"];
        if ( !error ) {
            [response setObject:[NSNumber numberWithBool:YES] forKey:@"responseCode"];
            [response setObject:resultArray forKey:@"objects"];
            [response setObject:timesArray forKey:@"time_objects"];
            
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
