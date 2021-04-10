//
//  File.swift
//  
//
//  Created by Paolo Moroni on 11/12/2019.
//

import Foundation

/// A `Prism` is a type which encapsulates get and set operations of a `Part` over a `Whole`.
/// It is typically used with Swift enums with associated values.
public struct Prism<Whole, Part> {

    /// A closure that derives the associated type `Part` of  a `Whole` case. The closure returns an
    /// `Optional<Part>` since the `Part` can only be retrieved if `Whole` is in the right case.
    /// If not, we returns nil.
    public let tryGet: (Whole) -> Part?

    /// A closure that sets `Part` on `Whole`. The closure returns `Whole` by setting the associated value `Part`
    /// on a target enum case.
    public let inject: (Part) -> Whole


    /// Default initializer
    /// - Parameters:
    ///   - tryGet: the closure returning the enum case associated value
    ///   - inject: the closure injecting the enum case associated value
    public init(
        tryGet: @escaping (Whole) -> Part?,
        inject: @escaping (Part) -> Whole
    ) {
        self.tryGet = tryGet
        self.inject = inject
    }
}
