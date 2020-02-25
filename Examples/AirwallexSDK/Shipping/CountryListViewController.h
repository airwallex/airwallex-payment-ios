//
//  CountryListViewController.h
//  Examples
//
//  Created by Victor Zhu on 2020/1/19.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Country.h"

@class CountryListViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol CountryListViewControllerDelegate <NSObject>

- (void)countryListViewController:(CountryListViewController *)controller didSelectCountry:(Country *)country;

@end

@interface CountryListViewController : UIViewController

@property (nonatomic, weak) id <CountryListViewControllerDelegate> delegate;
@property (nonatomic, strong) Country *country;

@end

NS_ASSUME_NONNULL_END
