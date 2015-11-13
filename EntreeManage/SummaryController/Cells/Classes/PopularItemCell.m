//
//  PopularItemCell.m
//  EntreeManage
//
//  Created by Tanner on 8/8/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "PopularItemCell.h"
#import "NSNumberFormatter+Dollars.h"

#pragma mark Private
@interface PopularItemCell ()

@property (nonatomic, weak) IBOutlet UILabel *indexLabel;
@property (nonatomic, weak) IBOutlet UILabel *saleCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *saleRevenueLabel;

@end


@implementation PopularItemCell

#pragma mark Initialization

- (void)awakeFromNib {
    self.backgroundColor = [UIColor clearColor];
    self.separatorInset = UIEdgeInsetsZero;
    self.preservesSuperviewLayoutMargins = NO;
    self.layoutMargins = UIEdgeInsetsZero;
}

#pragma mark Setters

- (void)setIndex:(NSUInteger)index {
    _index = index;
    self.indexLabel.text = [NSString stringWithFormat:@"%lu.", (unsigned long)index];
}

- (void)setSaleCount:(NSInteger)saleCount {
    _saleCount = saleCount;
    self.saleCountLabel.text = @(saleCount).stringValue;
}

- (void)setSaleRevenue:(CGFloat)saleRevenue {
    _saleRevenue = saleRevenue;
    self.saleRevenueLabel.text = [[NSNumberFormatter dollarFormatter] stringFromNumber:@(saleRevenue)];
}

@end
