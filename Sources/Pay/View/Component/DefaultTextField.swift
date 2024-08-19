//
//  DefaultTextField.swift
//  Pay
//
//  Created by Mariam Ormotsadze on 03.07.24.
//

import SwiftUI

struct DefaultTextField: View {
    @Injected private var configuration: Configuration
    
    @Binding var text: String
    @Binding var isEditing: Bool
    @State var errorMessage: String?

    var title: String
    var placeHolder: String
    var icon: Image?
    /// Value to validate -> ErrorMessage
    var validator: ((String) -> String?)?

    // MARK: - Init
    init(
        text: Binding<String>,
        isEditing: Binding<Bool>,
        title: String,
        placeHolder: String,
        icon: Image? = nil,
        validator: ((String) -> String?)? = nil
    ) {
        self._text = text
        self._isEditing = isEditing

        self.title = title
        self.placeHolder = placeHolder
        self.icon = icon
        self.validator = validator
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
                    if !isEditing {
                        self.errorMessage = validator?(text)
                    }
                })
                .onChange(of: text) { newValue in
                    if validator?(text) == nil {
                        errorMessage = nil
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            {
                                if isEditing {
                                    return configuration.colorPalette.brand
                                }
                                if errorMessage != nil {
                                    return configuration.colorPalette.negative.opacity(0.3)
                                }
                                return configuration.colorPalette.stroke
                            }(),
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

                if let icon {
                    HStack {
                        Spacer()

                        // TODO: Find how to pass (any View) instead
                        icon
                            .resizable()
                            .frame(width: 45, height: 22)
                            .padding(.trailing)
                    }
                }
            }


            errorMessageLabel
        }
    }

    func enable() {
        isEditing = true
    }
}

// MARK: - Components
private extension DefaultTextField {
    var errorMessageLabel: some View {
        if let errorMessage {
            AnyView(
                Text(errorMessage)
                    .foregroundColor(configuration.colorPalette.negative)
                    .font(.caption2)
                )
        } else {
            AnyView(
                EmptyView()
            )
        }
    }
}

// MARK: - Preview
#Preview {
    DefaultTextField(
        text: .constant("Some random text"),
        isEditing: .constant(true),
        title: "Required",
        placeHolder: "Number"
    )
    .environmentObject(Configuration.example)
}
