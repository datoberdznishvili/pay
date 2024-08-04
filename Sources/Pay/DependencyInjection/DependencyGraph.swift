//
//  DependencyGraph.swift
//  Pay
//
//  Created by Giga Khizanishvili on 04.08.24.
//

import Foundation

final class DependencyGraph {
    // MARK: - Properties
    static let shared = DependencyGraph()

    private var dependencies: [String: Any] = [:]

    // MARK: - Init
    private init() { }
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
