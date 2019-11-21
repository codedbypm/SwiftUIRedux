//
//  File.swift
//  
//
//  Created by Paolo Moroni on 21/11/2019.
//

import Combine
import Foundation

public protocol Action {
    associatedtype Mutation

    var reaction: AnyPublisher<Mutation, Never> { get }
}
