//
//  AWCountryListViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/19.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWCountryListViewController.h"
#import "AWCountry.h"
#import "AWUtils.h"

@interface AWCountryListViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray <AWCountry *> *countries;
@property (strong, nonatomic) NSArray <AWCountry *> *matchedCountries;

@end

@implementation AWCountryListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.countries = [AWCountry allCountries];
    self.matchedCountries = self.countries;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.matchedCountries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CountryCell" forIndexPath:indexPath];
    AWCountry *country = self.matchedCountries[indexPath.row];
    cell.textLabel.text = country.countryName;
    if ([self.country.countryName isEqualToString:country.countryName]) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tick" inBundle:[NSBundle resourceBundle]]];
        cell.accessoryView = imageView;
    } else {
        cell.accessoryView = nil;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(countryListViewController:didSelectCountry:)]) {
        self.country = self.matchedCountries[indexPath.row];
        [self.delegate countryListViewController:self didSelectCountry:self.country];
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length > 0) {
        self.matchedCountries = [self.countries filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            AWCountry *obj = (AWCountry *)evaluatedObject;
            return [obj.countryName rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound;
        }]];
    } else {
        self.matchedCountries = self.countries;
    }
    [self.tableView reloadData];
}

@end
