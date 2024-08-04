//
//  DefaultTextField.swift
//  Pay
//
//  Created by Mariam Ormotsadze on 03.07.24.
//

import SwiftUI

struct DefaultTextField: View {
    @EnvironmentObject private var configuration: Configuration
    
    @Binding var text: String
    @Binding var isEditing: Bool

    var title: String
    var placeHolder: String

    // MARK: - Init
    init(
        text: Binding<String>,
        isEditing: Binding<Bool>,
        title: String,
        placeHolder: String
    ) {
        self._text = text
        self._isEditing = isEditing

        self.title = title
        self.placeHolder = placeHolder
    }

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .foregroundColor(configuration.colorPalette.textPrimary)
                .font(.caption)
                .bold()

            ZStack {
                TextField(placeHolder, text: $text, onEditingChanged: { editing in
                    self.isEditing = editing
                })
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                isEditing 
                                ? configuration.colorPalette.brand
                                : configuration.colorPalette.stroke,
                                lineWidth: 1
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(configuration.colorPalette.surface)
                                    .shadow(
                                        color: isEditing ? configuration.colorPalette.brand.opacity(0.4) : Color.clear,
                                        radius: isEditing ? 4 : 0, x: 0, y: 0
                                    )
                            )
                    )
            }
        }
    }

    func enable() {
        isEditing = true
    }
}

// MARK: - Preview
#Preview {
    DefaultTextField(
        text: .constant("Some randome text"),
        isEditing: .constant(true),
        title: "Required",
        placeHolder: "Number"
    )
    .environmentObject(Configuration.example)
}
