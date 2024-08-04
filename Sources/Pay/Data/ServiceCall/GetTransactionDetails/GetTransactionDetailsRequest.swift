//
//  GetTransactionDetailsRequest.swift
//  Pay
//
//  Created by Giga Khizanishvili on 16.07.24.
//

struct GetTransactionDetailsRequest: Request {
    var path: String {
        "v2/payment/payment-details"
    }

    var queryParameters: [String : String]? {
        [
            "transactionId": transactionId
        ]
    }

    var method: NetworkMethod { .get }

    private let transactionId: String

    // MARK: - Init
    init(transactionId: String) {
        self.transactionId = transactionId
    }
}
