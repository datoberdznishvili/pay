//
//  PayResponse.swift
//
//
//  Created by Giga Khizanishvili on 05.08.24.
//

import Foundation

enum PayResponse {
    case success
    case failure
    case otpWasRequired(url: URL)
}
