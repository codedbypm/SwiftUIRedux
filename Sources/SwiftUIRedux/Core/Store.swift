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

    // MARK: - Private properties

    public private(set) var cancellables = Set<AnyCancellable>()

    public let reducer: Reducer<State, Mutation>

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

    // MARK: - Public methods

    public func send(_ action: Action) {
        os_log(
            .info,
            log: .redux,
            "Action: %@", String(describing: action)
        )

        controller.process(action, state)
            .receive(on: RunLoop.main)
            .sink { self.reducer.reduce(&self.state, $0) }
            .store(in: &cancellables)
    }
}
