//
//  CardConsentCellViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/18.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

struct CardConsentCellViewModel: CardConsentCellConfiguring {
    var image: UIImage?
    
    var text: String
    
    var buttonAction: () -> Void
}
