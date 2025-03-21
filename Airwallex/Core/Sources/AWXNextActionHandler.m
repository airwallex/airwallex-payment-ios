//
//  AWXNextActionHandler.m
//  Airwallex
//
//  Created by Hector.Huang on 2024/3/13.
//  Copyright © 2024 Airwallex. All rights reserved.
//

#import "AWXNextActionHandler.h"
#import "AWXDefaultActionProvider.h"
#import "AWXUtils.h"

@interface AWXNextActionHandler ()

@property (nonatomic, strong, readonly) AWXSession *session;

@property (nonatomic, weak, readonly) id<AWXProviderDelegate> delegate;

@property (nonatomic, strong) AWXDefaultActionProvider *provider;

@end

@implementation AWXNextActionHandler

- (instancetype)initWithDelegate:(id<AWXProviderDelegate>)delegate session:(AWXSession *)session {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _session = session;
    }
    return self;
}

- (void)handleNextAction:(AWXConfirmPaymentNextAction *)nextAction {
    Class class = ClassToHandleNextActionForType(nextAction);
    AWXDefaultActionProvider *actionProvider = [[class alloc] initWithDelegate:self.delegate session:self.session];
    if (actionProvider == nil) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedStringFromTableInBundle(@"No provider matched the next action.", nil, [NSBundle resourceBundle], nil) preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"Close", nil, [NSBundle resourceBundle], nil) style:UIAlertActionStyleCancel handler:nil]];
        if ([self.delegate respondsToSelector:@selector(hostViewController)]) {
            [[self.delegate hostViewController] presentViewController:controller animated:YES completion:nil];
        } else {
            if ([self.delegate respondsToSelector:@selector(provider:shouldPresentViewController:forceToDismiss:withAnimation:)]) {
                [self.delegate provider:[[AWXDefaultProvider alloc] initWithDelegate:_delegate session:_session] shouldPresentViewController:controller forceToDismiss:YES withAnimation:YES];
            }
        }
        return;
    }
    [actionProvider handleNextAction:nextAction];
    self.provider = actionProvider;
}

@end
