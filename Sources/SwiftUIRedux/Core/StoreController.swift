//
//  File.swift
//  
//
//  Created by Paolo Moroni on 28/11/2019.
//

import Combine
import Foundation

public struct StoreController<Action, Mutation> {
    public let effect: (Action) -> AnyPublisher<Mutation, Never>

    public init(effect: @escaping (Action) -> AnyPublisher<Mutation, Never>) {
        self.effect = effect
    }
}

public extension StoreController {

    func pullback<GlobalAction, GlobalMutation>(
        _ actionKeyPath: KeyPath<GlobalAction, Action?>,
        _ mutationMapper: @escaping (Mutation) -> GlobalMutation
    ) -> StoreController<GlobalAction, GlobalMutation> {

        return StoreController<GlobalAction, GlobalMutation> { globalAction in
            guard let localAction = globalAction[keyPath: actionKeyPath] else {
                return Empty<GlobalMutation, Never>(completeImmediately: false).eraseToAnyPublisher()
            }

            return self.effect(localAction)
                .map { mutationMapper($0) }
                .eraseToAnyPublisher()
        }
    }
    
    static func combine<Action, Mutation>(
        _ storeControllers: [StoreController<Action, Mutation>]
    ) -> StoreController<Action, Mutation> {
        return StoreController<Action, Mutation> { action in
            let initialResult = Empty<Mutation, Never>(completeImmediately: false).eraseToAnyPublisher()
            let publisher = storeControllers.reduce(initialResult) { (result, storeController) -> AnyPublisher<Mutation, Never> in
                return Publishers.Merge(result, storeController.effect(action)).eraseToAnyPublisher()
            }

            return publisher
                .eraseToAnyPublisher()
        }
    }
}

