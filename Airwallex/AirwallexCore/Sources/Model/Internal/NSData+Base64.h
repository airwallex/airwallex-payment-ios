//
//  NSData+Base64.h
//  Core
//
//  Created by Hector.Huang on 2023/3/17.
//  Copyright © 2023 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Base64)

/**
 In most base64 decoding implementations like Java, the padding-character is not needed, but ``NSData.initWithBase64EncodedString`` returns nil if it's missing.
 This method will append "=" to base64 string whenever necessary and then decode to `NSData`.
 */
+ (instancetype)initWithBase64NoPaddingString:(NSString *)base64String;

@end
