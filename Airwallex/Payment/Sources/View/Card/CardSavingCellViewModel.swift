//
//  CardSavingCellViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/27.
//  Copyright © 2024 Airwallex. All rights reserved.
//

struct CardSavingCellViewModel: CardSavingCellConfiguring {
    var shouldSaveCard: Bool
    
    var toggleSelection: () -> Void
}
