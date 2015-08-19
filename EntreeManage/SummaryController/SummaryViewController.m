//
//  SummaryViewController.m
//  EntreeManage
//
//  Created by Tanner on 8/5/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "SummaryViewController.h"
#import "global.h"

static NSString * const reuseIdentifier = @"Cell";

typedef NS_ENUM(NSInteger, SummaryView) {
    SummaryViewNetSalesGraph,
    SummaryViewNetSalesAveragePayment,
    SummaryViewPieChart,
    SummaryViewMostPopular,
    SummaryViewGuestCountTransactionsCountLaborCost,
};

NSString * StringFromSummaryView(SummaryView sv) {
    switch (sv) {
        case SummaryViewNetSalesGraph: {
            return krSummaryNetSalesGraphCell;
        }
        case SummaryViewNetSalesAveragePayment: {
            return krSummaryNetSalesMeanPaymentCell;
        }
        case SummaryViewPieChart: {
            return krSummaryMostPopularPieChartCell;
        }
        case SummaryViewMostPopular: {
            return krSummaryMostPopularTableCell;
        }
        case SummaryViewGuestCountTransactionsCountLaborCost: {
            return krSummaryGuestsTransactionLaborCell;
        }
    }
    
    return reuseIdentifier;
}



#define kSectionInset 34


#pragma mark - SummaryViewController -
@interface SummaryViewController () <UICollectionViewDelegateFlowLayout>
@end

@implementation SummaryViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Summary";
    self.collectionView.backgroundColor = [UIColor greenColor];
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    flowLayout.sectionInset       = UIEdgeInsetsMake(kSectionInset, kSectionInset, kSectionInset, kSectionInset);
    flowLayout.minimumLineSpacing = 24;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:krSummaryGuestsTransactionLaborCell bundle:nil] forCellWithReuseIdentifier:krSummaryGuestsTransactionLaborCell];
    [self.collectionView registerNib:[UINib nibWithNibName:krSummaryMostPopularPieChartCell bundle:nil] forCellWithReuseIdentifier:krSummaryMostPopularPieChartCell];
    [self.collectionView registerNib:[UINib nibWithNibName:krSummaryMostPopularTableCell bundle:nil] forCellWithReuseIdentifier:krSummaryMostPopularTableCell];
    [self.collectionView registerNib:[UINib nibWithNibName:krSummaryNetSalesGraphCell bundle:nil] forCellWithReuseIdentifier:krSummaryNetSalesGraphCell];
    [self.collectionView registerNib:[UINib nibWithNibName:krSummaryNetSalesMeanPaymentCell bundle:nil] forCellWithReuseIdentifier:krSummaryNetSalesMeanPaymentCell];
    
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 6;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:StringFromSummaryView(indexPath.row) forIndexPath:indexPath];
//    cell.backgroundColor = [UIColor blueColor];
    return cell;
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    SummaryView idx = (SummaryView)indexPath.row;
    switch (idx) {
        case SummaryViewNetSalesGraph: {
            return CGSizeMake(632, 278);
        }
        case SummaryViewNetSalesAveragePayment: {
            return CGSizeMake(292, 278);
        }
        case SummaryViewPieChart: {
            return CGSizeMake(374, 278);
        }
        case SummaryViewMostPopular: {
            return CGSizeMake(232, 278);
        }
        case SummaryViewGuestCountTransactionsCountLaborCost: {
            return CGSizeMake(292, 278);
        }
        default:
            return CGSizeMake([UIScreen mainScreen].bounds.size.width - 2*kSectionInset, 0);
    }
}

@end
