//
//  Int+Extension.swift
//  Pay
//
//  Created by Giga Khizanishvili on 17.07.24.
//

extension Int {
    func formattedToTwoDigits() -> String {
        String(format: "%02d", self)
    }
}
