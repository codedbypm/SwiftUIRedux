//
//  File.swift
//  
//
//  Created by Paolo Moroni on 16/11/2019.
//

import Foundation
import Combine

public protocol Reactor {
    associatedtype Action
    associatedtype Mutation

    func react(to _: Action) -> AnyPublisher<Mutation, Never>
}
