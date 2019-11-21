//
//  File.swift
//  
//
//  Created by Paolo Moroni on 16/11/2019.
//

public protocol Reducer {
    associatedtype State
    associatedtype Mutation

    func reduce(state: inout State, mutation: Mutation)
}

public extension Reducer {

    func eraseToAnyReducer() -> AnyReducer<State, Mutation> {
        return AnyReducer(reducer: self)
    }
}

public struct AnyReducer<State, Mutation> {

    public let reduce: (inout State, Mutation) -> Void

    public init<R: Reducer>(reducer: R) where R.State == State, R.Mutation == Mutation {
        self.reduce = reducer.reduce
    }
}
