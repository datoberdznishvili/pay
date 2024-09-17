//
//  NetworkServiceError.swift
//  Pay
//
//  Created by Giga Khizanishvili on 12.07.24.
//

struct NetworkServiceError: Decodable {
    let data: String? // TODO: ?
    let status: Status
}

// MARK: - Status
extension NetworkServiceError {
    struct Status: Decodable {
        let message: String
        let errors: [String]
        let type: String
    }
}
