//
//  Configuration.swift
//  Pay
//
//  Created by Giga Khizanishvili on 02.07.24.
//

import SwiftUI
import Combine

final class Configuration: ObservableObject {
    let colorPalette: ColorPalette
    let companyIcon: Image?
    let environment: ServiceEnvironment
    let language: Language

    init(
        colorPalette: ColorPalette,
        companyIcon: Image? = nil,
        environment: ServiceEnvironment,
        language: Language
    ) {
        self.colorPalette = colorPalette
        self.companyIcon = companyIcon
        self.environment = environment
        self.language = language
    }
}

// MARK: - ColorPalette
public struct ColorPalette {
    let brand: Color
    let textPrimary: Color
    let textSecondary: Color
    let background: Color
    let surface: Color
    let stroke: Color
    let negative: Color
    let nextOnInteractive: Color

    /// If no value is provided (nil) default colours will be used
    public init(
        brand: PayzeColor? = nil,
        textPrimary: PayzeColor? = nil,
        textSecondary: PayzeColor? = nil,
        background: PayzeColor? = nil,
        surface: PayzeColor? = nil,
        stroke: PayzeColor? = nil,
        negative: PayzeColor? = nil,
        nextOnInteractive: PayzeColor? = nil
    ) {
        self.brand = brand?.colorValue ?? Color("payBrand", bundle: .module)
        self.textPrimary = textPrimary?.colorValue ?? Color("payTextPrimary", bundle: .module)
        self.textSecondary = textSecondary?.colorValue ?? Color("payTextSecondary", bundle: .module)
        self.background = background?.colorValue ?? Color("payBackground", bundle: .module)
        self.surface = surface?.colorValue ?? Color("paySurface", bundle: .module)
        self.stroke = stroke?.colorValue ?? Color("payStroke", bundle: .module)
        self.negative = negative?.colorValue ?? Color("payNegative", bundle: .module)
        self.nextOnInteractive = nextOnInteractive?.colorValue ?? Color("payNextOnInteractive", bundle: .module)
    }
}

// MARK: - Example
extension Configuration {
    static var example: Self {
        Self(
            colorPalette: .init(),
            companyIcon: Image(.airbnb),
            environment: .development,
            language: .english
        )
    }
}
