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

    private let controller: StoreController<State, Action, Mutation>

    // MARK: - Inits

    public init(
        state: State,
        reducer: Reducer<State, Mutation>,
        controller: StoreController<State, Action, Mutation>
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
            .effect(action, state)
            .print("Store")
            .receive(on: RunLoop.main)
            .breakpoint(receiveOutput: { mutation -> Bool in
                return true
            })
            .sink {
                self.reducer.reduce(&self.state, $0)
            }
            .store(in: &cancellables)
    }
}

public extension Store {

    func map<LocalState, LocalAction, LocalMutation>(
        initialState: LocalState,
        stateGetter: @escaping (LocalState) -> State,
        stateSetter: @escaping (inout State, LocalState) -> Void,
        actionGetter: @escaping (LocalAction) -> Action,
        mutationGetter: @escaping (LocalMutation) -> Mutation,
        localMutationGetter: @escaping (Mutation) -> LocalMutation?
    ) -> Store<LocalState, LocalAction, LocalMutation> {

        let localReducer = reducer.map(
            stateGetter,
            stateSetter,
            mutationGetter
        )

        let localController = controller.map(
            stateGetter,
            actionGetter,
            localMutationGetter
        )

        return Store<LocalState, LocalAction, LocalMutation>(
            state: initialState,
            reducer: localReducer,
            controller: localController
        )
    }
}
