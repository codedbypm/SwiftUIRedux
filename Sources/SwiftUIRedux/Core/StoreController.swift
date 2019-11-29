//
//  File.swift
//  
//
//  Created by Paolo Moroni on 28/11/2019.
//

import Combine
import Foundation

public typealias StoreController<Action, Mutation> = (Action) -> AnyPublisher<Mutation, Never>

public enum StoreControllers {
}

//public protocol StoreController {
//    associatedtype Action
//    associatedtype Mutation
//
//    func storeResponse(to action: Action) -> AnyPublisher<Mutation, Never>
//}
//
//public enum StoreControllers {
//}
