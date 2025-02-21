//
//  Fonts.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/16.
//  Copyright © 2024 Airwallex. All rights reserved.
//
//
//UltraLight: [100] (approximation)
//Thin: [200] (approximation)
//Light: [300]
//Regular: [400]
//Medium: [500]
//Semibold: [600]
//Bold: [700]
//Heavy/Black: [800] (both can map to higher numeric values)

public extension UIFont {
    
    public enum AWXFont {
        /// 34, Use for larger devices such as iPad
        case largeTitle
        /// 28 Full page takeovers (eg. alerts, onboarding)
        case title1
        /// 22 PageHeader component header, Primary headers (eg. Wallet, Cards)
        case title2
        /// 20 Section headers (ie. sheets, wallet balance), CurrencyField
        case title3
        
        /// 17, Body Bold, Button text, CurrencySelector
        case headline1
        /// 15 Small buttons (eg. Filters), TableData balances, SectionHeader, TableHeader, CheckboxGroup, DateRangePickerGroup, DatePickerGroup, ChipGroup
        case headline2
        
        /// 15 regular -Tip, HeadingGroup caption, Label, Checkbox, Radio Button, DatePicker
        /// 15 bold - Tip, StatusBar, Chip, CurrencySelector, DatePicker input text, CurrencyField
        case subtitle1
        
        /// 14 bold - Tag (1)
        /// 14 regualr - N/A
        case caption1
        /// 12 regular - Section header caption, Currency field
        /// 12 bold - Tag (2), TextInput filled label, Alert, TableHeader, CurrencyField error (This needs some work), PasscodeField
        case caption2
        /// 11 regular - N/A
        /// 11 bold - TabBar
        case caption3
        
        /// 17 regular - Any paragraph text; Form fields text
        /// 17 bold - Bold paragraph text
        case body1
        /// 15 regular - TableData content, Secondary subheadings (eg. cardholder name), Search placeholder text, Alert body text
        /// 15 bold - TableData balances
        case body2
        
        /// 14 regular - TableRow secondary content (E.g. Return 20.00 AUD to cust)
        case optional1
        /// 12 regular - Alert (Inline & subtle), Form fields
        case optional2
        
        /// 14 regular - TableRow status (E.g. Declined | Overdue)
        case error1
        /// 12 regular - Field error
        case error2
        
        var size: CGFloat {
            switch self {
            case .largeTitle: return 34
            case .title1: return 28
            case .title2: return 22
            case .title3: return 20
            case .headline1: return 17
            case .headline2: return 15
            case .subtitle1: return 15
            case .caption1: return 14
            case .caption2: return 12
            case .caption3: return 11
            case .body1: return 17
            case .body2: return 15
            case .optional1: return 14
            case .optional2: return 12
            case .error1: return 14
            case .error2: return 12
            }
        }
    }
    
    /// return UIFont by semantic and weight
    /// - Parameters:
    ///   - font: Defined by UI
    ///   - weight: weight of font
    /// - Returns: UIFont
    public static func awxFont(_ font: AWXFont, weight: UIFont.Weight = .regular) -> UIFont {
        UIFont.systemFont(ofSize: font.size, weight: weight)
    }
}
