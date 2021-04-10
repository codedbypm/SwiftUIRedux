//
//  File.swift
//  
//
//  Created by Paolo Moroni on 11/12/2019.
//

import Foundation

/// A `Lens` is a type which encapsulates get and set operations of a `Part` over a `Whole`.
/// It is typically used with Swift structs.
public struct Lens<Whole, Part> {

    /// A closure that derives `Part` from `Whole`
    public let get: (Whole) -> Part

    /// A closure that sets `Part` on `Whole`
    public let set: (inout Whole, Part) -> Void

    /// Init a `Lens` with a getter and a setter closures.
    /// - Parameters:
    ///   - get: the closure acting as getter
    ///   - set: the closure acting as setter
    public init(
        get: @escaping (Whole) -> Part,
        set: @escaping (inout Whole, Part) -> Void
    ) {
        self.get = get
        self.set = set
    }

    /// Init a `Lens` using a keypath.
    /// - Parameter keyPath: the keypath indentifiying the `Part`
    init(keyPath: WritableKeyPath<Whole, Part>) {
        self = Lens<Whole, Part>(
            get: { $0[keyPath: keyPath] },
            set: { $0[keyPath: keyPath] = $1 }
        )
    }
}

public extension Lens {

    /// An operator that combines two `Lense` objects and returning a `Lens` whose `Part` is a tuple of the
    /// combined `Parts`.
    /// - Parameters:
    ///   - lhs: the lens operation on `PartA`
    ///   - rhs: the lens operation on `PartB`
    /// - Returns: a `Lens` where `Part = (PartA, PartB)`
    static func both<PartA, PartB>(
        _ lhs: Lens<Whole, PartA>,
        _ rhs: Lens<Whole, PartB>
    ) -> Lens<Whole, Part> where Part == (PartA, PartB) {
        return Lens<Whole, Part>(
            get: {
                (lhs.get($0), rhs.get($0))
            },
            set: { (whole: inout Whole, tuple) in
                let (partA, partB) = tuple
                lhs.set(&whole, partA)
                rhs.set(&whole, partB)
            }
        )
    }
}
