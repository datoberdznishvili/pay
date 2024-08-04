//
//  Request.swift
//  Pay
//
//  Created by Giga Khizanishvili on 12.07.24.
//

protocol Request {
    var path: String { get }
    var queryParameters: [String: String]? { get }
    var bodyParameters: [String: Any]? { get }
    var method: NetworkMethod { get }
}

extension Request {
    var queryParameters: [String: String]? { nil }
    var bodyParameters: [String: Any]? { nil }
}
