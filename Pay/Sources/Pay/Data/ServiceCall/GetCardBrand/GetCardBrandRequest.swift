//
//  GetCardBrandRequest.swift
//  Pay
//
//  Created by Giga Khizanishvili on 12.07.24.
//

struct GetCardBrandRequest: Request {
    var path: String {
        "card/brand"
    }

    var queryParameters: [String : String]? {
        [
            "bin": bin
        ]
    }

    var method: NetworkMethod { .get }

    private let bin: String

    // MARK: - Init
    init(bin: String) {
        self.bin = bin
    }
}
