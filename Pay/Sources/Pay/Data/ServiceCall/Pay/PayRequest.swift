//
//  PayRequest.swift
//  Pay
//
//  Created by Giga Khizanishvili on 12.07.24.
//

struct PayRequest: Request {
    var path: String {
        "v2/payment/pay" // TODO: v2?
    }

    var method: NetworkMethod { .post }

    let bodyParameters: [String : Any]?

    init(parameters: PayParameters) {
        self.bodyParameters = [
            "transactionId": parameters.transactionId,
            "number": parameters.number,
            "cardHolder": parameters.cardHolder,
            "expirationDate": parameters.expirationDate,
            "securityNumber": parameters.securityNumber,
        ]
    }
}
