//
//  BeginEditingEventObserver.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/11.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

class BeginEditingEventObserver: EditingEventObserver {
    private let block: () -> Void
    init(block: @escaping () -> Void) {
        self.block = block
    }
    
    func handleEditingEvent(event: UIControl.Event, for textField: UITextField) {
        switch event {
        case .editingDidBegin:
            block()
        default:
            break
        }
    }
}
