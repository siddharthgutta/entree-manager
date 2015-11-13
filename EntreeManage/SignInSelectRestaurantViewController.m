
#import "SignInSelectRestaurantViewController.h"
#import "AppDelegate.h"
#import "SummaryViewController.h"
#import "CommParse.h"

@interface SignInSelectRestaurantViewController ()

@property (copy) NSArray<Restaurant *> *restaurants;

- (void)doFarazsBadThings;
- (void)fetchData;

@end

@implementation SignInSelectRestaurantViewController

#pragma mark - SignInSelectRestaurantViewController

- (void)doFarazsBadThings {
    UITabBarController *tab = [[UITabBarController alloc] init];
    UINavigationController *summary = [[UIStoryboard storyboardWithName:@"Summary" bundle:nil]  instantiateViewControllerWithIdentifier:@"NavigationController"];
    UISplitViewController *business = [[UIStoryboard storyboardWithName:@"Business" bundle:nil]  instantiateViewControllerWithIdentifier:@"SplitBusinessController"];
    UISplitViewController *analytics = [[UIStoryboard storyboardWithName:@"Analytics" bundle:nil]  instantiateViewControllerWithIdentifier:@"SplitAnalyticsController"];
    UIViewController *settings = [[UIStoryboard storyboardWithName:@"Settings" bundle:nil]  instantiateViewControllerWithIdentifier:@"SettingsController"];
    
    [summary pushViewController:[[SummaryViewController alloc] initWithCollectionViewLayout:[UICollectionViewFlowLayout new]] animated:NO];
    
    NSArray *controllers = @[summary, business, analytics, settings]; // navController,
    tab.viewControllers = controllers;
    
    NSArray *unfilledNames = @[@"Summary", @"Business", @"Analytics", @"Settings"];
    NSArray *filledNames   = @[@"Summary-Fill", @"Business-Fill", @"Analytics-Fill", @"Settings-Fill"];
    
    NSInteger i = 0;
    for (UITabBarItem *item in tab.tabBar.items) {
        item.image = [UIImage imageNamed:unfilledNames[i]];
        item.selectedImage = [UIImage imageNamed:filledNames[i++]];
    }
    
    AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    delegate.window.rootViewController = tab;
}

- (void)fetchData {
    PFRelation *relation = [[PFUser currentUser] relationForKey:@"restaurants"];
    relation.targetClass = [Restaurant parseClassName];
    PFQuery *query = [relation query];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects) {
            self.restaurants = objects;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        } else {
            NSLog(@"%@", error);
        }
    }];
}

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self fetchData];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RestaurantCell" forIndexPath:indexPath];
    
    Restaurant *restaurant = self.restaurants[indexPath.row];
    
    cell.textLabel.text = restaurant[@"name"];
    cell.detailTextLabel.text = restaurant[@"location"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Restaurant *restaurant = self.restaurants[indexPath.row];
    
    [CommParse setCurrentRestaurant:restaurant];
    [[NSUserDefaults standardUserDefaults] setObject:restaurant.objectId forKey:@"restaurant_object_id"];
    
    [self doFarazsBadThings];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.restaurants.count;
}

@end
