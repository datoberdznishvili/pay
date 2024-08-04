//
//  String+Extension.swift
//  Pay
//
//  Created by Giga Khizanishvili on 17.07.24.
//

extension String {
    func removingWhitespaces() -> Self {
        self.replacingOccurrences(of: " ", with: "")
    }

    func toArray() -> [Character] {
        Array(self)
    }
}
