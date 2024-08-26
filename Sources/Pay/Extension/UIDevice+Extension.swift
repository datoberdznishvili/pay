//
//  UIDevice+Extension.swift
//  
//
//  Created by Giga Khizanishvili on 26.08.24.
//

import UIKit

extension UIDevice {
    var isPhone: Bool {
        userInterfaceIdiom == .phone
    }

    var isPad: Bool {
        userInterfaceIdiom == .pad
    }
}
