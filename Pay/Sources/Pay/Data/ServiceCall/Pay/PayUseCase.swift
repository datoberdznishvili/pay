//
//  PayUseCase.swift
//  Pay
//
//  Created by Giga Khizanishvili on 12.07.24.
//

// MARK: - Protocol
protocol PayUseCase {
    func execute(parameters: PayParameters) async -> Result<PayResponse, NetworkError>
}

// MARK: - Default Implementation
final class DefaultPayUseCase: PayUseCase {
    @Injected private var networkService: NetworkService

    func execute(parameters: PayParameters) async -> Result<PayResponse, NetworkError> {
        await networkService.request(PayRequest(parameters: parameters))
    }
}
