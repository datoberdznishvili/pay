//
//  NetworkService.swift
//  Pay
//
//  Created by Giga Khizanishvili on 12.07.24.
//

import Foundation
import os

// MARK: - Protocol
protocol NetworkService {
    func request<T: Decodable>(_ request: Request) async -> Result<T, NetworkError>
}

// MARK: - Default Implementation
final class DefaultNetworkService: NetworkService {

    // MARK: - Properties
    private let logger = Logger(subsystem: "pay-showroom", category: "Network")

    private var baseURL: URL

    // MARK: - Init
    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    func setBaseURL(_ baseURL: URL) {
        self.baseURL = baseURL
    }

    func request<T: Decodable>(_ request: Request) async -> Result<T, NetworkError> {
        guard var urlComponents = URLComponents(
            url: baseURL.appendingPathComponent(
                request.path
            ),
            resolvingAgainstBaseURL: false
        ) else {
            return .failure(.invalidURL)
        }

        if let queryParameters = request.queryParameters {
            urlComponents.queryItems = queryParameters.map { queryItem in
                URLQueryItem(
                    name: queryItem.key,
                    value: queryItem.value
                )
            }
        }

        guard let url = urlComponents.url else {
            return .failure(.invalidURL)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue.uppercased()

        if let bodyParameters = request.bodyParameters {
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: bodyParameters, options: [])
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            logger.log(
                level: .debug,
                "\(Self.self) \(#function): data: \(String(data: data, encoding: .utf8) ?? "")"
            )

            if let serviceError = try? JSONDecoder().decode(NetworkServiceError.self, from: data) {
                return .failure(.serviceError(serviceError))
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                return .failure(.invalidResponse)
            }

            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            return .success(decodedResponse)
        } catch let decodingError {
            logger.log(level: .error, "\(decodingError.localizedDescription)")
            return .failure(.decodingFailed(decodingError))
        }
    }
}
