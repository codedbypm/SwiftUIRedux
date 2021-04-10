//
//  File.swift
//  
//
//  Created by Paolo Moroni on 16/11/2019.
//

import Combine
import Foundation
import os.log

/// A class which owns the state  and allows modifications to it by means of actions
public final class Store<State, Action, Mutation>: ObservableObject {

    // MARK: - Public properties

    /// The structure modeling the state
    @Published
    public internal(set) var state: State

    // MARK: - Init

    public init(
        state: State,
        reducer: Reducer<State, Mutation>,
        controller: StoreController<Action, Mutation>
    ) {
        self.state = state
        self.reducer = reducer
        self.controller = controller
    }

    // MARK: - Public methods

    /// A method used to inform the store that some events that might change the state have occured.
    /// - Parameter action: the action to send to the store
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

    // MARK: - Internal properties

    internal let reducer: Reducer<State, Mutation>

    internal let controller: StoreController<Action, Mutation>

    // MARK: - Private properties

    private var cancellables = Set<AnyCancellable>()

}
