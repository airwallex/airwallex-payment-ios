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

@protocol AWCountryListViewControllerDelegate <NSObject>

- (void)countryListViewController:(AWCountryListViewController *)controller didSelectCountry:(AWCountry *)country;

@end

@interface AWCountryListViewController : AWViewController

@property (nonatomic, weak) id <AWCountryListViewControllerDelegate> delegate;
@property (nonatomic, strong, nullable) AWCountry *country;

@end

NS_ASSUME_NONNULL_END
