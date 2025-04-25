//
//  UserEditingEventObserver.swift
//  AirwallexPaymentSheet
//
//  Created by Weiping Li on 2025/4/15.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

class UserEditingEventObserver: EditingEventObserver  {
    
    let block: (UIControl.Event, UITextField) -> Void
    
    init(block: @escaping (UIControl.Event, UITextField) -> Void) {
        self.block = block
    }
    
    func handleEditingEvent(event: UIControl.Event, for textField: UITextField) {
        block(event, textField)
    }
}
