//
//  CommParse.h
//  EntreeManage
//
//  Created by Faraz on 7/25/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "global.h"
#import "ProgressHUD.h"

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
//+ (void)getAnalyticsSales:(id<CommsDelegate>)delegate;
//+ (void)getAnalyticsCategorySales:(id<CommsDelegate>)delegate;
//+ (void)getAnalyticsEmployeeShifts:(id<CommsDelegate>)delegate;



@end
