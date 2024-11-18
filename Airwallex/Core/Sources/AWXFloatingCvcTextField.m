//
//  AWXFloatingCvcTextField.m
//  Core
//
//  Created by Hector.Huang on 2024/9/2.
//  Copyright © 2024 Airwallex. All rights reserved.
//

#import "AWXFloatingCvcTextField.h"

@implementation AWXFloatingCvcTextField

#pragma mark Override parent methods

- (instancetype)init {
    self = [super init];
    self.fieldType = AWXTextFieldTypeCVC;
    return self;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.errorText = nil;
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    text = [text substringToIndex:MIN(text.length, _maxLength)];
    text.length > 0 ? [self activateAnimated:YES] : [self deactivateAnimated:YES];

    [self setText:text animated:YES];
    if (_textDidChangeCallback) {
        _textDidChangeCallback(text);
    }
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (_validationMessageCallback) {
        self.errorText = _validationMessageCallback(textField.text);
    }
}

@end
