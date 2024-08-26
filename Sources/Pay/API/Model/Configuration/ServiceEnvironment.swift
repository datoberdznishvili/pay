//
//  ServiceEnvironment.swift
//  Pay
//
//  Created by Giga Khizanishvili on 04.08.24.
//

import Foundation

public enum ServiceEnvironment {
    case development
    case production
}

extension ServiceEnvironment {
    var baseURL: URL {
        let urlString = switch self {
        case .development: "https://paygate.payze.dev"
        case .production: "https://paygate.payze.uz"
        }

        return URL(string: urlString)!
    }
}
