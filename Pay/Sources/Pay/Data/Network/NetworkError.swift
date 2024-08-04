//
//  NetworkError.swift
//  Pay
//
//  Created by Giga Khizanishvili on 12.07.24.
//

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case invalidData
    case decodingFailed(Error)
    case serviceError(NetworkServiceError)
}
