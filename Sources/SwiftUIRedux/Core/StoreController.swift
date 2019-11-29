//
//  File.swift
//  
//
//  Created by Paolo Moroni on 28/11/2019.
//

import Combine
import Foundation

public protocol StoreController {
    associatedtype Action
    associatedtype Mutation

    func storeResponse(to action: Action) -> Future<Mutation, Never>
}
