//
//  NetSalesGraphCell.h
//  EntreeManage
//
//  Created by Tanner on 8/8/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARLineGraph.h"

@interface NetSalesGraphCell : UICollectionViewCell <ARLineGraphDataSource>

@property (nonatomic, weak) IBOutlet ARLineGraph *graph;

/** An array of ARGraphDataPoint objects. */
@property (nonatomic      ) NSArray *graphPlotPoints;

@end
