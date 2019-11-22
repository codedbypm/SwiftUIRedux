//
//  File.swift
//  
//
//  Created by Paolo Moroni on 16/11/2019.
//

import Combine
import Foundation
import os.log

public final class Store<R: Reactor>: ObservableObject {

    // MARK: - Public properties

    @Published public private(set) var state: R.State

    // MARK: - Private properties

    public private(set) var cancellables = Set<AnyCancellable>()

    private let reducer: AnyReducer<R.State, R.Mutation>
    private let reactor: R

    // MARK: - Inits

    public init(state: R.State, reactor: R, reducer: AnyReducer<R.State, R.Mutation>) {
        self.state = state
        self.reactor = reactor
        self.reducer = reducer
    }

    // MARK: - Public methods

    public func send(_ action: R.Action) {
        os_log(
            .info,
            log: .redux,
            "Action: %@", String(describing: action)
        )

        reactor.reaction(for: action, state: state)
            .receive(on: RunLoop.main)
            .sink { self.reducer.reduce(&self.state, $0) }
            .store(in: &cancellables)
    }
}
