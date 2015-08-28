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
    // Do any additional setup after loading the view.
        
    [self showAnalyticsPage:@"segueAnalyticsSalesSummary"];
    self.navigationItem.hidesBackButton = YES;
}




// show Pages func when onclick Left Menu
- (void)showAnalyticsPage:(NSString *)segueId {
    [self performSegueWithIdentifier:segueId sender:self];
}

@end
