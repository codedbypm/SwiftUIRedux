//
//  File.swift
//  
//
//  Created by Paolo Moroni on 24/11/2019.
//

import Foundation

public typealias Reducer<State, Mutation> = (inout State, Mutation) -> Void

public enum Reducers {
}

public extension Reducers {

    /// This function enables `pulling back` a reducer, i.e. expressing a more local reducer using a broader higher
    /// level reducer.
    ///
    /// Since a `Reducer` is generic compared to the `State` and `Mutation`, the pullback function accepts two
    /// extra parameters which describe the conversion to apply when expressing the `LocalState` using `State`
    /// and the `LocalMutation` using a `Mutation`.
    ///
    /// - Parameters:
    ///   - localReducer: the reducer operating on a local context
    ///   - stateKeyPath: the transformation to follow when going from `State` to `LocalState`
    ///   - mutationKeyPath: the transformation to follow when going from `Mutation` to `LocalMutation`
    static func pullback<LocalState, LocalMutation, State, Mutation>(
        _ localReducer: @escaping Reducer<LocalState, LocalMutation>,
        stateKeyPath: WritableKeyPath<State, LocalState>,
        mutationKeyPath: KeyPath<Mutation, LocalMutation?>
    ) -> Reducer<State, Mutation> {

        return { state, mutation in
            guard let localMutation = mutation[keyPath: mutationKeyPath] else { return }

            var localState = state[keyPath: stateKeyPath]
            localReducer(&localState, localMutation)
            state[keyPath: stateKeyPath] = localState
        }
    }

    /// A function that combines an array of `Reducer` instances in one single `Reducer`
    ///
    /// - Parameter reducers: the arary of `Reducer`s to combine together
    static func combine<State, Mutation>(
        _ reducers: [Reducer<State, Mutation>]
    ) -> Reducer<State, Mutation> {
        return { state, mutation in
            reducers.forEach {
                $0(&state, mutation)
            }
        }
    }
}
