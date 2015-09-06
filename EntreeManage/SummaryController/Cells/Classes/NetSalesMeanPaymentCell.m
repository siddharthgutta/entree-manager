//
//  NetSalesMeanPaymentCell.m
//  EntreeManage
//
//  Created by Tanner on 8/8/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "NetSalesMeanPaymentCell.h"
#import "global.h"
#import "NSNumberFormatter+Dollars.h"

#pragma mark Private
@interface NetSalesMeanPaymentCell ()

@property (nonatomic, weak) IBOutlet UILabel *netSalesLabel;
@property (nonatomic, weak) IBOutlet UILabel *percentUpLabel;
@property (nonatomic, weak) IBOutlet UILabel *averagePaymentLabel;

@property (nonatomic, weak) IBOutlet UIView  *netSalesView;
@property (nonatomic, weak) IBOutlet UIView  *averagePaymentView;

@end

@implementation NetSalesMeanPaymentCell

#pragma mark Initialization

- (void)awakeFromNib {
    self.netSalesView.layer.cornerRadius       = kSummaryViewCornerRadius;
    self.averagePaymentView.layer.cornerRadius = kSummaryViewCornerRadius;
    
    self.netSales       = 0;
    self.percentUp      = 0;
    self.averagePayment = 0;
    self.numberOfDays   = 1;
}

#pragma mark Setters

- (void)setNetSales:(CGFloat)netSales {
    _netSales = netSales;
    self.netSalesLabel.text = [[NSNumberFormatter dollarFormatter] stringFromNumber:@(netSales)];
}

- (void)setPercentUp:(CGFloat)percentUp {
    _percentUp = percentUp;
    if (self.numberOfDays == 1)
        self.percentUpLabel.text = [NSString stringWithFormat:@"%.02f%% up from yesterday", self.percentUp];
    else
        self.percentUpLabel.text = [NSString stringWithFormat:@"%.02f%% up from previous %ld days", self.percentUp, (long)self.numberOfDays];
}

- (void)setNumberOfDays:(NSInteger)numberOfDays {
    _numberOfDays = numberOfDays;
    if (self.numberOfDays == 1)
        self.percentUpLabel.text = [NSString stringWithFormat:@"%.02f%% up from yesterday", self.percentUp];
    else
        self.percentUpLabel.text = [NSString stringWithFormat:@"%.02f%% up from previous %ld days", self.percentUp, (long)self.numberOfDays];
}


- (void)setAveragePayment:(CGFloat)averagePayment {
    _averagePayment = averagePayment;
    self.averagePaymentLabel.text = [[NSNumberFormatter dollarFormatter] stringFromNumber:@(averagePayment)];
}

@end
