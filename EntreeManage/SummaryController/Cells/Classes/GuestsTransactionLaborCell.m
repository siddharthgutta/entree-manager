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

@end

@implementation GuestsTransactionLaborCell

- (void)awakeFromNib {
    self.guestCountView.layer.cornerRadius       = kSummaryViewCornerRadius;
    self.transactionCountView.layer.cornerRadius = kSummaryViewCornerRadius;
    self.laborCostView.layer.cornerRadius        = kSummaryViewCornerRadius;
}

@end
