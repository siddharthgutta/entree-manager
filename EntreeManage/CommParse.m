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
    [query findObjectsInBackgroundWithBlock:^(NSArray *payments, NSError *error) {
        if (!error) {
            NSArray *orderItems  = [[payments valueForKeyPath:@"order.orderItems"] valueForKeyPath:@"@unionOfArrays.self"];
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
    [query findObjectsInBackgroundWithBlock:^(NSArray *payments, NSError *error) {
        if (!error) {
            NSArray *orderItems  = [[payments valueForKeyPath:@"order.orderItems"] valueForKeyPath:@"@unionOfArrays.self"];
            NSArray *discounted  = [orderItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"onTheHouse = YES"]];
            
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
        return [date isEqualToDateIgnoringTime:p.createdAt];
    }].allObjects;
    discounted = [discounted.mutableCopy objectsPassingTest:^BOOL(Payment *p, BOOL *stop) {
        return [date isEqualToDateIgnoringTime:p.createdAt];
    }].allObjects;
    
    CGFloat allSubtotals = [[orderItems valueForKeyPath:@"@sum.menuItem.price"] floatValue];
    CGFloat allDiscounts = [[discounted valueForKeyPath:@"@sum.menuItem.price"] floatValue];
    
    return @(allSubtotals - allDiscounts);
}

+ (void)getPopularItemsForInterval:(NSDate *)start end:(NSDate *)end callback:(ParseArrayResponseBlock)callback {
    PFQuery *query = [OrderItem queryWithCreatedAtFrom:start.dateAtStartOfDay to:end.dateAtStartOfDay.nextDay includeKeys:@[@"menuItem"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *items, NSError *error) {
        if (!error) {
            // Count the occurences of each menu item
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
    [query findObjectsInBackgroundWithBlock:^(NSArray *items, NSError *error) {
        if (!error) {
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
    PFQuery *query = [Payment queryWithCreatedAtFrom:start.dateAtStartOfDay to:end.dateAtStartOfDay.nextDay includeKeys:nil];
    [query findObjectsInBackgroundWithBlock:^(NSArray *payments, NSError *error) {
        if (!error) {
            callback(@([[payments valueForKeyPath:@"@sum.total"] floatValue]/payments.count), @(payments.count), nil);
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
        NSString *userEmail = user[@"email"];
        
        NSMutableDictionary *response = [NSMutableDictionary dictionary];
        response[@"action"] = @1;
        if ( !error ) {
            // save current user email address
            [[NSUserDefaults standardUserDefaults] setObject:userEmail forKey:@"curUserEmail"];
            
            
            response[@"responseCode"] = @YES;
        } else {
            response[@"responseCode"] = @NO;
            response[@"errorMsg"] = [CommParse parseErrorMsgFromError:error];
        }
        
        PFQuery *findRestaurant = [(PFRelation *)user[@"restaurants"] query];
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
    // Get class query if possible
    PFQuery *query;
    id cls = NSClassFromString(menuType);
    query = cls ? [(Class)cls query] : [PFQuery queryWithClassName:menuType];
    
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

+ (void)menus:(void(^)(NSArray *menus))callback {
    [currentRestaurant.menus.query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            callback(objects);
        } else {
            [ProgressHUD showError:error.localizedDescription];
        }
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
    
    __block CGFloat discountVal = 0;
    
    PFQuery *query = [OrderItem query];
    [query whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
    [query whereKey:@"createdAt" lessThanOrEqualTo:endDate];
    [query includeKey:@"menuItem"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *orderItems, NSError *error) {
        if (!error) {
            for(OrderItem *order in orderItems)
                discountVal += order.menuItem.price;
            
            // Get Payments
            PFQuery *query = [Payment query];
            [query whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
            [query whereKey:@"createdAt" lessThanOrEqualTo:endDate];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                NSMutableDictionary *response = [NSMutableDictionary dictionary];
                response[@"action"] = @1;
                if ( !error ) {
                    response[@"responseCode"] = @YES;
                    response[@"objects"] = objects;
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
    PFQuery *orderItemQuery = [OrderItem query];
    [orderItemQuery whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
    [orderItemQuery whereKey:@"createdAt" lessThanOrEqualTo:endDate];
    [orderItemQuery includeKey:@"menuItem"];
    [orderItemQuery includeKey:@"menuItem.menuCategory"];
    [orderItemQuery includeKey:@"order"];
    [orderItemQuery includeKey:@"order.payment"];
    
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
                CGFloat totalSales = orderItem.order.payment.total;
                
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
    
    PFQuery *shiftQuery = [Shift query];
    [shiftQuery whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
    [shiftQuery whereKey:@"createdAt" lessThanOrEqualTo:endDate];
    [shiftQuery includeKey:@"employee"];
    [shiftQuery orderByAscending:@"employee"];
    
    // emp name, date, start time, end time, calculate times, hours worked, tips
    
    [shiftQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        // calculate tips
        PFQuery *paymentQuery = [Payment query];
        [paymentQuery whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
        [paymentQuery whereKey:@"createdAt" lessThanOrEqualTo:endDate];
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
    
    PFQuery *shiftQuery = [Shift query];
    [shiftQuery whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
    [shiftQuery whereKey:@"createdAt" lessThanOrEqualTo:endDate];
    [shiftQuery includeKey:@"employee"];
    [shiftQuery orderByAscending:@"employee"];
    
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    
    // name, hours worked, tips, hourly wage
    
    [shiftQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *employees;
        NSString *employeeIdentifier;
        for(Shift *shift in objects) {
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
        PFQuery *paymentQuery = [Payment query];
        [paymentQuery whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
        [paymentQuery whereKey:@"createdAt" lessThanOrEqualTo:endDate];
        [paymentQuery includeKey:@"party"];
        [paymentQuery includeKey:@"party.server"];
        [paymentQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error) {
                
                for(Payment *payment in objects){
                    CGFloat tips = payment.tip;
                    
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
    
    PFQuery *orderItemQuery = [OrderItem query];
    [orderItemQuery whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
    [orderItemQuery whereKey:@"createdAt" lessThanOrEqualTo:endDate];
    [orderItemQuery includeKey:@"menuItem"];
    [orderItemQuery includeKey:@"menuItem.menuCategory"];
    [orderItemQuery includeKey:@"menuItem.menuCategory.menu"];
    [orderItemQuery includeKey:@"order"];
    [orderItemQuery includeKey:@"order.payment"];
    
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    
    [orderItemQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *orders;
        NSInteger timesOrdered;
        for(OrderItem *orderItem in objects){
            // Sales
            CGFloat totalSales = orderItem.order.payment.total;
            
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
    
    PFQuery *orderItemQuery = [OrderItem query];
    [orderItemQuery whereKey:@"createdAt" greaterThanOrEqualTo:startDate];
    [orderItemQuery whereKey:@"createdAt" lessThanOrEqualTo:endDate];
    [orderItemQuery includeKey:@"menuItem"];
    [orderItemQuery includeKey:@"menuItem.menuCategory"];
    [orderItemQuery includeKey:@"menuItemModifiers"];
    [orderItemQuery includeKey:@"order"];
    [orderItemQuery includeKey:@"order.payment"];
    //    [orderItemQuery includeKey:@"menuItemModifiers"];
    
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *timess = [NSMutableDictionary dictionary];
    
    __block NSMutableArray *orders;
    
    [orderItemQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for(OrderItem *orderItem in objects) {
            for(MenuItemModifier *modifier in orderItem.menuItemModifiers) {
                NSString *menuItemID = orderItem.menuItem.objectId;
                
                // if not exist then init
                int times = [timess[menuItemID] intValue]+1;
                
                timess[menuItemID] = @(times);
                
                orders = [NSMutableArray array];
                
                [orders addObject:modifier.name];
                [orders addObject:orderItem.menuItem.name];
                [orders addObject:orderItem.menuItem.menuCategory.name];
                [orders addObject:orderItem.menuItem.objectId];
                [orders addObject:@(orderItem.order.payment.total)];
                
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
    
    NSString *curUserEmail =  [[NSUserDefaults standardUserDefaults] objectForKey:@"curUserEmail"];
    
    // send to current user's email
    if (!userEmail.length) {
        if (!curUserEmail.length)
            userEmail = @"happywithyou86@gmail.com";
        else
            userEmail = curUserEmail;
    }
    
    // Mailgun API Key
    Mailgun *mailgun = [Mailgun clientWithDomain:@"sandboxd17cd83f7a424425b963d8ef54e5c218.mailgun.org" apiKey:@"key-1595ddf58f0a7d74c0042bdb34a9e75d"];
    
    NSMutableDictionary *response = [NSMutableDictionary dictionary];
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
    if (!written) NSLog(@"write failed, error = %@", error);
    
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
