// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import UIKit

public func initialize() {
    DependencyGraph.registerAllServices()
}

public func open(from sourceViewController: UIViewController, configuration: Configuration) {
    let newViewController = UIHostingController(
        rootView: NavigationView {
            ContentView()
                .environmentObject(configuration)
        }
    )
    sourceViewController.present(
        newViewController,
        animated: true
    )
}
