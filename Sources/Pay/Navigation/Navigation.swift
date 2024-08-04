//
//  PayNavigation.swift
//  Pay
//
//  Created by Giga Khizanishvili on 04.08.24.
//

import UIKit
import SwiftUI

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
