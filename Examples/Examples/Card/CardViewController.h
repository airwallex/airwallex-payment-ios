//
//  CardViewController.h
//  Examples
//
//  Created by Victor Zhu on 2020/2/1.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Airwallex/Airwallex.h>
#import "EditShippingViewController.h"

@class CardViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol CardViewControllerDelegate <NSObject>

- (void)cardViewController:(CardViewController *)controller didSelectCard:(AWCard *)card;

@end

@interface CardViewController : UIViewController

@property (nonatomic, weak) id <CardViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
