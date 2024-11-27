//
//  AWXUIContext+Card.m
//  AirWallexPaymentSDK
//
//  Created by Weiping Li on 2024/11/27.
//

#import "AWXCardViewController.h"
#import "AWXCardViewModel.h"
#import "AWXUIContext+Card.h"

@implementation AWXUIContext (Card)

/// Present the card payment flow.
- (void)presentCardPaymentFlowFrom:(UIViewController *)hostViewController cardSchemes:(NSArray<AWXCardBrand> *)cardSchemes {
    AWXCardViewController *controller = [[AWXCardViewController alloc] initWithNibName:nil bundle:nil];
    controller.session = self.session;

    NSMutableArray<AWXCardScheme *> *cardSchemesArray = [NSMutableArray array];
    for (AWXCardBrand scheme in cardSchemes) {
        AWXCardScheme *cardScheme = [[AWXCardScheme alloc] init];
        cardScheme.name = scheme;
        [cardSchemesArray addObject:cardScheme];
    }

    AWXCardViewModel *viewModel = [[AWXCardViewModel alloc] initWithSession:self.session supportedCardSchemes:cardSchemesArray launchDirectly:YES];
    controller.viewModel = viewModel;

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.modalInPresentation = YES;

    [hostViewController presentViewController:navigationController animated:YES completion:nil];
}

/// Push the card payment flow.
- (void)pushCardPaymentFlowFrom:(UIViewController *)hostViewController cardSchemes:(NSArray<AWXCardBrand> *)cardSchemes {
    UINavigationController *navigationController = nil;

    if ([hostViewController isKindOfClass:[UINavigationController class]]) {
        navigationController = (UINavigationController *)hostViewController;
    } else {
        navigationController = hostViewController.navigationController;
    }

    if (!navigationController) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"The hostViewController is not a navigation controller, or is not contained in a navigation controller."
                                     userInfo:nil];
    }

    AWXCardViewController *controller = [[AWXCardViewController alloc] initWithNibName:nil bundle:nil];
    controller.session = self.session;

    NSMutableArray<AWXCardScheme *> *supportedCardSchemes = [NSMutableArray array];
    for (AWXCardBrand brand in cardSchemes) {
        AWXCardScheme *cardScheme = [[AWXCardScheme alloc] init];
        cardScheme.name = brand;
        [supportedCardSchemes addObject:cardScheme];
    }

    AWXCardViewModel *viewModel = [[AWXCardViewModel alloc] initWithSession:self.session supportedCardSchemes:supportedCardSchemes launchDirectly:YES];
    controller.viewModel = viewModel;

    [navigationController pushViewController:controller animated:YES];
}

- (void)presentCardPaymentFlowFrom:(UIViewController *)hostViewController {
    [self presentCardPaymentFlowFrom:hostViewController cardSchemes:@[AWXCardBrandVisa, AWXCardBrandMastercard, AWXCardBrandAmex, AWXCardBrandDiscover, AWXCardBrandDinersClub, AWXCardBrandJCB, AWXCardBrandUnionPay]];
}

- (void)pushCardPaymentFlowFrom:(UIViewController *)hostViewController {
    [self pushCardPaymentFlowFrom:hostViewController cardSchemes:@[AWXCardBrandVisa, AWXCardBrandMastercard, AWXCardBrandAmex, AWXCardBrandDiscover, AWXCardBrandDinersClub, AWXCardBrandJCB, AWXCardBrandUnionPay]];
}

@end
