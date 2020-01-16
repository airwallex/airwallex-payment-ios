//
//  AWConstants.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

NSErrorDomain const AWSDKErrorDomain = @"com.airwallex.paymentacceptance";

#else

NSString *const AWSDKErrorDomain = @"com.airwallex.paymentacceptance";

#endif
