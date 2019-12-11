//
//  File.swift
//  
//
//  Created by Paolo Moroni on 11/12/2019.
//

import Foundation

public struct Lens<Whole, Part> {
    public let get: (Whole) -> Part
    public let set: (inout Whole, Part) -> Void

    public init(
        get: @escaping (Whole) -> Part,
        set: @escaping (inout Whole, Part) -> Void
    ) {
        self.get = get
        self.set = set
    }
}

public extension WritableKeyPath {

    var lens: Lens<Root, Value> {
        return Lens<Root, Value>(
            get: { $0[keyPath: self] },
            set: { $0[keyPath: self] = $1 }
        )
    }
}

public extension Lens {

    static func both<PartA, PartB>(
        _ lhs: Lens<Whole, PartA>,
        _ rhs: Lens<Whole, PartB>
    ) -> Lens<Whole, (PartA, PartB)> {

        return Lens<Whole, (PartA, PartB)>(
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
