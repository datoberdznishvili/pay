//
//  Currency.swift
//  Pay
//
//  Created by Giga Khizanishvili on 02.07.24.
//

public enum Currency {
    case usd
    case uzs

    init(backedName: String) {
        switch backedName {
        case "USD":
            self = .usd
        case "UZS":
            self = .uzs
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
        case .uzs:
            "UZS"
        }
    }
}

// MARK: - Position
extension Currency {
    enum Position {
        case beforeAmount
        case afterAmount
    }

    var position: Position {
        switch self {
        case .usd:
                .beforeAmount
        case .uzs:
                .afterAmount
        }
    }
}
