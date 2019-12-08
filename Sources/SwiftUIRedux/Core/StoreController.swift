//
//  File.swift
//  
//
//  Created by Paolo Moroni on 28/11/2019.
//

import Combine
import Foundation

public struct StoreController<State, Action, Mutation> {
    public let effect: (Action, State) -> AnyPublisher<Mutation, Never>

    public init(effect: @escaping (Action, State) -> AnyPublisher<Mutation, Never>) {
        self.effect = effect
    }
}

public extension StoreController {

    func pullback<GlobalAction, GlobalState, GlobalMutation>(
        _ stateKeyPath: WritableKeyPath<GlobalState, State>,
        _ actionKeyPath: KeyPath<GlobalAction, Action?>,
        _ mutationMapper: @escaping (Mutation) -> GlobalMutation
    ) -> StoreController<GlobalState, GlobalAction, GlobalMutation> {

        return StoreController<GlobalState, GlobalAction, GlobalMutation> { globalAction, globalState in
            guard let localAction = globalAction[keyPath: actionKeyPath] else {
                return Empty<GlobalMutation, Never>(completeImmediately: false).eraseToAnyPublisher()
            }

            let localState = globalState[keyPath: stateKeyPath]
            return self.effect(localAction, localState)
                .map { mutationMapper($0) }
                .print("Pulledback")
                .eraseToAnyPublisher()
        }
    }

    func map<LocalAction, LocalState, LocalMutation>(
        _ stateGetter: @escaping (LocalState) -> State,
        _ actionGetter: @escaping (LocalAction) -> Action,
        _ localMutationGetter: @escaping (Mutation) -> LocalMutation?
    ) -> StoreController<LocalState, LocalAction, LocalMutation> {

        return StoreController<LocalState, LocalAction, LocalMutation> { localAction, localState in
            let action = actionGetter(localAction)
            let state = stateGetter(localState)

            return self.effect(action, state)
                .compactMap { localMutationGetter($0) }
                .print("Mapped")
                .eraseToAnyPublisher()
        }
    }

    static func combine<Action, State, Mutation>(
        _ storeControllers: [StoreController<State, Action, Mutation>]
    ) -> StoreController<State, Action, Mutation> {
        return StoreController<State, Action, Mutation> { (action, state) in
            let initialResult = Empty<Mutation, Never>(completeImmediately: false).eraseToAnyPublisher()
            let publisher = storeControllers.reduce(initialResult) { (result, storeController) -> AnyPublisher<Mutation, Never> in
                return Publishers.Merge(result, storeController.effect(action, state)).eraseToAnyPublisher()
            }

            return publisher
                .print("Combined")
                .eraseToAnyPublisher()
        }
    }
}

