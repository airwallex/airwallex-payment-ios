//
//  AWCountryListViewController.m
//  Examples
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
@property (nonatomic, strong) NSArray *countries;
@property (nonatomic, strong) NSArray *matchedCountries;

@end

@implementation AWCountryListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLocale *locale = [NSLocale currentLocale];
    NSArray *isoCountryCodes = [NSLocale ISOCountryCodes];
    NSMutableArray *countries = [[NSMutableArray alloc] init];
    for (NSString *countryCode in isoCountryCodes) {
        NSString *countryName = [locale displayNameForKey:NSLocaleCountryCode value:countryCode];
        AWCountry *country = [AWCountry new];
        country.countryCode = countryCode;
        country.countryName = countryName;
        [countries addObject:country];
    }
    [countries sortUsingComparator:^NSComparisonResult(AWCountry * _Nonnull obj1, AWCountry * _Nonnull obj2) {
        return [obj1.countryName localizedCompare:obj2.countryName];
    }];
    self.countries = countries;
    self.matchedCountries = countries;
}

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
        AWCountry *country = self.matchedCountries[indexPath.row];
        [self.delegate countryListViewController:self didSelectCountry:country];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.matchedCountries = [self.countries filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        AWCountry *obj = (AWCountry *)evaluatedObject;
        return [obj.countryName rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound;
    }]];
    [self.tableView reloadData];
}

@end
