//
//  File.swift
//  
//
//  Created by Paolo Moroni on 16/11/2019.
//

import Combine
import Foundation
import os.log

public final class Store<State, Action, Mutation>: ObservableObject {

    // MARK: - Public properties

    @Published public private(set) var state: State

    public let reducer: Reducer<State, Mutation>

    public private(set) var cancellables = Set<AnyCancellable>()

    // MARK: - Private properties

    private let controller: StoreController<Action, Mutation>

    // MARK: - Inits

    public init(
        state: State,
        reducer: Reducer<State, Mutation>,
        controller: StoreController<Action, Mutation>
    ) {
        self.state = state
        self.reducer = reducer
        self.controller = controller
    }

    deinit {
        print("deinit of \(self)")
    }
    // MARK: - Public methods

    public func send(_ action: Action) {
        os_log(
            .info,
            log: .redux,
            "Action: %@", String(describing: action)
        )

        controller
            .body(action)
            .receive(on: RunLoop.main)
            .sink { self.reducer.body(&self.state, $0) }
            .store(in: &cancellables)
    }
}

public extension Store {

    func map<LocalState, LocalAction, LocalMutation>(
        localStateKeyPath: WritableKeyPath<State, LocalState>,
        actionGetter: @escaping (LocalAction) -> Action,
        mutationGetter: @escaping (LocalMutation) -> Mutation,
        localMutationGetter: @escaping (Mutation) -> LocalMutation?
    ) -> Store<LocalState, LocalAction, LocalMutation> {

        let localReducer: Reducer<LocalState, LocalMutation> = .init { localState, localMutation in
            /// Get the mutation
            let mutation: Mutation = mutationGetter(localMutation)

            /// Reduce the Store state
            self.reducer.body(&self.state, mutation)

            /// Change the localState
            localState = self.state[keyPath: localStateKeyPath]
        }

        let localStoreController: StoreController<LocalAction, LocalMutation> = .init { (localAction) -> AnyPublisher<LocalMutation, Never> in

            /// Get the action
            let action: Action = actionGetter(localAction)

            /// Get the Publisher
            let publisher = self.controller.body(action)

            /// Map the publisher and return
            return publisher
                .compactMap { localMutationGetter($0) }
                .eraseToAnyPublisher()
        }

        return Store<LocalState, LocalAction, LocalMutation>(
            state: state[keyPath: localStateKeyPath],
            reducer: localReducer,
            controller: localStoreController
        )
    }
}
