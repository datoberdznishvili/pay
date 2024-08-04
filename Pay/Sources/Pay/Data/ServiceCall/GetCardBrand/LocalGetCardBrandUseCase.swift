//
//  LocalGetCardBrandUseCase.swift
//  Pay
//
//  Created by Giga Khizanishvili on 31.07.24.
//

final class LocalGetCardBrandUseCase: GetCardBrandUseCase {
    /// Uzcard: 8600, 5614
    /// HUMO: 9860
    /// Visa: 4...
    /// Mastercard: 2221-2720, 51..-55..
    /// Amex: 34, 37
    func execute(parameters bin: String) async -> Result<CardBrand, NetworkError> {
        let bin = bin.removingWhitespaces().toArray()

        guard bin.allSatisfy({ $0.isNumber }) else {
            return .failure(.invalidData)
        }

        guard bin.count >= 1 else {
            return .failure(.invalidData)
        }

        // Visa
        if bin[0] == "4" {
            return .success(.visa)
        }

        guard bin.count >= 2 else {
            return .failure(.invalidData)
        }

        let firstTwoDigitNumber = Int(String(bin[0...1]))!

        // Amex
        if [34, 37].contains(firstTwoDigitNumber) {
            return .success(.amex)
        }

        if (51...55).contains(firstTwoDigitNumber) {
            return .success(.mastercard)
        }

        guard bin.count >= 4 else {
            return .failure(.invalidURL)
        }

        let firstFourDigitNumber = Int(String(bin[0...3]))!

        if [8600, 5614].contains(firstFourDigitNumber) {
            return .success(.uzCard)
        }

        if [9860].contains(firstFourDigitNumber) {
            return .success(.humo)
        }

        if (2221...2720).contains(firstFourDigitNumber) {
            return .success(.mastercard)
        }

        return .failure(.invalidData)
    }
}
