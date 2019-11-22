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
    associatedtype State
    
    func reaction(for: Action, state: State) -> AnyPublisher<Mutation, Never>
}
