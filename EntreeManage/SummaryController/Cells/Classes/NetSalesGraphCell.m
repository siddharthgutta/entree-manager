//
//  NetSalesGraphCell.m
//  EntreeManage
//
//  Created by Tanner on 8/8/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "NetSalesGraphCell.h"
#import "global.h"

@implementation NetSalesGraphCell

- (void)awakeFromNib {
    self.graph.normalizeXValues   = YES;
    self.graph.showMeanLine       = YES;
    self.graph.showMinMaxLines    = YES;
    self.graph.showDots           = YES;
    self.graph.showXLegend        = YES;
    self.graph.showYLegend        = YES;
    self.graph.tintColor          = [UIColor colorWithRed:0.383 green:0.780 blue:0.876 alpha:1.000];
    self.graph.shouldSmooth       = YES;
    self.graph.showXLegendValues  = YES;
    self.graph.layer.cornerRadius = kSummaryViewCornerRadius;
    self.graph.clipsToBounds      = YES;
    [self.graph beginAnimationIn];
}

@end
