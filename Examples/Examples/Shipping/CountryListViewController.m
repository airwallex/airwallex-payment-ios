//
//  CountryListViewController.m
//  Examples
//
//  Created by Victor Zhu on 2020/1/19.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "CountryListViewController.h"

@interface CountryListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *countries;

@end

@implementation CountryListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLocale *locale = [NSLocale currentLocale];
    NSArray *isoCountryCodes = [NSLocale ISOCountryCodes];
    NSMutableArray *countries = [[NSMutableArray alloc] init];
    for (NSString *countryCode in isoCountryCodes) {
        NSString *countryName = [locale displayNameForKey:NSLocaleCountryCode value:countryCode];
        Country *country = [Country new];
        country.countryCode = countryCode;
        country.countryName = countryName;
        [countries addObject:country];
    }
    [countries sortUsingComparator:^NSComparisonResult(Country * _Nonnull obj1, Country * _Nonnull obj2) {
        return [obj1.countryName localizedCompare:obj2.countryName];
    }];
    self.countries = countries;
}

- (IBAction)closePressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.countries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CountryCell" forIndexPath:indexPath];
    Country *country = self.countries[indexPath.row];
    cell.textLabel.text = country.countryName;
    if ([self.country.countryName isEqualToString:country.countryName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(countryListViewController:didSelectCountry:)]) {
        Country *country = self.countries[indexPath.row];
        [self.delegate countryListViewController:self didSelectCountry:country];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
