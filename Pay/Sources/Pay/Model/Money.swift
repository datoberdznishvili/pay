//
//  Money.swift
//  Pay
//
//  Created by Giga Khizanishvili on 02.07.24.
//

struct Money {
    let amount: Double
    let currency: Currency
}

extension Money {
    func formatted() -> String {
        "\(currency.symbol)\(amount)"
    }
}
