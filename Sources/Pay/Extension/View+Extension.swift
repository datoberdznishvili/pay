//
//  View+Extension.swift
//  Pay
//
//  Created by Giga Khizanishvili on 17.07.24.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(
                UIResponder.resignFirstResponder
            ),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
