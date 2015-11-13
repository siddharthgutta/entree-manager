//
//  AnalyticsViewController.m
//  EntreeManage
//
//  Created by Faraz on 7/27/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "AnalyticsViewController.h"

@interface AnalyticsViewController ()

@end

@implementation AnalyticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
<<<<<<< HEAD
    // Do any additional setup after loading the view.
=======
>>>>>>> origin/tanner
        
    [self showAnalyticsPage:@"segueAnalyticsSalesSummary"];
    self.navigationItem.hidesBackButton = YES;
}




// show Pages func when onclick Left Menu
<<<<<<< HEAD
-(void)showAnalyticsPage:(NSString*)segueId{
=======
- (void)showAnalyticsPage:(NSString *)segueId {
>>>>>>> origin/tanner
    [self performSegueWithIdentifier:segueId sender:self];
}

@end
