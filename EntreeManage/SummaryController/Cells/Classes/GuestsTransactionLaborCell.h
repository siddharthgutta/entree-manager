//
//  GuestsTransactionLaborCell.h
//  EntreeManage
//
//  Created by Tanner on 8/8/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuestsTransactionLaborCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *guestCount;
@property (nonatomic, weak) IBOutlet UILabel *transactionCount;
@property (nonatomic, weak) IBOutlet UILabel *laborCostPercentage;

@end
