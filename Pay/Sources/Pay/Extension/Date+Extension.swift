//
//  Date+Extension.swift
//  Pay
//
//  Created by Giga Khizanishvili on 24.07.24.
//

import Foundation

extension Date {
    // MARK: - Static
    static var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }
}
