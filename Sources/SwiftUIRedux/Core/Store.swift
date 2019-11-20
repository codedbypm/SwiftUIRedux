//
//  File.swift
//  
//
//  Created by Paolo Moroni on 16/11/2019.
//

import Combine
import Foundation
import os.log

public class Store<S, A>: ObservableObject {

    public typealias Reducer = (inout S, A) -> Void

    // MARK: - Public properties

    @Published public var state: S

    // MARK: - Private properties

    private var cancellables: Set<AnyCancellable> = []
    private let reducer: Reducer

    // MARK: - Init

    public init(state: S, reducer: @escaping Reducer) {
        self.state = state
        self.reducer = reducer
    }

    deinit {
        print("Deinit")
    }

    // MARK: - Public methods

    public func send(_ action: A) {
//        os_log(
//            .info,
//            log: .redux,
//            "[%@] Action: %@", String(describing: self), String(describing: action)
//        )

//        self.reducer(&state, action)
    }
}
