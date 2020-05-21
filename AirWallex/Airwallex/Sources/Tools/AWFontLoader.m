//
//  AWFontLoader.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/25.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWFontLoader.h"
#import "AWConstants.h"
#import "AWUtils.h"
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@implementation AWFontLoader

+ (void)loadFontIfNeeded
{
    if ([UIFont fontNamesForFamilyName:AWFontFamilyNameCircularStd].count == 0) {
        NSBundle *bundle = [NSBundle resourceBundle];
        NSString *identifier = bundle.bundleIdentifier;

        NSArray *fonts = @[AWFontNameCircularStdMedium, AWFontNameCircularStdBold];
        for (NSString *fontName in fonts) {
            NSURL *fontURL = nil;
            if ([identifier hasPrefix:@"org.cocoapods"]) {
                fontURL = [bundle URLForResource:fontName withExtension:@"otf" subdirectory:@"Airwallex.bundle"];
            } else {
                fontURL = [bundle URLForResource:fontName withExtension:@"otf"];
            }
            NSData *data = [NSData dataWithContentsOfURL:fontURL];
            CFErrorRef error;
            CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
            CGFontRef font = CGFontCreateWithDataProvider(provider);
            if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
                CFStringRef errorDescription = CFErrorCopyDescription(error);
                
                NSLog(@"Failed to load font: %@", errorDescription);
                CFRelease(errorDescription);
            }
            CGFontRelease(font);
            CGDataProviderRelease(provider);
        }
    }
}

@end
