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


// Add Business Menus
+ (void)addBusinessMenu:(id<CommsDelegate>)delegate MenuType:(NSString*) menu_type MenuInfo:(NSDictionary *)menuInfo ;

// Update Business Menus
+ (void)updateBusinessMenu:(id<CommsDelegate>)delegate MenuType:(NSString*) menu_type MenuInfo:(NSDictionary *)menuInfo;


// Get Business Employee
+ (void)getBusinessEmployees:(id<CommsDelegate>)delegate;
+ (void)getBusinessEmployeeInfo:(id<CommsDelegate>)delegate EmployeeId:(NSString*) employee_id;
// Add, Update Business Employee
+ (void)addBusinessEmployee:(id<CommsDelegate>)delegate EmployeeInfo:(NSDictionary *)employeeInfo;
+ (void)updateBusinessEmployee:(id<CommsDelegate>)delegate EmployeeInfo:(NSDictionary *)employeeInfo;


// Get Analytics
//+ (void)getAnalyticsSales:(id<CommsDelegate>)delegate;
//+ (void)getAnalyticsCategorySales:(id<CommsDelegate>)delegate;
//+ (void)getAnalyticsEmployeeShifts:(id<CommsDelegate>)delegate;



@end
