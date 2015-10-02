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
        EMUser *userr = (id)user;
        
        NSMutableDictionary *response = [NSMutableDictionary dictionary];
        response[@"action"] = @1;
        if ( !error ) {
            // save current user email address
            [[NSUserDefaults standardUserDefaults] setObject:user.email forKey:@"curUserEmail"];
            
            response[@"responseCode"] = @YES;
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
    [query whereKey:@"objectID" equalTo:menuId];
    
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
                        NSParameterAssert(employees);
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
    
}



@end
