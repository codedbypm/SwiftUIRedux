//
//  File.swift
//  
//
//  Created by Paolo Moroni on 16/11/2019.
//

import Combine
import Foundation
import os.log

public final class Store<State, Action: Effect>: ObservableObject where State == Action.State {

    // MARK: - Public properties

    @Published public private(set) var state: State

    // MARK: - Private properties

    public private(set) var cancellables = Set<AnyCancellable>()

    public let reducer: Reducer<State, Action.Mutation>

    // MARK: - Inits

    public init(
        state: State,
        reducer: @escaping Reducer<State, Action.Mutation>
    ) {
        self.state = state
        self.reducer = reducer
    }

    // MARK: - Public methods

    public func send(_ action: Action) {
        os_log(
            .info,
            log: .redux,
            "Action: %@", String(describing: action)
        )

        action.reaction(state: state)
            .receive(on: RunLoop.main)
            .sink { self.reducer(&self.state, $0) }
            .store(in: &cancellables)
    }
}
