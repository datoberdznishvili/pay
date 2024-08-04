// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import UIKit

public struct Pay {
    let configuration: Configuration

    public init(
        font: Font,
        colorPalette: ColorPalette,
        companyIcon: Image? = nil,
        environment: ServiceEnvironment
    ) {
        self.configuration = Configuration(
            font: font,
            colorPalette: colorPalette,
            companyIcon: companyIcon,
            environment: environment
        )

        DependencyGraph.registerAllServices(using: configuration)
    }

    public func present(
        from sourceViewController: UIViewController,
        transactionId: String,
        successCompletionHandler: @escaping () -> Void,
        failureCompletionHandler: @escaping () -> Void
    ) {
        let viewModel = ContentViewModel(
            transactionId: transactionId,
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
