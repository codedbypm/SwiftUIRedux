//
//  File.swift
//  
//
//  Created by Paolo Moroni on 16/11/2019.
//

import Combine
import Foundation
import os.log

public class Store<State, A: Action>: ObservableObject {

    // MARK: - Public properties

    @Published public private(set) var state: State

    // MARK: - Private properties

//    public private(set) var cancellables = Set<AnyCancellable>()

    private let reducer: AnyReducer<State, A.Mutation>

    // MARK: - Inits

    public init(state: State, reducer: AnyReducer<State, A.Mutation>) {
        self.state = state
        self.reducer = reducer
    }

    // MARK: - Public methods

    public func send(_ action: A) {
        os_log(
            .info,
            log: .redux,
            "[%@] Action: %@", String(describing: self), String(describing: action)
        )

        let publisher = action.reaction.sink { mutation in
            print(mutation)
        }

//        action
//            .reaction
//            .receive(on: RunLoop.main)
//            .sink { self.reducer.reduce(&self.state, $0) }
//            .store(in: &cancellables)
    }
}

extension Store: CustomStringConvertible {

    public var description: String {
        return "Store"
    }
}
