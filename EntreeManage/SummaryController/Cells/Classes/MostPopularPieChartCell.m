//
//  MostPopularPieChartCell.m
//  EntreeManage
//
//  Created by Tanner on 8/8/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "MostPopularPieChartCell.h"

@implementation MostPopularPieChartCell

- (void)awakeFromNib {
    self.chart.tintColor          = [UIColor colorWithRed:0.386 green:0.867 blue:0.973 alpha:1.000];
    self.layer.cornerRadius = kSummaryViewCornerRadius;
    self.chart.clipsToBounds      = YES;
    
    self.chart.dataSource         = self;
    [self.chart beginAnimationIn];
    NSInteger perPopData = 10;
    
    NSMutableArray *points = [NSMutableArray array];
    while (perPopData--) {
        [points addObject:[[ARGraphDataPoint alloc] initWithX:100 - perPopData y:100 + arc4random()%100]];
    }
    self.graphPlotPoints = points;
    
    [self.chart beginAnimationIn];
}

- (NSArray *)ARPieChartDataPoints:(ARPieChart *)graph {
    return self.graphPlotPoints;
}

- (NSString *)titleForPieChart:(ARPieChart *)chart {
    return @"Most Popular Categories by Sales";
}

- (UIColor *)ARPieChart:(ARPieChart *)chart colorForSliceAtIndex:(NSUInteger)index {
    CGFloat hue = ( arc4random() % 256 / 256.0 );
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

@end
