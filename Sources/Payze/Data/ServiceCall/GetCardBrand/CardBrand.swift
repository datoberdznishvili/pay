//
//  CardBrand.swift
//  Pay
//
//  Created by Giga Khizanishvili on 12.07.24.
//

import SwiftUI

enum CardBrand: Decodable {
    case amex
    case visa
    case mastercard
    case humo
    case uzCard

    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case amex = "Amex"
        case visa = "visa"
        case mastercard = "mastercard"
        case humo = "Humo"
        case uzCard = "uzCard"
    }
    
    var format: String {
        switch self {
        case .visa, .mastercard, .humo, .uzCard:
            "#### #### #### ####"
        case .amex:
            "#### ###### #####"
        }
    }

    var icon: Image {
        switch self {
        case .amex:
            Image(.amex)
        case .humo:
            Image(.humo)
        case .mastercard:
            Image(.masterCard)
        case .uzCard:
            Image(.uzcard)
        case .visa:
            Image(.visa)
        }
    }

    var hasCVV: Bool {
        cvvLength != nil
    }

    var cvvLength: Int? {
        switch self {
        case .amex:
            4
        case .visa:
            3
        case .mastercard:
            3
        case .humo:
            nil
        case .uzCard:
            nil
        }
    }
}
