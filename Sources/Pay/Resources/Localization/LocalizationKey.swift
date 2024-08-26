//
//  LocalizationKey.swift
//
//
//  Created by Giga Khizanishvili on 22.08.24.
//

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
