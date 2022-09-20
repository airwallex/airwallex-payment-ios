//
//  AWXCardViewModel.h
//  Card
//
//  Created by Hector.Huang on 2022/9/14.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXCard.h"
#import "AWXSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWXCardViewModel : NSObject

- (instancetype)initWithSession:(AWXSession *)session;

- (void)saveBillingWithPlaceDetails:(AWXPlaceDetails *)placeDetails
                            Address:(AWXAddress *)address
                  completionHandler:(void (^)(AWXPlaceDetails *_Nullable address, NSString *_Nullable error))completionHandler;

- (void)saveCardWithName:(NSString *)name
                  CardNo:(NSString *)cardNo
              ExpiryText:(NSString *)expiryText
                     Cvc:(NSString *)cvc
       completionHandler:(void (^)(AWXCard *_Nullable address, NSError *_Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
