//
//  File.swift
//  
//
//  Created by Paolo Moroni on 16/11/2019.
//

public protocol Reducer {
    associatedtype State
    associatedtype Mutation

    func reduce(_ state: inout State, mutation: Mutation)
}
