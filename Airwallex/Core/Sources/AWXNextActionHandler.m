//
//  AWXNextActionHandler.m
//  Airwallex
//
//  Created by Hector.Huang on 2024/3/13.
//  Copyright © 2024 Airwallex. All rights reserved.
//

#import "AWXNextActionHandler.h"
#import "AWXDefaultActionProvider.h"

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
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"No provider matched the next action.", nil) preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil) style:UIAlertActionStyleCancel handler:nil]];
        [self.delegate provider:actionProvider shouldPresentViewController:controller forceToDismiss:YES withAnimation:YES];
        return;
    }
    [actionProvider handleNextAction:nextAction];
    self.provider = actionProvider;
}

@end
