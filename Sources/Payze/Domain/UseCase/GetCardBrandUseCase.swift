//
//  GetCardBrandUseCase.swift
//  Pay
//
//  Created by Giga Khizanishvili on 12.07.24.
//

// MARK: - Protocol
protocol GetCardBrandUseCase {
    func execute(parameters bin: String) async -> Result<CardBrand, NetworkError>
}

// MARK: - Default Implementation
final class DefaultGetCardBrandUseCase: GetCardBrandUseCase {
    @Injected private var networkService: NetworkService

    func execute(parameters bin: String) async -> Result<CardBrand, NetworkError> {
        await networkService.request(GetCardBrandRequest(bin: bin))
    }
}
