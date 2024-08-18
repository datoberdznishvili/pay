//
//  Money.swift
//  Pay
//
//  Created by Giga Khizanishvili on 02.07.24.
//

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
        "\(currency.symbol)\(amount)"
    }
}
