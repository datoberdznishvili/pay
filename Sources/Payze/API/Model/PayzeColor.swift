//
//  MyColor.swift
//  Pay
//
//  Created by Giga Khizanishvili on 02.07.24.
//

import SwiftUI

public struct PayzeColor {
    let light: UIColor
    let dark: UIColor

    var colorValue: Color {
        Color(
            UIColor {
                $0.userInterfaceStyle == .dark ? dark : light
            }
        )
    }
}
