//
//  CommParse.h
//  EntreeManage
//
//  Created by Faraz on 7/25/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "ProgressHUD.h"
#import "Mailgun.h"
@class Restaurant, Menu, MenuCategory, MenuItem;

typedef void (^ParseObjectResponseBlock)(id object, NSError *error);
typedef void (^ParseTwoObjectResponseBlock)(id object1, id object2, NSError *error);
typedef void (^ParseArrayResponseBlock)(NSArray *objects, NSError *error);

@protocol CommsDelegate <NSObject>
- (void)commsDidAction:(NSDictionary *)response;
@end


@interface CommParse : NSObject

+ (Restaurant *)currentRestaurant;
+ (void)setCurrentRestaurant:(Restaurant *)restaurant;

/** Callback takes an NSNumber object. */
+ (void)getNetSalesForInterval:(NSDate *)start end:(NSDate *)end callback:(ParseObjectResponseBlock)callback;
/** Callback takes an array of NSNumber objects. */
+ (void)getNetSalesForPastWeek:(NSDate *)day callback:(ParseArrayResponseBlock)callback;
/** Callback takes an array of MenuItem objects. */
+ (void)getPopularItemsForInterval:(NSDate *)start end:(NSDate *)end callback:(ParseArrayResponseBlock)callback;
/** Callback takes an array of MenuCategory objects. */
+ (void)getPopularCategoriesForInterval:(NSDate *)start end:(NSDate *)end callback:(ParseArrayResponseBlock)callback;
/** Callback takes an NSNumber object. */
+ (void)getAveragePaymentForInterval:(NSDate *)start end:(NSDate *)end callback:(ParseTwoObjectResponseBlock)callback;
/** Callback takes an NSNumber object. */
+ (void)getGuestCountForInterval:(NSDate *)start end:(NSDate *)end callback:(ParseObjectResponseBlock)callback;
/** Callback takes an NSNumber object. */
+ (void)getLaborCostForInterval:(NSDate *)start end:(NSDate *)end callback:(ParseObjectResponseBlock)callback;
/** Callback takes an array of Order objects. */
+ (void)getTransactionsForInterval:(NSDate *)start end:(NSDate *)end callback:(ParseArrayResponseBlock)callback;

/** Callback takes an array of Menu objects. */
+ (void)getMenus:(ParseArrayResponseBlock)callback;
/** Callback takes an array of MenuCategory objects. */

+ (void)getMenuCategoriesOfMenu:(Menu *)menu callback:(ParseArrayResponseBlock)callback;
/** Gets all menu categories under the current restaurant. */
+ (void)getAllMenuCategories:(ParseArrayResponseBlock)callback;

/** Callback takes an array of MenuItem objects. */
+ (void)getMenuItemsOfMenuCategory:(MenuCategory *)category callback:(ParseArrayResponseBlock)callback;
/** Gets all menu items under the current restaurant. */
+ (void)getAllMenuItems:(ParseArrayResponseBlock)callback;

/** Gets all menu item modifiers under the current restaurant. Callback takes an array of MenuItem objects. */
+ (void)getAllMenuItemModifiers:(ParseArrayResponseBlock)callback;



// I wrote everything above this line, except CommsDelegate —Tanner //


+ (void)emailLogin:(id<CommsDelegate>)delegate userInfo:(NSDictionary *)userInfo;

// Get Business Menus
+ (void)getBusinessMenus:(id<CommsDelegate>)delegate menuType:(NSString *)menuType topKey:(NSString *)topKey topObject:(PFObject *)topObject;
+ (void)getBusinessMenuInfo:(id<CommsDelegate>)delegate menuType:(NSString *)menuType MenuId:(NSString *)menuId;
+ (void)getMenuItemsOfModifier:(id<CommsDelegate>)delegate modifierect:(PFObject *)modifierect;

// Add, Update Business Menus
+ (void)updateQuoteRequest:(id<CommsDelegate>)delegate Quote:(PFObject *)quote;

// delete business menus
+ (void)deleteQuoteRequest:(id<CommsDelegate>)delegate Quote:(PFObject *)quote;

// Get Analytics

+ (void)getAnalyticsSalesView:(id<CommsDelegate>)delegate startDate:(NSDate *)startDate endDate:(NSDate *)endDate;

+ (void)getAnalyticsCategorySales:(id<CommsDelegate>)delegate startDate:(NSDate *)startDate endDate:(NSDate *)endDate;

+ (void)getAnalyticsEmployeeShifts:(id<CommsDelegate>)delegate startDate:(NSDate *)startDate endDate:(NSDate *)endDate;

+ (void)getAnalyticsPayroll:(id<CommsDelegate>)delegate startDate:(NSDate *)startDate endDate:(NSDate *)endDate;

+ (void)getAnalyticsOrderReport:(id<CommsDelegate>)delegate startDate:(NSDate *)startDate endDate:(NSDate *)endDate;

+ (void)getAnalyticsModifierSales:(id<CommsDelegate>)delegate startDate:(NSDate *)startDate endDate:(NSDate *)endDate;

+ (void)sendEmailwithMailGun:(id<CommsDelegate>)delegate userEmail:(NSString *)userEmail emailSubject:(NSString *)emailSubject emailContent:(NSString *)emailContent;

@end
