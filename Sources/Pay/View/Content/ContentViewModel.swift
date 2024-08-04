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

    // TODO: Update values
    private let successDestinationURLString = "https://barcamania.ge/contact.html"
    private let failureDestinationURLString = "https://barcamania.ge/blog/"

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

        if url.absoluteString == successDestinationURLString {
            print("User did reach success case")
            successCompletionHandler()
            dismissSubject.send(())
        } else if url.absoluteString == failureDestinationURLString {
            print("User did reach failure case")
            failureCompletionHandler()
            dismissSubject.send()
        }
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
