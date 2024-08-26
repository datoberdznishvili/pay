//
//  ContentView.swift
//  Pay
//
//  Created by Mariam Ormotsadze on 19.06.24.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State private var isPoweredBySectionVisible = true

    // MARK: - Properties
    @Environment(\.presentationMode) private var presentationMode

    @Injected private var configuration: Configuration

    @StateObject private var viewModel: ContentViewModel

    @State private var isWebViewPresented = false
    @State private var urlForWebView: URL = URL(string: "https://google.com")!

    @State private var number = ""
    @State private var expirationDate = ""
    @State private var cvv = ""
    @State private var cardHolderName = ""

    @State private var isNumberTextFieldEditing = false
    @State private var isExpirationDateTextFieldEditing = false
    @State private var isCVVTextFieldEditing = false
    @State private var isCardHolderNameTextFieldEditing = false

    @State private var isExpirationDatePickerPresented = false
    @State private var selectedMonth = Date.currentMonth
    @State private var selectedYear = Date.currentYear

    private let alertTitle = LocalizationKey.Error.Default.title()
    @State private var isAlertPresented = false
    @State private var alertMessage = ""

    // MARK: - Init
    init(viewModel: ContentViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            configuration.colorPalette.background
                .edgesIgnoringSafeArea(.bottom)

            ZStack {
                VStack {
                    Divider()

                    contentView
                }

                if isExpirationDatePickerPresented {
                        ExpirationDatePickerView(
                            selectedMonth: $selectedMonth,
                            selectedYear: $selectedYear,
                            isPresented: $isExpirationDatePickerPresented
                        )
                }

                navigationLinkForWebView
            }
        }
        .disabled(viewModel.isLoading)
        .alert(isPresented: $isAlertPresented) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("Got It")) // TODO: Not localized
            )
        }
        .onReceive(
            viewModel.errorPublisher
                .receive(on: DispatchQueue.main)
        ) { error in
            alertMessage = error.localizedDescription
            isAlertPresented = true
        }
        .onReceive(
            viewModel.navigateToWebView
        ) { url in
            urlForWebView = url
            isWebViewPresented = true
        }
        .onReceive(
            viewModel.dismissPublisher
                .receive(on: DispatchQueue.main)
        ) {
            isWebViewPresented = false
            presentationMode.wrappedValue.dismiss()
        }
        .onReceive(keyboardWillShowPublisher) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                isPoweredBySectionVisible = false
            }
        }
        .onReceive(keyboardWillHidePublisher) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                isPoweredBySectionVisible = true
            }
        }
        .alert(isPresented: $viewModel.isAlertPresented) {
            Alert(title: Text(viewModel.errorAlertMessage))
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                toolbarCloseButton
            }
        }
        .navigationTitle(LocalizationKey.NavigationHeader.title())
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Components
private extension ContentView {
    var contentView: some View {
        VStack {
            contentBodyView
            Spacer()
            bottomView
        }
        .padding(.horizontal, 20)
    }

    var contentBodyView: some View {
        VStack(spacing: 12) {
            bannerView

            inputSection
        }
    }

    // MARK: Banner
    var bannerView: some View {
        HStack {
            configuration.companyIcon

            Spacer()

            VStack(alignment: configuration.companyIcon == nil ? .center : .trailing) {
                Text(LocalizationKey.Banner.amount())
                    .font(.caption)
                    .foregroundColor(configuration.colorPalette.textSecondary)
                
                Text(viewModel.amount.formatted())
                    .foregroundColor(configuration.colorPalette.textPrimary)
                    .bold()
            }

            if configuration.companyIcon == nil {
                Spacer()
            }
        }
        .padding(10)
        .background(configuration.colorPalette.surface)
        .cornerRadius(8)
    }

    var inputSection: some View {
        VStack(alignment: .leading, spacing: spacingForInputSection) {
            numberTextField

            HStack(alignment: .top) {
                expirationDateTextField

                if let cardBrand = viewModel.cardBrand, cardBrand.hasCVV {
                    cvvTextField
                }
            }

            cardHolderNameTextField
        }
    }

    // MARK: Number
    var numberTextField: some View {
        ZStack {
            DefaultTextField(
                text: $number,
                isEditing: $isNumberTextFieldEditing,
                title: LocalizationKey.CardNumber.title(),
                placeHolder: "Required", // TODO: Not localized
                icon: viewModel.cardBrand?.icon,
                formatter: viewModel.cardNumberFormatter(_:),
                validator: viewModel.numberValidator(_:)
            )
            .keyboardType(.numberPad)
            .textContentType(.creditCardNumber)
            .onChange(of: number) { number in
                viewModel.numberDidUpdate(to: number)
            }
            .onReceive(
                viewModel.updateCardNumberPublisher.receive(on: DispatchQueue.main)
            ) { newCardNumber in
                number = newCardNumber
            }
        }
    }

