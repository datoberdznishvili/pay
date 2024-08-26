//
//  Localizable.swift
//  Pay
//
//  Created by Giga Khizanishvili on 23.08.24.
//

import Foundation

protocol Localizable { }

extension Localizable {
    func callAsFunction(_ args: any CVarArg...) -> String {
        ""
    }

    private var name: String {
        let components = String(reflecting: self)
            .components(separatedBy: ["."])
            .dropFirst() // Module name
            .dropFirst() // LocalizationKey
            .map(\.withLowercasedFirstLetter)

        return ([moduleName] + components)
            .joined(separator: ".")
    }

    private var moduleName: String { "pay" }
}

private extension String {
    var withLowercasedFirstLetter: String {
        prefix(1).lowercased() + dropFirst()
    }
}
