//
//  PayNavigation.swift
//  Pay
//
//  Created by Giga Khizanishvili on 04.08.24.
//

import UIKit
import SwiftUI

public final class Navigation {
    public func navigate(from sourceViewController: UIViewController, configuration: Configuration) {
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

    public init() { }
}
