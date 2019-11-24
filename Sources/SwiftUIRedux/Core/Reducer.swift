//
//  File.swift
//  
//
//  Created by Paolo Moroni on 24/11/2019.
//

import Foundation

public typealias Reducer<State, Mutation> = (inout State, Mutation) -> Void

public enum Reducers {
}
