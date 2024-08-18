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

    @Published var errorAlertMessage: String?
    @Published var isAlertPresented = false

    let amount: Money

    // MARK: - Init
    init(
        transactionId: String,
        amount: Money,
        successCompletionHandler: @escaping () -> Void,
        failureCompletionHandler: @escaping () -> Void
    ) {
        self.transactionId = transactionId
        self.amount = amount
        self.successCompletionHandler = successCompletionHandler
        self.failureCompletionHandler = failureCompletionHandler
    }

    // MARK: - Functions
    func pay(
        number: String,
        cardHolder: String,
        expirationDate: String,
        securityNumber: String
    ) {
        let expirationDate = expirationDate.removingWhitespaces()

        if let numberErrorMessage = numberValidator(number) {
            showErrorMessage("Number: \(numberErrorMessage)")
            return
        }

        if let cardHolderMessage = cardHolderNameValidator(cardHolder) {
            showErrorMessage("CardHolder: \(cardHolderMessage)")
            return
        }

        if let expirationDateMessage = expirationDateValidator(expirationDate) {
            showErrorMessage("Expiration Date: \(expirationDateMessage)")
            return
        }

        guard let shortenedExpirationDate = shortenYear(in: expirationDate) else {
            showErrorMessage("Please enter valid expiration date")
            return
        }

        if let securityNumberMessage = cvvValidator(securityNumber) {
            showErrorMessage("CVV: \(securityNumberMessage)")
            return
        }

        isLoading = true
        Task {
            let result = await payUseCase.execute(
                parameters: PayParameters(
                    transactionId: transactionId,
                    number: number,
                    cardHolder: cardHolder,
                    expirationDate: shortenedExpirationDate,
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

        guard isValidCardNumber(number) else {
            return "Please enter valid card number"
        }

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

    func expirationDateValidator(_ expirationDate: String) -> String? {
        let expirationDate = expirationDate.removingWhitespaces()
        let dateComponents = expirationDate.components(separatedBy: "/")
        
        guard dateComponents.count == 2 else {
            return "Please enter Expiration Date"
        }

        guard isFutureDate(month: dateComponents[0], year: dateComponents[1]) else {
            return "Please enter card that's expiration date in the future, not in past"
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

    func isValidCardNumber(_ cardNumber: String) -> Bool {
        let reversedDigits = cardNumber.reversed().map { String($0) }

        var sum = 0

        for (index, element) in reversedDigits.enumerated() {
            guard let digit = Int(element) else {
                return false
            }

            if index % 2 == 1 {
                let doubledDigit = digit * 2
                sum += doubledDigit > 9 ? doubledDigit - 9 : doubledDigit
            } else {
                sum += digit
            }
        }

        return sum % 10 == 0
    }

    func isFutureDate(month: String, year: String) -> Bool {
        // Ensure that the inputs are valid
        guard let monthInt = Int(month), let yearInt = Int(year), monthInt >= 1, monthInt <= 12 else {
            print("Invalid month or year input")
            return false
        }

        // Get the current date components
        let currentDate = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)

        // Compare year and month
        if yearInt > currentYear {
            return true
        } else if yearInt == currentYear, monthInt >= currentMonth {
            return true
        } else {
            return false
        }
    }

    func shortenYear(in expression: String) -> String? {
        // Split the input string into components using the "/" separator
        let components = expression.split(separator: "/")

        // Ensure the input has exactly two components (month and year)
        guard components.count == 2 else {
            print("Invalid format")
            return nil
        }

        let month = components[0]
        let year = components[1]

        // Ensure the year has at least four characters
        print("Year: \(year)")
        guard year.count == 4 else {
            print("Invalid year format")
            return nil
        }

        // Get the last two characters of the year
        let shortYear = year.suffix(2)

        // Combine the month and shortened year
        return "\(month)/\(shortYear)"
    }

    func showErrorMessage(_ message: String) {
        errorAlertMessage = message
        isAlertPresented = true
    }
}
