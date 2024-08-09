//
//  ContentViewModel.swift
//  Pay
//
//  Created by Giga Khizanishvili on 12.07.24.
//

import Foundation
import Combine

final class ContentViewModel: ObservableObject {
    // MARK: - Properties
    @Injected private var cardNumberFormatter: CardNumberFormatter
    @Injected private var payUseCase: PayUseCase
    @Injected private var getCardBrandUseCase: GetCardBrandUseCase
    @Injected private var getTransactionDetailsUseCase: GetTransactionDetailsUseCase

    @Injected private var configuration: Configuration

    private let successDestinationEndpoint = "/Success"
    private let failureDestinationEndpoint = "/Fail"

    private let transactionId: String
    private let successCompletionHandler: () -> Void
    private let failureCompletionHandler: () -> Void

    private var getCardBrandTask: Task<Void, Never>?

    private var subscriptions: Set<AnyCancellable> = []

    private let errorSubject = PassthroughSubject<NetworkError, Never>()
    private let updateCardNumberSubject = PassthroughSubject<String, Never>()
    private let dismissSubject = PassthroughSubject<Void, Never>()
    private let navigateToWebViewSubject = PassthroughSubject<URL, Never>()

    // MARK: - Published internal properties
    @Published var isLoading = false
    @Published var cardBrand: CardBrand?
    @Published var amount: Money?

    // MARK: - Init
    init(
        transactionId: String,
        successCompletionHandler: @escaping () -> Void,
        failureCompletionHandler: @escaping () -> Void
    ) {
        self.transactionId = transactionId
        self.successCompletionHandler = successCompletionHandler
        self.failureCompletionHandler = failureCompletionHandler
    }

    // MARK: - Functions
    func viewDidAppear() {
        fetchTransactionDetails(for: transactionId)
    }

    func fetchTransactionDetails(for transactionId: String) {
        Task {
            let result = await getTransactionDetailsUseCase.execute(parameters: transactionId)

            switch result {
            case .success(let details):
                DispatchQueue.main.async {
                    self.amount = Money(
                        amount: details.amount,
                        currency: .init(backedName: details.currency)
                    )
                }
            case .failure:
                failureCompletionHandler()
                dismissSubject.send(())
            }
        }
    }

    func pay(
        number: String,
        cardHolder: String,
        expirationDate: String,
        securityNumber: String
    ) {
        isLoading = true
        Task {
            let result = await payUseCase.execute(
                parameters: PayParameters(
                    transactionId: transactionId,
                    number: number,
                    cardHolder: cardHolder,
                    expirationDate: expirationDate,
                    securityNumber: securityNumber
                )
            )

            DispatchQueue.main.async {
                self.isLoading = false
            }

            switch result {
            case .success(let response):
                switch response {
                case .success:
                    successCompletionHandler()
                    dismissSubject.send(())
                case .otpWasRequired(let url):
                    openWebView(withURL: url)
                case .failure:
                    failureCompletionHandler()
                    dismissSubject.send(())
                }
            case .failure:
                failureCompletionHandler()
                dismissSubject.send(())
            }
        }
    }

    func numberDidUpdate(to bin: String) {
        getCardBrandTask?.cancel()

        let bin = bin.removingWhitespaces()

        updateCardNumberUsingCardBrandFormat(bin)

        getCardBrandTask = Task {
            let result = await getCardBrandUseCase.execute(parameters: bin)

            switch result {
            case .success(let cardBrand):
                DispatchQueue.main.async {
                    self.cardBrand = cardBrand
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.cardBrand = nil
                }
            }
        }
    }

    func webViewDidNavigate(to url: URL) {
        print("\(#function): \(url.absoluteString)")
        guard url.pathComponents.count == 2 else { return }
        // `/` and `endpoint`

        if url.lastPathComponent == successDestinationEndpoint {
            successCompletionHandler()
            dismissSubject.send(())
        } else if url.lastPathComponent == failureDestinationEndpoint {
            failureCompletionHandler()
            dismissSubject.send()
        }
    }

    // MARK: - Validation
    func numberValidator(_ number: String) -> String? {
        let number = number.removingWhitespaces()
        if number.isEmpty {
            return "This field should not be empty"
        }

        if number.count < 15 {
            return "Please fill this field"
        }
        
        guard let cardBrand else { return nil }

        guard number.count == cardBrand.format.removingWhitespaces().count else {
            return "Number's length should be \(cardBrand.format.removingWhitespaces().count)"
        }

        // TODO: Use Algorithm

        return nil
    }

    func cardHolderNameValidator(_ cardHolderName: String) -> String? {
        guard !cardHolderName.isEmpty else {
            return "This field should not be empty"
        }

        guard cardHolderName
            .components(separatedBy: " ")
            .filter({ !$0.isEmpty })
            .count >= 2
        else {
            return "Please enter full card holder name"
        }

        return nil
    }

    func cvvValidator(_ cvv: String) -> String? {
        guard let cardBrand else { return nil }
        guard cvv.allSatisfy(\.isNumber) else {
            return "Use only digits"
        }
        guard let cvvLength = cardBrand.cvvLength else { return nil }
        guard cvvLength == cvv.count else {
            return "CVV should be length of \(cvvLength)"
        }

        return nil
    }
}

// MARK: - Publishers
extension ContentViewModel {
    var errorPublisher: AnyPublisher<NetworkError, Never> {
        errorSubject
            .eraseToAnyPublisher()
    }

    var updateCardNumberPublisher: AnyPublisher<String, Never> {
        updateCardNumberSubject
            .eraseToAnyPublisher()
    }

    var navigateToWebView: AnyPublisher<URL, Never> {
        navigateToWebViewSubject
            .eraseToAnyPublisher()
    }

    var dismissPublisher: AnyPublisher<Void, Never> {
        dismissSubject
            .eraseToAnyPublisher()
    }
}

// MARK: - Private
private extension ContentViewModel {
    func updateCardNumberUsingCardBrandFormat(_ cardNumber: String) {
        // Right now all cards have the same format, so we use any of them
        let cardBrand = cardBrand ?? .visa

        let formattedCardNumber = cardNumberFormatter.format(cardNumber, for: cardBrand)
        updateCardNumberSubject.send(formattedCardNumber)
    }

    func openWebView(withURL url: URL) {
        navigateToWebViewSubject.send((url))
    }
}
