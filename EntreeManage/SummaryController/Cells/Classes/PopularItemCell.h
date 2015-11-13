//
//  PopularItemCell.h
//  EntreeManage
//
//  Created by Tanner on 8/8/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopularItemCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic      ) NSUInteger index;
@property (nonatomic      ) NSInteger  saleCount;
@property (nonatomic      ) CGFloat    saleRevenue;

@end
