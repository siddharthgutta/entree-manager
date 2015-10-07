//
//  SummaryViewController.m
//  EntreeManage
//
//  Created by Tanner on 8/5/15.
//  Copyright (c) 2015 Faraz. All rights reserved.
//

#import "SummaryViewController.h"
#import "global.h"

#import "NetSalesGraphCell.h"
#import "NetSalesMeanPaymentCell.h"
#import "GuestsTransactionLaborCell.h"
#import "GuestsTransactionLaborCell.h"
#import "MostPopularPieChartCell.h"
#import "MostPopularTableCell.h"
#import "PopularItemCell.h"

#import "RMDateSelectionViewController.h"

static NSString *const reuseIdentifier = @"Cell";

typedef NS_ENUM(NSInteger, SummaryView) {
    SummaryViewNetSalesGraph,
    SummaryViewNetSalesAveragePayment,
    SummaryViewPieChart,
    SummaryViewMostPopular,
    SummaryViewGuestCountTransactionsCountLaborCost,
    SummaryViewNA
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
        case SummaryViewNA: {
            return reuseIdentifier;
        }
    }
    
    return reuseIdentifier;
}



#define kSectionInset 34


#pragma mark - SummaryViewController -
@interface SummaryViewController () <UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate, ARLineGraphDataSource, ARPieChartDataSource>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSArray     *netSalesGraphDataPoints;
@property (nonatomic) NSArray     *popularCategoriesDataPoints;

@property (nonatomic) CGFloat   netSales;
@property (nonatomic) CGFloat   averagePayment;
@property (nonatomic) CGFloat   laborCost;
@property (nonatomic) NSInteger guestCount;
@property (nonatomic) NSInteger transactionCount;
@property (nonatomic) NSArray   *popularItems;
@property (nonatomic) NSArray   *popularCategories;

@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSDate *endDate;
@end

@implementation SummaryViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.startDate = [NSDate date30DaysAgo];
    self.endDate = [NSDate date];
    
    self.popularItems = @[];
    self.popularCategories = @[];
    self.netSalesGraphDataPoints = @[];
    
    self.title = @"Summary";
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.scrollEnabled   = NO;
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    flowLayout.sectionInset       = UIEdgeInsetsMake(kSectionInset, kSectionInset, kSectionInset, kSectionInset);
    flowLayout.minimumLineSpacing = 24;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:krSummaryGuestsTransactionLaborCell bundle:nil] forCellWithReuseIdentifier:krSummaryGuestsTransactionLaborCell];
    [self.collectionView registerNib:[UINib nibWithNibName:krSummaryMostPopularPieChartCell    bundle:nil] forCellWithReuseIdentifier:krSummaryMostPopularPieChartCell];
    [self.collectionView registerNib:[UINib nibWithNibName:krSummaryMostPopularTableCell       bundle:nil] forCellWithReuseIdentifier:krSummaryMostPopularTableCell];
    [self.collectionView registerNib:[UINib nibWithNibName:krSummaryNetSalesGraphCell          bundle:nil] forCellWithReuseIdentifier:krSummaryNetSalesGraphCell];
    [self.collectionView registerNib:[UINib nibWithNibName:krSummaryNetSalesMeanPaymentCell    bundle:nil] forCellWithReuseIdentifier:krSummaryNetSalesMeanPaymentCell];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Date Range" style:UIBarButtonItemStylePlain target:self action:@selector(showDatePickers)];
    
    [self loadSummaryData];
}

