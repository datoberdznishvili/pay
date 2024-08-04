//
//  CardNumberFormatter.swift
//  Pay
//
//  Created by Giga Khizanishvili on 12.07.24.
//

protocol CardNumberFormatter {
    func format(_ cardNumber: String, for brand: CardBrand) -> String
}

final class DefaultCardNumberFormatter: CardNumberFormatter {
    func format(_ cardNumber: String, for brand: CardBrand) -> String {
        let format = brand.format
        var result = ""
        var index = cardNumber.startIndex

        for ch in format {
            if index == cardNumber.endIndex {
                break
            }

            if ch == "#" {
                result.append(cardNumber[index])
                index = cardNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }

        return result
    }
}
