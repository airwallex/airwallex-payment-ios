//
//  BeginEditingEventObserver.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/11.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

class BeginEditingEventObserver: NSObject, UserEditingEventObserver {
    private let block: () -> Void
    init(block: @escaping () -> Void) {
        self.block = block
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        block()
    }
}
