//
//  File.swift
//  
//
//  Created by Paolo Moroni on 24/11/2019.
//

import Combine
import Foundation

public typealias Reactor<State, Action, Mutation> = (Action, State) -> AnyPublisher<Mutation, Never>

public enum Reactors {
}
