//
//  MostPopularPieChartCell.h
//  EntreeManage
//
//  Created by Tanner on 8/8/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARPieChart.h"

@interface MostPopularPieChartCell : UICollectionViewCell <ARPieChartDataSource>
@property (nonatomic, weak) IBOutlet ARPieChart *chart;
@property (nonatomic      ) NSArray *graphPlotPoints;
@end
