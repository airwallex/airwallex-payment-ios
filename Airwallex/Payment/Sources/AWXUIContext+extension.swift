//
//  AWXUIContext+extension.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/10.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation


//- (void)presentEntirePaymentFlowFrom:(UIViewController *)hostViewController {
//    NSCAssert(hostViewController != nil, @"hostViewController must not be nil.");
//
//    AWXPaymentMethodListViewController *controller = [[AWXPaymentMethodListViewController alloc] initWithNibName:nil bundle:nil];
//    controller.viewModel = [[AWXPaymentMethodListViewModel alloc] initWithSession:_session APIClient:[[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]]];
//    controller.session = self.session;
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
//    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
//    [hostViewController presentViewController:navigationController animated:YES completion:nil];
//}

public extension AWXUIContext {
    func presentPaymentViewController(from hostingVC: UIViewController) {
        let paymentVC = PaymentMethodsViewController()
//        let viewModel = AWXPaymentMethodListViewModel(
//            session: session,
//            apiClient: AWXAPIClient(configuration: AWXAPIClientConfiguration.shared())
//        )
        paymentVC.session = self.session
        let nav = UINavigationController(rootViewController: paymentVC)
        nav.modalPresentationStyle = .fullScreen
        hostingVC.present(nav, animated: true)
    }
}
