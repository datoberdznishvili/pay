//
//  Money.swift
//  Pay
//
//  Created by Giga Khizanishvili on 02.07.24.
//

import Foundation

public struct Money {
    let amount: Double
    let currency: Currency

    public init(amount: Double, currency: Currency) {
        self.amount = amount
        self.currency = currency
    }
}

extension Money {
    func formatted() -> String {
        func formatNumber(_ number: Double) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = " "
            formatter.decimalSeparator = "."    // Ensure a dot as the decimal separator
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 2

            if let formattedNumber = formatter.string(from: NSNumber(value: number)) {
                return formattedNumber
            } else {
                return "\(number)"
            }
        }

        let formattedAmount = formatNumber(amount)

        switch currency.position {
        case .beforeAmount:
            return "\(currency.symbol)\(formattedAmount)"
        case .afterAmount:
            return "\(formattedAmount) \(currency.symbol)"
        }
    }
}
