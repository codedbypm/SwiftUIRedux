//
//  File.swift
//  
//
//  Created by Paolo Moroni on 16/11/2019.
//

import Combine
import Foundation
import os.log

public final class Store<State, R: Reactor>: ObservableObject {

    // MARK: - Public properties

    @Published public private(set) var state: State

    // MARK: - Private properties

    public private(set) var cancellables = Set<AnyCancellable>()

    private let reducer: AnyReducer<State, R.Mutation>
    private let reactor: R

    // MARK: - Inits

    public init(state: State, reactor: R, reducer: AnyReducer<State, R.Mutation>) {
        self.state = state
        self.reactor = reactor
        self.reducer = reducer
    }

    // MARK: - Public methods

    public func send(_ action: R.Action) {
        os_log(
            .info,
            log: .redux,
            "[%@] Action: %@", String(describing: self), String(describing: action)
        )

        reactor.reaction(for: action)
            .receive(on: RunLoop.main)
            .sink { self.reducer.reduce(&self.state, $0) }
            .store(in: &cancellables)
    }
}

extension Store: CustomStringConvertible {

    public var description: String {
        return "Store"
    }
}
