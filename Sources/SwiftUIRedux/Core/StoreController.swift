//
//  File.swift
//  
//
//  Created by Paolo Moroni on 28/11/2019.
//

import Combine
import Foundation

public struct StoreController<State, Action, Mutation> {
    public let process: (Action, State) -> AnyPublisher<Mutation, Never>

    public init(process: @escaping (Action, State) -> AnyPublisher<Mutation, Never>) {
        self.process = process
    }
}

public protocol StoreControllerProtocol {
    associatedtype A
    associatedtype S
    associatedtype M

    func process(_ action: A, _ state: S) -> AnyPublisher<M, Never>
}
