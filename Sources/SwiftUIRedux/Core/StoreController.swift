//
//  File.swift
//  
//
//  Created by Paolo Moroni on 28/11/2019.
//

import Combine
import Foundation

public typealias StoreController<State, Action, Mutation> = (Action, State) -> AnyPublisher<Mutation, Never>

public enum StoreControllers {
}
