//
//  CheckBoxCellViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/7.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

class CheckBoxCellViewModel: CheckBoxCellConfiguring {
    var isSelected: Bool
    
    var title: String?
    
    var boxInfo: String = ""
    
    func toggleSelection() {
        isSelected.toggle()
        selectionDidChanged?(isSelected)
    }
    //  MARK: -
    private var selectionDidChanged: ((Bool) -> Void)?
    
    init(isSelected: Bool,
         title: String?,
         boxInfo: String,
         selectionDidChanged: ((Bool) -> Void)? = nil) {
        self.isSelected = isSelected
        self.title = title
        self.boxInfo = boxInfo
        self.selectionDidChanged = selectionDidChanged
    }
}
        

