//
//  GuestsTransactionLaborCell.h
//  EntreeManage
//
//  Created by Tanner on 8/8/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuestsTransactionLaborCell : UICollectionViewCell

@property (nonatomic) NSInteger guestCount;
@property (nonatomic) NSInteger transactionCount;
@property (nonatomic) CGFloat   laborCostPercentage;
@property (nonatomic) CGFloat   laborCost;

- (void)showLaborCostPercentage;
- (void)hideLaborCostPercentage;


@end
