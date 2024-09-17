//
//  GetUrlPathActionUseCase.swift
//
//
//  Created by David Berdznishvili on 17.09.24.
//

import Foundation

protocol GetUrlPathActionUseCase {
    /// Returns nil if redirect is not terminating
    func execute(url: URL) -> PaymentCompletionType?
}

final class DefaultGetUrlPathActionUseCase: GetUrlPathActionUseCase {
    func execute(url: URL) -> PaymentCompletionType? {
        guard
            let redirectUrlHost = url.host,
            hosts.contains(redirectUrlHost)
        else {
            return nil
        }
        
        if url.pathComponents.contains(TerminatingPaths.success) {
            return .success
        } else if url.pathComponents.contains(TerminatingPaths.fail) {
            return .fail
        } else if url.pathComponents.contains(TerminatingPaths.inProgress) {
            return .inProgress
        } else {
            return nil
        }
    }
}
 
private extension DefaultGetUrlPathActionUseCase {
    var hosts: [String] {
        [
            "paygate.payze.dev",
            "paygate.payze.io",
            "paygate.payze.uz"
        ]
    }
    
    enum TerminatingPaths {
        static let success = "success"
        static let fail = "fail"
        static let inProgress = "inProgress"
    }
}
