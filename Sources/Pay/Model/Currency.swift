//
//  Currency.swift
//  Pay
//
//  Created by Giga Khizanishvili on 02.07.24.
//

enum Currency {
    case usd

    init(backedName: String) {
        switch backedName {
        case "USD":
            self = .usd
        default:
            self = .usd
        }
    }
}

extension Currency {
    var symbol: String {
        switch self {
        case .usd:
            "$"
        }
    }
}
