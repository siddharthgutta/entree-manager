//
//  MostPopularTableCell.h
//  EntreeManage
//
//  Created by Tanner on 8/8/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MostPopularTableCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic      )          NSArray     *dataSource;

@end
