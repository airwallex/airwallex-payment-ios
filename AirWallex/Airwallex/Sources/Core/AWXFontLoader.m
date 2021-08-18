//
//  AWXFontLoader.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/25.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXFontLoader.h"
#import "AWXConstants.h"
#import "AWXUtils.h"
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@implementation AWXFontLoader

+ (void)loadFontIfNeeded
{
    [self loadFontWithFamilyName:AWXFontFamilyNameCircularStd
                       fontNames:@[AWXFontNameCircularStdMedium, AWXFontNameCircularStdBold]];
    [self loadFontWithFamilyName:AWXFontFamilyNameCircularXX
                       fontNames:@[AWXFontNameCircularXXRegular]];
}

+ (void)loadFontWithFamilyName:(NSString *)familyName fontNames:(NSArray <NSString *> *)fontNames
{
    if ([UIFont fontNamesForFamilyName:familyName].count == 0) {
        NSBundle *bundle = [NSBundle resourceBundle];
        NSString *identifier = bundle.bundleIdentifier;

        for (NSString *fontName in fontNames) {
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
