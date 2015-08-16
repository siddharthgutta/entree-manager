//
//  CommParse.h
//  EntreeManage
//
//  Created by Faraz on 7/25/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "ProgressHUD.h"
#import "Mailgun.h"


@protocol CommsDelegate <NSObject>
@optional
- (void)commsDidAction:(NSDictionary *)response;

@end


@interface CommParse : NSObject


+ (void)emailLogin:(id<CommsDelegate>)delegate UserInfo:(NSDictionary *)userInfo;

// Get Business Menus
+ (void)getBusinessMenus:(id<CommsDelegate>) delegate MenuType:(NSString*) menu_type TopKey:(NSString*)topKey TopObject:(PFObject*)topObject;
+ (void)getBusinessMenuInfo:(id<CommsDelegate>)delegate MenuType:(NSString*) menu_type MenuId:(NSString*) menu_id;
+ (void)getMenuItemsOfModifier:(id<CommsDelegate>) delegate ModifierObject:(PFObject*)modifierObject;

// Add, Update Business Menus
+ (void)updateQuoteRequest:(id<CommsDelegate>)delegate Quote:(PFObject *)quote;

// delete business menus
+ (void)deleteQuoteRequest:(id<CommsDelegate>)delegate Quote:(PFObject *)quote;

// Get Analytics

+ (void)getAnalyticsSalesView:(id<CommsDelegate>)delegate StartDate:(NSDate*) startDate EndDate:(NSDate*) endDate;

+ (void)getAnalyticsCategorySales:(id<CommsDelegate>)delegate StartDate:(NSDate*) startDate EndDate:(NSDate*) endDate;

+ (void)getAnalyticsEmployeeShifts:(id<CommsDelegate>)delegate StartDate:(NSDate*) startDate EndDate:(NSDate*) endDate;

+ (void)getAnalyticsPayroll:(id<CommsDelegate>)delegate StartDate:(NSDate*) startDate EndDate:(NSDate*) endDate;

+ (void)getAnalyticsOrderReport:(id<CommsDelegate>)delegate StartDate:(NSDate*) startDate EndDate:(NSDate*) endDate;

+ (void)getAnalyticsModifierSales:(id<CommsDelegate>)delegate StartDate:(NSDate*) startDate EndDate:(NSDate*) endDate;

+ (void)sendEmailwithMailGun:(id<CommsDelegate>)delegate userEmail:(NSString*) userEmail EmailSubject:(NSString*) emailSubject EmailContent:(NSString*) emailContent;

@end
