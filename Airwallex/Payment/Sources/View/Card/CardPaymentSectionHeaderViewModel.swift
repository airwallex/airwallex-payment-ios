//
//  CardPaymentSectionHeaderViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/18.
//  Copyright © 2024 Airwallex. All rights reserved.
//

struct CardPaymentSectionHeaderViewModel: CardPaymentSectionHeaderConfiguring {
    var title: String
    var actionTitle: String
    var buttonAction: () -> Void
}
