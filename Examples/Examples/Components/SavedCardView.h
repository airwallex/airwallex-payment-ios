//
//  savedCardView.h
//  Examples
//
//  Created by Tony He (CTR) on 2024/8/9.
//  Copyright © 2024 Airwallex. All rights reserved.
//

#import <Airwallex/Core.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SavedCardViewDelegate

- (void)consentSelected:(AWXPaymentConsent *)consent;

@end

@interface SavedCardView : UIView

@property (nonatomic, weak) id<SavedCardViewDelegate> delegate;

- (void)reloadWith:(NSArray<AWXPaymentConsent *> *)list;

@end

NS_ASSUME_NONNULL_END
