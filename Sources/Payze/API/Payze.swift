// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import UIKit

/// Entity for starting payze payment process
/// 1. Use 'Payze.init()' to create payze instance
/// 2. Use 'present()' instance method to present payment flow
public struct Payze {
    let configuration: Configuration


/// - Parameters:
///   - colorPalette: Colour configuration of card input screen,uses Payze colours by default
///   - companyIcon: Optional parameter to display on payment screen
///   - environment: Determines whether payment will be done on development or production environment
///   - language: Current localisation, supports: English, Uzbek, and Russian languages
///
/// - Warning: Initializing alone won't start payment process you have to use `present()` function to start payment flow
    public init(
        colorPalette: ColorPalette = .init(),
        companyIcon: Image? = nil,
        environment: ServiceEnvironment,
        language: Language
    ) {
        self.configuration = Configuration(
            colorPalette: colorPalette,
            companyIcon: companyIcon,
            environment: environment,
            language: language
        )

        DependencyGraph.registerAllServices(using: configuration)
    }

/// - Parameters:
///   - sourceViewController: Root view controller which will present payment flow on top of itself
///   - transactionId: Payze transactionId
///   - amount: Money amount
///   - completionHandler: Callback for when payment flow is finished
    public func present(
        on sourceViewController: UIViewController,
        transactionId: String,
        amount: Money,
        completionHandler: @escaping (PaymentCompletionType) -> Void
    ) {
        let viewModel = ContentViewModel(
            transactionId: transactionId,
            amount: amount,
            completionHandler: completionHandler
        )
        let newViewController = UIHostingController(
            rootView: NavigationView {
                ContentView(viewModel: viewModel)
            }
        )

        if UIDevice.current.userInterfaceIdiom == .phone {
            newViewController.modalPresentationStyle = .fullScreen
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            newViewController.modalPresentationStyle = .formSheet
        }

        sourceViewController.present(
            newViewController,
            animated: true
        )
    }
}
