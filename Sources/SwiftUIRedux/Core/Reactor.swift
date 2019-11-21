//
//  File.swift
//  
//
//  Created by Paolo Moroni on 21/11/2019.
//

import Combine
import Foundation

public protocol Reactor {
    associatedtype Action
    associatedtype Mutation

    func reaction(for: Action) -> AnyPublisher<Mutation, Never>
}
