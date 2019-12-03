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

public func combine<State, Mutation>(
    _ reducers: [(inout State, Mutation) -> Void]
) -> (inout State, Mutation) -> Void {
    return { (state, mutation) in
        reducers.forEach {
            $0(&state, mutation)
        }
    }
}

public func combine<Action, State, Mutation>(
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

public func pullback<LocalState, GlobalState, LocalMutation, GlobalMutation>(
    _ reducer: @escaping (inout LocalState, LocalMutation) -> Void,
    _ stateKeyPath: WritableKeyPath<GlobalState, LocalState>,
    _ mutationKeyPath: KeyPath<GlobalMutation, LocalMutation?>
) -> (inout GlobalState, GlobalMutation) -> Void {
    return { state, mutation in
        guard let localMutation = mutation[keyPath: mutationKeyPath] else { return }

        reducer(&state[keyPath: stateKeyPath], localMutation)
    }
}