    // MARK: Expiration Date
    var expirationDateTextField: some View {
        ZStack {
            DefaultTextField(
                text: $expirationDate,
                isEditing: $isExpirationDateTextFieldEditing,
                title: LocalizationKey.ExpirationDate.title(),
                placeHolder: "MM / YYYY", // TODO: Not localized
                validator: viewModel.expirationDateValidator(_:)
            )
            .disabled(true)
            .onTapGesture {
                withAnimation {
                    hideKeyboard()

                    isExpirationDatePickerPresented = true
                    
                    isNumberTextFieldEditing = false
                    isExpirationDateTextFieldEditing = false
                    isCVVTextFieldEditing = false
                    isCardHolderNameTextFieldEditing = false

                    updateExpirationDateText()
                }
            }
            .onChange(of: selectedMonth) { _ in
                updateExpirationDateText()
            }
            .onChange(of: selectedYear) { _ in
                updateExpirationDateText()
            }
            .onChange(of: isExpirationDatePickerPresented) { isExpirationDatePickerPresented in
                isExpirationDateTextFieldEditing = isExpirationDatePickerPresented
            }

            HStack {
                Spacer()

                Image(.arrowDown)
                    .frame(width: 50, height: 50)
                    .offset(x: 4, y: 8)
            }
        }
    }

    // MARK: - CVV
    var cvvTextField: some View {
        DefaultTextField(
            text: $cvv, 
            isEditing: $isCVVTextFieldEditing,
            title: LocalizationKey.CVV.title(),
            placeHolder: LocalizationKey.CVV.placeholder(),
            validator: viewModel.cvvValidator(_:)
        )
        .keyboardType(.numberPad)
        .onChange(of: cvv) { newValue in
            guard let cvvLength = viewModel.cardBrand?.cvvLength else { return }
            if newValue.count > cvvLength {
                cvv = String(newValue.prefix(cvvLength))
            }
        }
    }

    // MARK: CardHolder
    var cardHolderNameTextField: some View {
        DefaultTextField(
            text: $cardHolderName,
            isEditing: $isCardHolderNameTextFieldEditing,
            title: LocalizationKey.CardHolder.title(),
            placeHolder: LocalizationKey.CardHolder.placeholder(),
            validator: viewModel.cardHolderNameValidator(_:)
        )
        .onChange(of: cardHolderName) { newValue in
            cardHolderName = newValue.uppercased()
        }
    }

    var bottomView: some View {
        VStack(spacing: 26) {
            nextButton

            if shouldShowFooterView {
                FooterView()
                    .padding(.bottom, 12)
            }
        }
    }

    // MARK: Next
    var nextButton: some View {
        let hasCVV = viewModel.cardBrand?.hasCVV == true
        let isDisabled = (
            [number, expirationDate, cardHolderName]
            + (hasCVV ? [cvv] : [])
        )
            .reduce(false) { $0 || $1.isEmpty }

        return Button(
            action: {
                viewModel.pay(
                    number: number,
                    cardHolder: cardHolderName,
                    expirationDate: expirationDate,
                    securityNumber: cvv
                )
            },
            label: {
                ZStack {
                    if viewModel.isLoading {
                        HStack {
                            ProgressView()
                                .foregroundColor(.white)

                            Spacer()
                        }
                    }
                    Text(LocalizationKey.nextButtonTitle())
                        .foregroundColor(configuration.colorPalette.nextOnInteractive)
                }
                .foregroundColor(configuration.colorPalette.surface)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(configuration.colorPalette.brand)
                        .opacity(isDisabled ? 0.4 : 1)
                )
            }
        )
        .padding(.bottom, shouldShowFooterView ? 0 : 16)
        .disabled(isDisabled)
    }

    var toolbarCloseButton: some View {
        Button(
            action: {
                presentationMode.wrappedValue.dismiss()
            },
            label: {
                Text(LocalizationKey.NavigationHeader.closeButtonTitle())
                    .foregroundColor(configuration.colorPalette.negative)
            }
        )
    }

    var navigationLinkForWebView: some View {
        NavigationLink(
            destination: {
                WebView(
                    url: urlForWebView,
                    onNavigation: { url in
                        viewModel.webViewDidNavigate(to: url)
                    }
                )
            }(),
            isActive: $isWebViewPresented
        ) {
            EmptyView()
        }
    }
}

// MARK: - Private
private extension ContentView {
    func updateExpirationDateText() {
        expirationDate = "\(selectedMonth.formattedToTwoDigits()) / \(selectedYear)"
    }

    var shouldShowFooterView: Bool {
        isPoweredBySectionVisible || UIDevice.current.userInterfaceIdiom == .pad
    }

    var spacingForInputSection: CGFloat {
        if UIScreen.main.bounds.height < 750 {
            10
        } else {
            22
        }
    }

    var keyboardWillShowPublisher: AnyPublisher<Void, Never> {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { _ in }
            .eraseToAnyPublisher()
    }

    var keyboardWillHidePublisher: AnyPublisher<Void, Never> {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in }
            .eraseToAnyPublisher()
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        ContentView(
            viewModel: ContentViewModel(
                transactionId: UUID().uuidString,
                amount: .init(amount: 123, currency: .usd),
                successCompletionHandler: { },
                failureCompletionHandler: { }
            )
        )
    }
}
