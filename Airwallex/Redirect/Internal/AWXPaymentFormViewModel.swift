//
//  AWXPaymentFormViewModel.swift
//  Redirect
//
//  Created by Hector.Huang on 2022/7/1.
//  Copyright © 2022 Airwallex. All rights reserved.
//

import Foundation

public class AWXPaymentFormViewModel: NSObject {
    let session: AWXSession
    
    @objc public init(session: AWXSession) {
        self.session = session
    }
    
    @objc public func getPhonePrefix() -> String? {
        getPhonePrefixFromCountryCode() ?? getPhonePrefixFromCurrency()
    }
    
    private func getPhonePrefixFromCountryCode() -> String? {
        let dict = loadConfigFile(fileName: "CountryCodes")
        return dict?[session.countryCode]
    }
    
    private func getPhonePrefixFromCurrency() -> String? {
        let dict = loadConfigFile(fileName: "CurrencyCodes")
        return dict?[session.currency()]
    }
    
    private func loadConfigFile(fileName: String) -> Dictionary<String, String>? {
        if let path = Bundle.resource().path(forResource: fileName, ofType: "json") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                if let dict = try? JSONSerialization.jsonObject(with: data) {
                    return dict as? Dictionary<String, String>
                }
            }
        }
        return nil
    }
}