- (void)loadSummaryData {
    [CommParse getNetSalesForInterval:self.startDate end:self.endDate callback:^(NSNumber *num, NSError *error) {
        if (!error) {
            self.netSales = num.floatValue;
            [self.collectionView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    [CommParse getNetSalesForPastWeek:self.endDate callback:^(NSArray *numbers, NSError *error) {
        if (!error) {
            NSMutableArray *points = [NSMutableArray array];
            [numbers enumerateObjectsUsingBlock:^(NSNumber *num, NSUInteger idx, BOOL *stop) {
                [points addObject:[[ARGraphDataPoint alloc] initWithX:idx y:num.floatValue]];
            }];
            self.netSalesGraphDataPoints = points.copy;
            [self.collectionView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
    [CommParse getAveragePaymentForInterval:self.startDate end:self.endDate callback:^(NSNumber *num, NSNumber *count, NSError *error) {
        if (!error) {
            self.averagePayment = num.floatValue;
            self.transactionCount = count.integerValue;
            [self.collectionView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
    [CommParse getLaborCostForInterval:self.startDate end:self.endDate callback:^(NSNumber *num, NSError *error) {
        if (!error) {
            self.laborCost = num.floatValue;
            [self.collectionView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
    [CommParse getGuestCountForInterval:self.startDate end:self.endDate callback:^(NSNumber *num, NSError *error) {
        if (!error) {
            self.guestCount = num.integerValue;
            [self.collectionView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
    [CommParse getPopularItemsForInterval:self.startDate end:self.endDate callback:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.popularItems = objects.copy;
            [self.collectionView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
    [CommParse getPopularCategoriesForInterval:self.startDate end:self.endDate callback:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.popularCategories = objects.copy;
            NSMutableArray *points = [NSMutableArray array];
            [self.popularCategories enumerateObjectsUsingBlock:^(MenuCategory *category, NSUInteger idx, BOOL *stop) {
                [points addObject:[[ARGraphDataPoint alloc] initWithX:idx y:category.saleCount]];
            }];
            self.popularCategoriesDataPoints = points;
            [self.collectionView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)showDatePickers {
    RMAction *cancelAction = [RMAction actionWithTitle:@"Cancel" style:RMActionStyleCancel andHandler:nil];
    
    RMAction *startDateAction = [RMAction actionWithTitle:@"Next date" style:RMActionStyleDone andHandler:^(RMActionController *start) {
    
        RMAction *endDateAction = [RMAction actionWithTitle:@"Done" style:RMActionStyleDone andHandler:^(RMActionController *end) {
            self.startDate = [(RMDateSelectionViewController *)start datePicker].date;
            self.endDate = [(RMDateSelectionViewController *)end datePicker].date;
            [self loadSummaryData];
        }];
        
        RMDateSelectionViewController *secondPicker = [RMDateSelectionViewController actionControllerWithStyle:0 selectAction:endDateAction andCancelAction:cancelAction];
        secondPicker.title   = @"Date picker";
        secondPicker.message = @"Pick the ending date.";
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController.tabBarController presentViewController:secondPicker animated:YES completion:nil];
        });
    }];
    
    RMDateSelectionViewController *firstPicker = [RMDateSelectionViewController actionControllerWithStyle:0 selectAction:startDateAction andCancelAction:cancelAction];
    firstPicker.title   = @"Date picker";
    firstPicker.message = @"Pick the starting date.";
    
    [self.navigationController.tabBarController presentViewController:firstPicker animated:YES completion:nil];
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 6;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:StringFromSummaryView(indexPath.row) forIndexPath:indexPath];
    
    SummaryView sv = indexPath.row;
    switch (sv) {
        case SummaryViewNetSalesGraph: {
            [(NetSalesGraphCell *)cell graph].dataSource = self;
            [[(NetSalesGraphCell *)cell graph] reloadData];
            break;
        }
        case SummaryViewNetSalesAveragePayment: {
            [(NetSalesMeanPaymentCell *)cell setNetSales:self.netSales];
            [(NetSalesMeanPaymentCell *)cell setAveragePayment:self.averagePayment];
            break;
        }
        case SummaryViewPieChart: {
            [(MostPopularPieChartCell *)cell chart].dataSource = self;
            [[(MostPopularPieChartCell *)cell chart] beginAnimationIn];
            break;
        }
        case SummaryViewMostPopular: {
            // Only needs to run once, not sure how else
            // to get a reference to this tableView
            // until the big rewrite
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                self.tableView = [(id)cell tableView];
                self.tableView.delegate       = self;
                self.tableView.dataSource     = self;
                self.tableView.rowHeight      = 41;
                self.tableView.separatorInset = UIEdgeInsetsZero;
                self.tableView.preservesSuperviewLayoutMargins = NO;
                self.tableView.layoutMargins = UIEdgeInsetsZero;
                [self.tableView registerNib:[UINib nibWithNibName:krSummaryPopularItemCell bundle:nil] forCellReuseIdentifier:krSummaryPopularItemCell];
            });
            [self.tableView reloadData];
            break;
        }
        case SummaryViewGuestCountTransactionsCountLaborCost: {
            GuestsTransactionLaborCell *gtlcell = (id)cell;
            gtlcell.guestCount = self.guestCount;
            gtlcell.transactionCount = self.transactionCount;
            gtlcell.laborCostPercentage = self.laborCost/self.netSales;
            gtlcell.laborCost = self.laborCost;
            
            if (self.netSales == 0.f)
                [gtlcell hideLaborCostPercentage];
            else
                [gtlcell showLaborCostPercentage];
            break;
        }
        case SummaryViewNA: {
            break;
        }
    }
    
    return cell;
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
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
    MenuItem *item        = self.popularItems[indexPath.row];
    cell.titleLabel.text  = item.name;
    cell.index            = indexPath.row+1;
    cell.saleCount        = item.saleCount;
    cell.saleRevenue      = item.netSales;
    cell.separatorInset = UIEdgeInsetsZero;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MIN(6, self.popularItems.count); // 5 items at most, table isn't scrollable
}

#pragma mark ARLineGraphDataSource

- (NSArray *)ARGraphDataPoints:(ARLineGraph *)graph {
    return self.netSalesGraphDataPoints;
}

- (NSString *)titleForGraph:(ARLineGraph *)graph {
    return @"Net Sales over Time";
}

- (NSString *)ARGraphTitleForXAxis:(ARLineGraph *)graph {
    return @"By day";
}

- (NSString *)ARGraphTitleForYAxis:(ARLineGraph *)graph {
    return @"Dollar amount";
}

#pragma mark ARPieChartDataSource

- (NSArray *)ARPieChartDataPoints:(ARLineGraph *)graph {
    return self.popularCategoriesDataPoints;
}

- (NSString *)titleForPieChart:(ARPieChart *)chart {
    return @"Most Popular Categories by Sales";
}

- (NSString *)ARPieChart:(ARPieChart *)chart titleForPieIndex:(NSUInteger)index {
    MenuCategory *mc = self.popularCategories[index];
    return mc.name;
}

- (UIColor *)ARPieChart:(ARPieChart *)chart colorForSliceAtIndex:(NSUInteger)index {
    switch (index) {
        case 0:
            return [UIColor colorWithRed:0.969 green:0.129 blue:0.263 alpha:1.000];
        case 1:
            return [UIColor colorWithRed:0.275 green:0.878 blue:0.710 alpha:1.000];
        case 2:
            return [UIColor colorWithRed:0.996 green:0.961 blue:0.329 alpha:1.000];
        case 3:
            return [UIColor colorWithRed:0.243 green:0.835 blue:0.996 alpha:1.000];
            
        default:
            return [UIColor blackColor];
            break;
    }
}

@end
















