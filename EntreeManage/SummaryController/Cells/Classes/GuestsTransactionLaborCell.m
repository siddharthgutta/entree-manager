//
//  GuestsTransactionLaborCell.m
//  EntreeManage
//
//  Created by Tanner on 8/8/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "GuestsTransactionLaborCell.h"
#import "global.h"

@interface GuestsTransactionLaborCell ()

@property (nonatomic, weak) IBOutlet UIView *guestCountView;
@property (nonatomic, weak) IBOutlet UIView *transactionCountView;
@property (nonatomic, weak) IBOutlet UIView *laborCostView;

@property (nonatomic, weak) IBOutlet UILabel *guestCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *transactionCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *laborCostPercentageLabel;
@property (nonatomic, weak) IBOutlet UILabel *laborCostLabel;

@end

@implementation GuestsTransactionLaborCell

- (void)awakeFromNib {
    self.guestCountView.layer.cornerRadius       = kSummaryViewCornerRadius;
    self.transactionCountView.layer.cornerRadius = kSummaryViewCornerRadius;
    self.laborCostView.layer.cornerRadius        = kSummaryViewCornerRadius;
}

- (void)setGuestCount:(NSInteger)guestCount {
    _guestCount = guestCount;
    self.guestCountLabel.text = [NSString stringWithFormat:@"%ld", (long)guestCount];
}

- (void)setTransactionCount:(NSInteger)transactionCount {
    _transactionCount = transactionCount;
    self.transactionCountLabel.text = [NSString stringWithFormat:@"%ld", (long)transactionCount];
}

- (void)setLaborCostPercentage:(CGFloat)laborCostPercentage {
    if (laborCostPercentage != laborCostPercentage) laborCostPercentage = 0;
    laborCostPercentage = MIN(100, laborCostPercentage);
    _laborCostPercentage = laborCostPercentage;
    self.laborCostPercentageLabel.text = [NSString stringWithFormat:@"%.2f%%", laborCostPercentage];
}

- (void)setLaborCost:(CGFloat)laborCost {
    if (laborCost != laborCost) laborCost = 0;
    _laborCost = laborCost;
    self.laborCostLabel.text = [NSString stringWithFormat:@"$%.2f", laborCost];
}

- (void)showLaborCostPercentage {
    self.laborCostPercentageLabel.hidden = NO;
}

- (void)hideLaborCostPercentage {
    self.laborCostPercentageLabel.hidden = YES;
}

@end
