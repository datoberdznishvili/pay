//
//  GetTransactionDetailsUseCase.swift
//  Pay
//
//  Created by Giga Khizanishvili on 16.07.24.
//

// MARK: - Protocol
protocol GetTransactionDetailsUseCase {
    func execute(parameters transactionId: String) async -> Result<TransactionDetails, NetworkError>
}

// MARK: - Default Implementation
final class DefaultGetTransactionDetailsUseCase: GetTransactionDetailsUseCase {
    @Injected private var networkService: NetworkService

    func execute(parameters transactionId: String) async -> Result<TransactionDetails, NetworkError> {
        await networkService.request(
            GetTransactionDetailsRequest(transactionId: transactionId)
        )
    }
}
