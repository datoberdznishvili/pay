// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import UIKit

public struct Pay {
    let configuration: Configuration

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

    public func present(
        on sourceViewController: UIViewController,
        transactionId: String,
        amount: Money,
        successCompletionHandler: @escaping () -> Void,
        failureCompletionHandler: @escaping () -> Void
    ) {
        let viewModel = ContentViewModel(
            transactionId: transactionId,
            amount: amount,
            successCompletionHandler: successCompletionHandler,
            failureCompletionHandler: failureCompletionHandler
        )
        let newViewController = UIHostingController(
            rootView: NavigationView {
                ContentView(viewModel: viewModel)
            }
        )
        newViewController.modalPresentationStyle = .fullScreen
        sourceViewController.present(
            newViewController,
            animated: true
        )
    }
}
