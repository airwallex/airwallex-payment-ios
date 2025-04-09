//
//  Customer.swift
//  Examples
//
//  Created by Hector.Huang on 2024/9/6.
//  Copyright © 2024 Airwallex. All rights reserved.
//

#if canImport(Airwallex)
import Airwallex
#elseif canImport(AirwallexPayment)
import AirwallexPayment
import AirwallexCore
#endif

class Customer: NSObject, AWXJSONDecodable {
    @objc let id: String
    
    static func decode(fromJSON json: [AnyHashable : Any]) -> Any? {
        if let id = json["id"] as? String {
            return Customer(id: id)
        }
        return nil
    }
    
    init(id: String) {
        self.id = id
    }
}
