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
@property (nonatomic, weak) IBOutlet UILabel *percentUpFromDayLabel;
@property (nonatomic, weak) IBOutlet UILabel *percentUpFromWeekLabel;
@property (nonatomic, weak) IBOutlet UILabel *percentUpFromMonthLabel;
@property (nonatomic, weak) IBOutlet UILabel *averagePaymentLabel;

@property (nonatomic, weak) IBOutlet UIView  *netSalesView;
@property (nonatomic, weak) IBOutlet UIView  *averagePaymentView;

@end

@implementation NetSalesMeanPaymentCell

#pragma mark Initialization

- (void)awakeFromNib {
    self.netSalesView.layer.cornerRadius       = kSummaryViewCornerRadius;
    self.averagePaymentView.layer.cornerRadius = kSummaryViewCornerRadius;
    
    self.netSales           = 0;
    self.percentUpFromDay   = 0;
    self.percentUpFromWeek  = 0;
    self.percentUpFromMonth = 0;
    self.averagePayment     = 0;
}

#pragma mark Setters

- (void)setNetSales:(CGFloat)netSales {
    _netSales = netSales;
    self.netSalesLabel.text = [[NSNumberFormatter dollarFormatter] stringFromNumber:@(netSales)];
}

- (void)setPercentUpFromDay:(CGFloat)percentUpFromDay {
    _percentUpFromDay = percentUpFromDay;
    self.percentUpFromDayLabel.text = [NSString stringWithFormat:@"%f%% up from yesterday", percentUpFromDay];
}

- (void)setPercentUpFromWeek:(CGFloat)percentUpFromWeek {
    _percentUpFromWeek = percentUpFromWeek;
    self.percentUpFromWeekLabel.text = [NSString stringWithFormat:@"%f%% up from last week", percentUpFromWeek];
}

- (void)setPercentUpFromMonth:(CGFloat)percentUpFromMonth {
    _percentUpFromMonth = percentUpFromMonth;
    self.percentUpFromMonthLabel.text = [NSString stringWithFormat:@"%f%% up from last month", percentUpFromMonth];
}

- (void)setAveragePayment:(CGFloat)averagePayment {
    _averagePayment = averagePayment;
    self.averagePaymentLabel.text = [[NSNumberFormatter dollarFormatter] stringFromNumber:@(averagePayment)];
}

@end
