//
//  AddressRule.swift
//  Airwallex
//
//  Copyright © 2026 Airwallex. All rights reserved.
//

import Foundation
#if canImport(AirwallexCore)
import AirwallexCore
#endif

package struct AddressRule: Decodable {
    package let fmt: String?
    package let zip: String?
    package let subKeys: [String]?
    package let subLabels: [String]?
    package let stateNameType: String?
    package let localityNameType: String?
    package let zipNameType: String?
}

package enum AddressFieldKind {
    case street
    case state
    case city
    case postcode
}

package enum AddressFieldWidth {
    case full
    case half
}

package struct SubdivisionOption: Hashable {
    package let value: String
    package let label: String

    package init(value: String, label: String) {
        self.value = value
        self.label = label
    }
}

package extension Array where Element == SubdivisionOption {
    /// Map a free-form state string (from a prefilled address or external API) to the matching
    /// option, mirroring web's `getMappedState` in `util.ts`. Case-insensitive exact match
    /// against the option's `value` (sub_key) or `label` (sub_label). Returns `nil` when no
    /// option matches — i.e. the input doesn't correspond to any known subdivision for this
    /// country, so it cannot pre-select the dropdown.
    func option(matching stateString: String?) -> SubdivisionOption? {
        guard let needle = stateString?.trimmed.lowercased(), !needle.isEmpty else { return nil }
        return first { $0.value.lowercased() == needle || $0.label.lowercased() == needle }
    }
}

package struct AddressFieldSpec {
    package let kind: AddressFieldKind
    package let width: AddressFieldWidth
    /// The `*_name_type` hint from the rule (`"prefecture"`, `"post_town"`, `"eircode"`, etc.).
    /// The UI layer translates this to a localized placeholder. `nil` for street and when the
    /// rule didn't specify one — the UI layer falls back to a default per kind.
    package let nameType: String?
    /// Non-nil only when `kind == .state` and the country has a `sub_keys` list — renders the
    /// state field as a dropdown.
    package let options: [SubdivisionOption]?
    /// Non-nil only when `kind == .postcode` and the country has a `zip` regex — used to
    /// validate user input.
    package let regex: NSRegularExpression?
}

package final class AddressRuleProvider {

    private let bundle: Bundle

    /// Lazy so a fresh provider doesn't pay the JSON-decode cost until something actually
    /// looks up a rule — useful for short-lived instances (e.g. inside `AWXAddress.isValid`).
    private lazy var rules: [String: AddressRule] = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let url = bundle.url(forResource: "address", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? decoder.decode([String: AddressRule].self, from: data) else {
            return [:]
        }
        return decoded
    }()

    private static let layoutOrder: [AddressFieldKind] = [.street, .state, .city, .postcode]

    package init(bundle: Bundle = .payment) {
        self.bundle = bundle
    }

    package func rule(for countryCode: String?) -> AddressRule? {
        guard let code = countryCode?.uppercased(), !code.isEmpty else { return nil }
        return rules[code]
    }

    package func fields(for countryCode: String?) -> [AddressFieldSpec] {
        let rule = rule(for: countryCode)
        let kinds = visibleKinds(in: rule?.fmt)
        if kinds.isEmpty {
            return [
                AddressFieldSpec(kind: .street, width: .full, nameType: nil, options: nil, regex: nil),
                AddressFieldSpec(kind: .city, width: .full, nameType: nil, options: nil, regex: nil),
            ]
        }
        let ordered = Self.layoutOrder.filter { kinds.contains($0) }
        return ordered.enumerated().map { index, kind in
            let width: AddressFieldWidth = (ordered.count >= 3 && (index == 1 || index == 2)) ? .half : .full
            return AddressFieldSpec(
                kind: kind,
                width: width,
                nameType: nameType(for: kind, rule: rule),
                options: kind == .state ? subdivisionOptions(from: rule) : nil,
                regex: kind == .postcode ? compileZipRegex(rule?.zip) : nil
            )
        }
    }

    /// True iff `address` satisfies the country's rule end-to-end:
    /// - country code is present and valid;
    /// - every field declared by `fmt` is non-empty (HK has no postcode in `fmt`, GB has no
    ///   state, AE has only state — so requiring all of them would reject otherwise-valid
    ///   prefilled addresses);
    /// - for dropdown-state countries, the state maps to one of the known `sub_keys` /
    ///   `sub_labels` via `option(matching:)`;
    /// - if the country has a `zip` regex, the postcode matches it.
    /// The bar is "could this address be submitted as-is without further user input?" —
    /// matches what the in-form validators enforce.
    package func isValid(_ address: AWXAddress) -> Bool {
        guard let countryCode = address.countryCode?.trimmed, !countryCode.isEmpty,
              countryCode.isValidCountryCode else {
            return false
        }
        for spec in fields(for: countryCode) {
            let value: String?
            switch spec.kind {
            case .street: value = address.street
            case .state: value = address.state
            case .city: value = address.city
            case .postcode: value = address.postcode
            }
            guard let value, !value.trimmed.isEmpty else { return false }
            switch spec.kind {
            case .state:
                if let options = spec.options, options.option(matching: value) == nil {
                    return false
                }
            case .postcode:
                if let regex = spec.regex {
                    let trimmed = value.trimmed
                    let range = NSRange(trimmed.startIndex..., in: trimmed)
                    if regex.firstMatch(in: trimmed, range: range) == nil {
                        return false
                    }
                }
            case .street, .city:
                break
            }
        }
        return true
    }

    private func nameType(for kind: AddressFieldKind, rule: AddressRule?) -> String? {
        switch kind {
        case .street:   return nil
        case .state:    return rule?.stateNameType
        case .city:     return rule?.localityNameType
        case .postcode: return rule?.zipNameType
        }
    }

    private func visibleKinds(in fmt: String?) -> Set<AddressFieldKind> {
        guard let fmt, !fmt.isEmpty,
              let pattern = try? NSRegularExpression(pattern: "%([ACSZ])") else { return [] }
        let range = NSRange(fmt.startIndex..., in: fmt)
        var kinds: Set<AddressFieldKind> = []
        pattern.enumerateMatches(in: fmt, range: range) { match, _, _ in
            guard let match, match.numberOfRanges >= 2,
                  let tokenRange = Range(match.range(at: 1), in: fmt) else { return }
            switch fmt[tokenRange] {
            case "A": kinds.insert(.street)
            case "C": kinds.insert(.city)
            case "S": kinds.insert(.state)
            case "Z": kinds.insert(.postcode)
            default: break
            }
        }
        return kinds
    }

    private func subdivisionOptions(from rule: AddressRule?) -> [SubdivisionOption]? {
        guard let keys = rule?.subKeys, !keys.isEmpty else { return nil }
        let labels = rule?.subLabels ?? []
        return keys.enumerated().map { index, key in
            SubdivisionOption(value: key, label: index < labels.count ? labels[index] : key)
        }
    }

    private func compileZipRegex(_ raw: String?) -> NSRegularExpression? {
        guard let raw, !raw.isEmpty else { return nil }
        return try? NSRegularExpression(pattern: "^\(raw)$", options: [.caseInsensitive])
    }
}
