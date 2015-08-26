//
//  SummaryViewController.m
//  EntreeManage
//
//  Created by Tanner on 8/5/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "SummaryViewController.h"
#import "PopularItemCell.h"
#import "global.h"

static NSString *const reuseIdentifier = @"Cell";

typedef NS_ENUM(NSInteger, SummaryView) {
    SummaryViewNetSalesGraph,
    SummaryViewNetSalesAveragePayment,
    SummaryViewPieChart,
    SummaryViewMostPopular,
    SummaryViewGuestCountTransactionsCountLaborCost,
};

NSString *StringFromSummaryView(SummaryView sv) {
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
@interface SummaryViewController () <UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate>;
@property (nonatomic) UITableView *tableView;
@end

@implementation SummaryViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Summary";
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.scrollEnabled   = NO;
    
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
    
    // Only needs to run once
    if (indexPath.row == SummaryViewMostPopular) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            self.tableView = [(id)cell tableView];
            self.tableView.delegate      = self;
            self.tableView.dataSource    = self;
            self.tableView.rowHeight     = 40.5;
            self.tableView.scrollEnabled = NO;
            [self.tableView registerNib:[UINib nibWithNibName:krSummaryPopularItemCell bundle:nil] forCellReuseIdentifier:krSummaryPopularItemCell];
        });
    }
    
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

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PopularItemCell *cell = (id)[self.tableView dequeueReusableCellWithIdentifier:krSummaryPopularItemCell];
    cell.titleLabel.text = @"Fooo";
    cell.index = indexPath.row;
    cell.saleCount = arc4random_uniform(100);
    cell.saleRevenue = (CGFloat)arc4random_uniform(100);
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

@end
