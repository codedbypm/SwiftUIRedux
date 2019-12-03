//
//  File.swift
//  
//
//  Created by Paolo Moroni on 24/11/2019.
//

import Combine
import Foundation

public struct Reducer<State, Mutation> {
    let reduce: (inout State, Mutation) -> Void

    public init(reduce: @escaping (inout State, Mutation) -> Void) {
        self.reduce = reduce
    }
}

public extension Reducer {

    /// This function enables `pulling back` a reducer, i.e. expressing a more local reducer using a broader higher
    /// level reducer.
    ///
    /// - Parameters:
    ///   - localReducer: the reducer operating on a local context
    ///   - stateKeyPath: the transformation to follow when going from `State` to `LocalState`
    ///   - mutationKeyPath: the transformation to follow when going from `Mutation` to `LocalMutation`
    func pullBack<ToState, ToMutation>(
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

    static func combine<State, Mutation>(
        _ reducers: [(inout State, Mutation) -> Void]
    ) -> (inout State, Mutation) -> Void {
        return { (state, mutation) in
            reducers.forEach {
                $0(&state, mutation)
            }
        }
    }

    func combine<State, Mutation>(
        _ reducers: [(inout State, Mutation) -> Void]
    ) -> (inout State, Mutation) -> Void {
        return { (state, mutation) in
            reducers.forEach {
                $0(&state, mutation)
            }
        }
    }

    func combine<Action, State, Mutation>(
        _ storeControllers: [(Action, State) -> AnyPublisher<Mutation, Never>]
    ) -> (Action, State) -> AnyPublisher<Mutation, Never> {
        return { (action, state) in
            let initialResult = Empty<Mutation, Never>(completeImmediately: false).eraseToAnyPublisher()
            let publisher = storeControllers.reduce(initialResult) { (result, storeController) -> AnyPublisher<Mutation, Never> in
                return Publishers.Merge(result, storeController(action, state)).eraseToAnyPublisher()
            }

            return publisher.eraseToAnyPublisher()
        }
    }

    func pullback<LocalState, GlobalState, LocalMutation, GlobalMutation>(
        _ reducer: @escaping (inout LocalState, LocalMutation) -> Void,
        _ stateKeyPath: WritableKeyPath<GlobalState, LocalState>,
        _ mutationKeyPath: KeyPath<GlobalMutation, LocalMutation?>
    ) -> (inout GlobalState, GlobalMutation) -> Void {
        return { state, mutation in
            guard let localMutation = mutation[keyPath: mutationKeyPath] else { return }

            reducer(&state[keyPath: stateKeyPath], localMutation)
        }
    }
}
