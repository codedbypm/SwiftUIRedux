//
//  File.swift
//  
//
//  Created by Paolo Moroni on 16/11/2019.
//

import Combine
import Foundation
import os.log

public typealias Reactor<State, Action, Mutation> = (Action, State) -> AnyPublisher<Mutation, Never>

public typealias Reducer<State, Mutation> = (inout State, Mutation) -> Void

public final class Store<State, Action, Mutation>: ObservableObject {

    // MARK: - Public properties

    @Published public private(set) var state: State

    // MARK: - Private properties

    public private(set) var cancellables = Set<AnyCancellable>()

    public let reducer: Reducer<State, Mutation>
    private let reactor: Reactor<State, Action, Mutation>

    // MARK: - Inits

    public init(
        state: State,
        reactor: @escaping Reactor<State, Action, Mutation>,
        reducer: @escaping Reducer<State, Mutation>
    ) {
        self.state = state
        self.reactor = reactor
        self.reducer = reducer
    }

    // MARK: - Public methods

    public func send(_ action: Action) {
        os_log(
            .info,
            log: .redux,
            "Action: %@", String(describing: action)
        )

        reactor(action, state)
            .receive(on: RunLoop.main)
            .sink { self.reducer(&self.state, $0) }
            .store(in: &cancellables)
    }
}
