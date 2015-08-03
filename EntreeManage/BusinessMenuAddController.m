//
//  BusinessMenuAddController.m
//  EntreeManage
//
//  Created by Faraz on 7/31/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "BusinessMenuAddController.h"

@interface BusinessMenuAddController ()
- (IBAction)onClickBtnClose:(id)sender;

@end

@implementation BusinessMenuAddController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onClickBtnClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
