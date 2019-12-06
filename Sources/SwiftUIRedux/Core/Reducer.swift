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

public func map<State, Mutation, LocalState, LocalMutation>(
    _ reducer: @escaping (inout State, Mutation) -> Void,
    _ stateGetter: @escaping (LocalState) -> State,
    _ stateSetter: @escaping (inout State, LocalState) -> Void,
    _ mutationGetter: @escaping (LocalMutation) -> Mutation
) -> (inout LocalState, LocalMutation) -> Void {

    return { localState, localMutation in
        var state = stateGetter(localState)
        let mutation = mutationGetter(localMutation)

        reducer(&state, mutation)
        stateSetter(&state, localState)
    }
}

public func map<Action, State, Mutation, LocalAction, LocalState, LocalMutation>(
    _ storeController: @escaping (Action, State) -> AnyPublisher<Mutation, Never>,
    _ stateGetter: @escaping (LocalState) -> State,
    _ actionGetter: @escaping (LocalAction) -> Action,
    _ localMutationGetter: @escaping (Mutation) -> LocalMutation
) -> (LocalAction, LocalState) -> AnyPublisher<LocalMutation, Never> {

    return { localAction, localState in
        let action = actionGetter(localAction)
        let state = stateGetter(localState)

        return storeController(action, state)
            .map { localMutationGetter($0) }
            .eraseToAnyPublisher()
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

public func pullback<LocalAction, LocalState, LocalMutation, GlobalAction, GlobalState, GlobalMutation>(
    _ localStoreController: @escaping (LocalAction, LocalState) -> AnyPublisher<LocalMutation, Never>,
    _ stateKeyPath: WritableKeyPath<GlobalState, LocalState>,
    _ actionKeyPath: KeyPath<GlobalAction, LocalAction?>,
    _ mutationMapper: @escaping (LocalMutation) -> GlobalMutation
) -> (GlobalAction, GlobalState) -> AnyPublisher<GlobalMutation, Never> {
    return { action, state in
        guard let localAction = action[keyPath: actionKeyPath] else {
            return Empty<GlobalMutation, Never>(completeImmediately: false).eraseToAnyPublisher()
        }

        let localState = state[keyPath: stateKeyPath]
        return localStoreController(localAction, localState)
            .map { mutationMapper($0) }
            .eraseToAnyPublisher()
    }
}
