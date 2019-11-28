//
//  File.swift
//  
//
//  Created by Paolo Moroni on 28/11/2019.
//

import Combine
import Foundation

public protocol Effect {
    associatedtype State
    associatedtype Mutation

    func reaction(state: State) -> AnyPublisher<Mutation, Never>
}
