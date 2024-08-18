//
//  ContentView.swift
//  Pay
//
//  Created by Mariam Ormotsadze on 19.06.24.
//

import SwiftUI

struct ContentView: View {

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

    // TODO: Change approach to be removed
    @State private var isNumberTextFieldEditing = false
    @State private var isExpirationDateTextFieldEditing = false
    @State private var isCVVTextFieldEditing = false
    @State private var isCardHolderNameTextFieldEditing = false

    @State private var isExpirationDatePickerPresented = false
    @State private var selectedMonth = 6
    @State private var selectedYear = Date.currentYear

    @State private var isAlertPresented = false
    @State private var alertTitle = "Error occurred"
    @State private var alertMessage = ""

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
                dismissButton: .default(Text("Got It"))
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
        .alert(isPresented: $viewModel.isAlertPresented) {
            Alert(title: Text(viewModel.errorAlertMessage ?? "There is some problem."))
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                toolbarCloseButton
            }
        }
        .navigationTitle("Enter Card")
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
                Text("Amount")
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
        VStack(alignment: .leading, spacing: 22) {
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
                title: "Number",
                placeHolder: "Required",
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

            if let cardBrand = viewModel.cardBrand {
                HStack(alignment: .top) {
                    Spacer()

                    cardBrand.icon
                        .resizable()
                        .frame(width: 45, height: 22)
                        .padding(.trailing)
                        .padding(.top)
                }
            }
        }
    }

    // MARK: Expiration Date
    var expirationDateTextField: some View {
        ZStack {
            DefaultTextField(
                text: $expirationDate,
                isEditing: $isExpirationDateTextFieldEditing,
                title: "Expires",
                placeHolder: "MM / YYYY",
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
            title: "CVV",
            placeHolder: "Security Code",
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
            title: "Card Holder Name",
            placeHolder: "Name",
            validator: viewModel.cardHolderNameValidator(_:)
        )
        .onChange(of: cardHolderName) { newValue in
            cardHolderName = newValue.uppercased()
        }
    }

    var bottomView: some View {
        VStack(spacing: 26) {
            nextButton

            FooterView()
                .padding(.bottom, 12)
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

                            Spacer()
                        }
                    }
                    Text("Next")
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
        .disabled(isDisabled)
    }

    var toolbarCloseButton: some View {
        Button(
            action: {
                presentationMode.wrappedValue.dismiss()
            },
            label: {
                Text("Close")
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
