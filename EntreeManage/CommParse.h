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
- (void)commsDidAction:(NSDictionary *)response;
@end


@interface CommParse : NSObject


+ (void)emailLogin:(id<CommsDelegate>)delegate userInfo:(NSDictionary *)userInfo;

// Get Business Menus
+ (void)getBusinessMenus:(id<CommsDelegate>)delegate menuType:(NSString *)menuType topKey:(NSString *)topKey topObject:(PFObject *)topObject;
+ (void)getBusinessMenuInfo:(id<CommsDelegate>)delegate menuType:(NSString *)menuType MenuId:(NSString *)menuId;
+ (void)getMenuItemsOfModifier:(id<CommsDelegate>)delegate ModifierObject:(PFObject *)modifierObject;

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
