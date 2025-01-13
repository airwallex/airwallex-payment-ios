//
//  CardConsentCellViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/18.
//  Copyright © 2024 Airwallex. All rights reserved.
//

struct CardConsentCellViewModel: CardConsentCellConfiguring {
    
    var image: UIImage?
    
    var text: String

    var highlightable: Bool
    
    var actionTitle: String?
    
    var actionIcon: UIImage?

    var buttonAction: () -> Void
}
