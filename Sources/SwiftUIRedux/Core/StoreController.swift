//
//  File.swift
//  
//
//  Created by Paolo Moroni on 28/11/2019.
//

import Combine
import Foundation

public struct StoreController<State, Action, Mutation> {
    public let effect: (Action, State) -> AnyPublisher<Mutation, Never>

    public init(effect: @escaping (Action, State) -> AnyPublisher<Mutation, Never>) {
        self.effect = effect
    }
}
