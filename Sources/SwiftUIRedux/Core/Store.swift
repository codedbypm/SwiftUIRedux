//
//  File.swift
//  
//
//  Created by Paolo Moroni on 16/11/2019.
//

import Combine
import Foundation
import os.log

public final class Store<State, Controller: StoreController>: ObservableObject {

    // MARK: - Public properties

    @Published public private(set) var state: State

    // MARK: - Private properties

    public private(set) var cancellables = Set<AnyCancellable>()

    public let reducer: Reducer<State, Controller.Mutation>

    private let controller: Controller

    // MARK: - Inits

    public init(
        state: State,
        reducer: @escaping Reducer<State, Controller.Mutation>,
        controller: Controller
    ) {
        self.state = state
        self.reducer = reducer
        self.controller = controller
    }

    // MARK: - Public methods

    public func send(_ action: Controller.Action) {
        os_log(
            .info,
            log: .redux,
            "Action: %@", String(describing: action)
        )

        controller
            .storeResponse(to: action)
            .receive(on: RunLoop.main)
            .sink { self.reducer(&self.state, $0) }
            .store(in: &cancellables)
    }
}

//extension StoreController: StoreResponse {
//
//    public func storeResponse(to action: Action) -> AnyPublisher<Mutation, Never> {
//        return Fail(outputType: Mutation, failure: Error).eraseToAnyPublisher()
//    }
//}
