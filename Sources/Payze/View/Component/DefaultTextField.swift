//
//  DefaultTextField.swift
//  Pay
//
//  Created by Mariam Ormotsadze on 03.07.24.
//

import SwiftUI

struct DefaultTextField: View {
    private var wrappedTextField: any View

    // MARK: - Init
    init(
        text: Binding<String>,
        isEditing: Binding<Bool>,
        title: String,
        placeHolder: String,
        icon: Image? = nil,
        isSecured: Bool = true,
        formatter: ((String) -> String)? = nil,
        validator: ((String) -> String?)? = nil
    ) {
        if #available(iOS 15.0, *) {
            wrappedTextField = NewDefaultTextField(
                text: text,
                isEditing: isEditing,
                title: title,
                placeHolder: placeHolder,
                icon: icon,
                isSecured: isSecured,
                formatter: formatter,
                validator: validator
            )
        } else {
            wrappedTextField = DeprecatedDefaultTextField(
                text: text,
                isEditing: isEditing,
                title: title,
                placeHolder: placeHolder,
                icon: icon,
                isSecured: isSecured,
                formatter: formatter,
                validator: validator
            )
        }
    }

    var body: some View {
        AnyView(
            wrappedTextField
        )
    }
}

// MARK: - New Text Field
@available(iOS 15.0, *)
struct NewDefaultTextField: View {
    @Injected private var configuration: Configuration

    @Binding private var text: String
    @Binding private var isEditing: Bool
    @State private var errorMessage: String?

    @FocusState private var isSecureFieldFocused: Bool

    private let title: String
    private let placeHolder: String
    private let icon: Image?
    private let isSecured: Bool
    private let formatter: ((String) -> String)?
    /// Value to validate -> ErrorMessage
    private let validator: ((String) -> String?)?

    // MARK: - Init
    init(
        text: Binding<String>,
        isEditing: Binding<Bool>,
        title: String,
        placeHolder: String,
        icon: Image? = nil,
        isSecured: Bool = true,
        formatter: ((String) -> String)? = nil,
        validator: ((String) -> String?)? = nil
    ) {
        self._text = text
        self._isEditing = isEditing

        self.title = title
        self.placeHolder = placeHolder
        self.icon = icon
        self.isSecured = isSecured
        self.formatter = formatter
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
                textField
                    .onChange(of: text) { newValue in
                        if validator?(text) == nil {
                            errorMessage = nil
                        }
                        if let formatter {
                            text = formatter(newValue)
                        }
                    }
                    .onChange(of: isEditing) { newValue in
                        if !newValue {
                            self.errorMessage = validator?(text)
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
@available(iOS 15.0, *)
private extension NewDefaultTextField {
    var textField: some View {
        if isSecured {
            AnyView(
                SecureField(placeHolder, text: $text)
                    .focused($isSecureFieldFocused)
                    .onChange(of: isSecureFieldFocused) { newValue in
                        isEditing = newValue
                    }
            )
        } else {
            AnyView(
                TextField(placeHolder, text: $text, onEditingChanged: { editing in
                    self.isEditing = editing
                })
            )
        }
    }

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


// MARK: - New Text Field
struct DeprecatedDefaultTextField: View {
    @Injected private var configuration: Configuration

    @Binding private var text: String
    @Binding private var isEditing: Bool
    @State private var errorMessage: String?

    private let title: String
    private let placeHolder: String
    private let icon: Image?
    private let isSecured: Bool
    private let formatter: ((String) -> String)?
    /// Value to validate -> ErrorMessage
    private let validator: ((String) -> String?)?

    // MARK: - Init
    init(
        text: Binding<String>,
        isEditing: Binding<Bool>,
        title: String,
        placeHolder: String,
        icon: Image? = nil,
        isSecured: Bool = true,
        formatter: ((String) -> String)? = nil,
        validator: ((String) -> String?)? = nil
    ) {
        self._text = text
        self._isEditing = isEditing

        self.title = title
        self.placeHolder = placeHolder
        self.icon = icon
        self.isSecured = isSecured
        self.formatter = formatter
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
                textField
                    .onChange(of: text) { newValue in
                        if validator?(text) == nil {
                            errorMessage = nil
                        }
                        if let formatter {
                            text = formatter(newValue)
                        }
                    }
                    .onChange(of: isEditing) { newValue in
                        if !newValue {
                            self.errorMessage = validator?(text)
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
private extension DeprecatedDefaultTextField {
    var textField: some View {
        if isSecured {
            AnyView(
                SecureField(placeHolder, text: $text)
            )
        } else {
            AnyView(
                TextField(placeHolder, text: $text, onEditingChanged: { editing in
                    self.isEditing = editing
                })
            )
        }
    }

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
