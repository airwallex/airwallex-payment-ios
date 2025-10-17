//
//  CardNumberTextFieldViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/24.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation
#if canImport(AirwallexCore)
import AirwallexCore
#endif

class CardNumberTextFieldViewModel: InfoCollectorTextFieldViewModel, CardBrandViewConfiguring {
    let supportedBrands: [AWXBrandType]
    var currentBrand: AWXBrandType {
        if supportedBrands.contains(formatter.currentBrand) {
            return formatter.currentBrand
        } else {
            return .unknown
        }
    }
    
    private lazy var brandSortingDict: [AWXBrandType: Int] = {
        var dict = [AWXBrandType: Int]()
        for (idx, brand) in supportedBrands.enumerated() {
            guard dict[brand] == nil else { continue }
            dict[brand] = idx
        }
        return dict
    }()
    
    var cardBrands: [AWXBrandType] {
        if (text ?? "").isEmpty {
            return supportedBrands
        }
        let results = formatter.candidates
            .filter { supportedBrands.contains($0) }
            .sorted {
                guard let idx_l = brandSortingDict[$0],
                      let idx_r = brandSortingDict[$1] else {
                    return true
                }
                return idx_l <= idx_r
            }
        return results
    }
    
    private let formatter: CardNumberFormatter
    
    init(supportedCardSchemes: [AWXCardScheme],
         editingEventObserver: EditingEventObserver?,
         reconfigureHandler: @escaping ReconfigureHandler) {
        supportedBrands = supportedCardSchemes.compactMap { $0.brandType == .unknown ? nil : $0.brandType }
        formatter = CardNumberFormatter(candidates: supportedBrands)
        super.init(
            textFieldType: .cardNumber,
            placeholder: "1234 1234 1234 1234",
            clearButtonMode: .whileEditing,
            customInputFormatter: formatter,
            customInputValidator: CardNumberValidator(supportedCardSchemes: supportedCardSchemes),
            editingEventObserver: editingEventObserver,
            reconfigureHandler: reconfigureHandler
        )
    }
}
