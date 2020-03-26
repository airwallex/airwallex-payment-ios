//
//  AWCountryListViewController.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/19.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWViewController.h"

@class AWCountry, AWCountryListViewController;

NS_ASSUME_NONNULL_BEGIN

/**
 A delegate which handles selected country.
 */
@protocol AWCountryListViewControllerDelegate <NSObject>

/**
 This method is called when a country has been selected.
 
 @param controller The country list view controller.
 @param country The selected country.
 */
- (void)countryListViewController:(AWCountryListViewController *)controller didSelectCountry:(AWCountry *)country;

@end

/**
 `AWCountryListViewController` includes a list of countries.
 */
@interface AWCountryListViewController : AWViewController

/**
 A delegate which handles country selection events.
 */
@property (nonatomic, weak) id <AWCountryListViewControllerDelegate> delegate;

/**
 A country has been selected.
 */
@property (nonatomic, strong, nullable) AWCountry *country;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
