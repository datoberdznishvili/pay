//
//  FooterView.swift
//
//
//  Created by Giga Khizanishvili on 18.08.24.
//

import SwiftUI

struct FooterView: View {

    @Injected private var configuration: Configuration

    var body: some View {
        VStack(spacing: 4) {
            Text(LocalizationKey.Footer.title())
                .foregroundColor(configuration.colorPalette.textSecondary)

            Image(.payze)
                .renderingMode(.template)
                .opacity(0.7)
                .blendMode(.luminosity)
                .foregroundColor(configuration.colorPalette.textSecondary)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack {
        Spacer()
        FooterView()
    }
}
