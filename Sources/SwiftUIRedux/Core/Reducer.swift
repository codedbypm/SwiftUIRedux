//
//  File.swift
//  
//
//  Created by Paolo Moroni on 24/11/2019.
//

import Foundation

public struct Reducer<State, Mutation> {
    let reduce: (inout State, Mutation) -> Void
}

public extension Reducer {

    /// This function enables `pulling back` a reducer, i.e. expressing a more local reducer using a broader higher
    /// level reducer.
    ///
    /// - Parameters:
    ///   - localReducer: the reducer operating on a local context
    ///   - stateKeyPath: the transformation to follow when going from `State` to `LocalState`
    ///   - mutationKeyPath: the transformation to follow when going from `Mutation` to `LocalMutation`
    func pullback<ToState, ToMutation>(
        stateKeyPath: WritableKeyPath<ToState, State>,
        mutationKeyPath: KeyPath<ToMutation, Mutation?>
    ) -> Reducer<ToState, ToMutation> {

        return .init { toState, toMutation in
            guard let fromMutation = toMutation[keyPath: mutationKeyPath] else { return }

            var fromState = toState[keyPath: stateKeyPath]
            self.reduce(&fromState, fromMutation)
            toState[keyPath: stateKeyPath] = fromState
        }
    }

    func push<ToState, ToMutation>(
        stateKeyPath: WritableKeyPath<ToState, State>
    ) -> Reducer<ToState, ToMutation> {

        return .init { toState, toMutation in

        }
    }

    /// A function that combines an array of `Reducer` instances in one single `Reducer`
    ///
    /// - Parameter reducers: the arary of `Reducer`s to combine together
    static func combine<State, Mutation>(
        _ reducers: [Reducer<State, Mutation>]
    ) -> Reducer<State, Mutation> {
        return .init { (state, mutation) in
            reducers.forEach {
                $0.reduce(&state, mutation)
            }
        }
    }
}
