//
//  File.swift
//  
//
//  Created by Paolo Moroni on 28/11/2019.
//

import Combine
import Foundation

public struct StoreController<State, Action, Mutation> {
    let process: (Action, State) -> AnyPublisher<Mutation, Never>

    public init(process: @escaping (Action, State) -> AnyPublisher<Mutation, Never>) {
        self.process = process
    }
}

