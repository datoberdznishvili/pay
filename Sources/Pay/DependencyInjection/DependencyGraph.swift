//
//  DependencyGraph.swift
//  Pay
//
//  Created by Giga Khizanishvili on 04.08.24.
//

import Foundation

public func initialize() {
    DependencyGraph.registerAllServices()
}

final class DependencyGraph {
    // MARK: - Properties
    static let shared = DependencyGraph()

    private var dependencies: [String: Any] = [:]

    // MARK: - Init
    private init() { }
}

// MARK: - Public API
extension DependencyGraph {
    static func registerAllServices() {
        DependencyGraph.shared.register(
            DefaultNetworkService(
                baseURL: URL(string: "https://paygate.payze.dev")!
            ),
            for: NetworkService.self
        )

        DependencyGraph.shared.register(
            DefaultPayUseCase(),
            for: PayUseCase.self
        )
        DependencyGraph.shared.register(
            LocalGetCardBrandUseCase(),
            for: GetCardBrandUseCase.self
        )
        DependencyGraph.shared.register(
            DefaultGetTransactionDetailsUseCase(),
            for: GetTransactionDetailsUseCase.self
        )

        DependencyGraph.shared.register(
            DefaultCardNumberFormatter(),
            for: CardNumberFormatter.self
        )
    }
}

// MARK: - Internal API
extension DependencyGraph {
    func register<T>(_ dependency: T, for type: T.Type) {
        let key = String(describing: type)
        dependencies[key] = dependency
    }
}

// MARK: - Fileprivate API
fileprivate extension DependencyGraph {
    func resolve<T>() -> T {
        let key = String(describing: T.self)
        return dependencies[key] as! T
    }
}

// MARK: - Injected
@propertyWrapper
struct Injected<T> {
    private var value: T

    var wrappedValue: T {
        get {
            return value
        }
        set {
            value = newValue
        }
    }

    var projectedValue: T {
        DependencyGraph.shared.resolve()
    }

    init() {
        self.value = DependencyGraph.shared.resolve()
    }
}
