//
//  File.swift
//  
//
//  Created by Giga Khizanishvili on 22.08.24.
//

import Foundation

protocol Localizable { }

extension Localizable {
    func callAsFunction(_ args: any CVarArg...) -> String {
        String(
            format: NSLocalizedString(
                name,
                bundle: .module,
                comment: ""
            ),
            args
        )
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


enum LocalizationKey: Localizable {
    enum Banner: Localizable {
        case amount
    }

    enum CardHolder: Localizable {
        case errorMessage
        case placeholder
        case title
    }

    enum CardNumber: Localizable {
        case errorMessage
        case placeholder
        case title
    }

    enum CVV: Localizable {
        case errorMessage
        case placeholder
        case title
    }

    enum Error {
        enum Default: Localizable {
            case description
            case title
        }
    }

    enum ExpirationDate: Localizable {
        case errorMessage
        case title
    }

    enum Footer: Localizable {
        case title
    }

    enum NavigationHeader: Localizable {
        case closeButtonTitle
        case title
    }

    case nextButtonTitle
}
