//
//  File.swift
//  
//
//  Created by Paolo Moroni on 24/11/2019.
//

import Combine
import Foundation

public struct Reducer<State, Mutation> {
    public typealias Body = (inout State, Mutation) -> Void

    public let body: Body

    public init(reduce: @escaping Body) {
        self.body = reduce
    }
}

public extension Reducer {

    func pullback<GlobalState, GlobalMutation>(
        _ stateKeyPath: WritableKeyPath<GlobalState, State>,
        _ mutationKeyPath: KeyPath<GlobalMutation, Mutation?>
    ) -> Reducer<GlobalState, GlobalMutation> {
        return Reducer<GlobalState, GlobalMutation> { globalState, globalMutation in
            guard let mutation = globalMutation[keyPath: mutationKeyPath] else { return }

            self.body(&globalState[keyPath: stateKeyPath], mutation)
        }
    }

    func lift<GlobalState, GlobalMutation>(
        _ lens: Lens<GlobalState, State>,
        _ prism: Prism<GlobalMutation, Mutation>
    ) -> Reducer<GlobalState, GlobalMutation> {
        return Reducer<GlobalState, GlobalMutation> { globalState, globalMutation in
            guard let mutation = prism.tryGet(globalMutation) else { return }
            var state = lens.get(globalState)
            self.body(&state, mutation)
            lens.set(&globalState, state)
        }
    }

    static func combine<State, Mutation>(
        _ reducers: [Reducer<State, Mutation>]
    ) -> Reducer<State, Mutation> {
        return Reducer<State, Mutation> { (state, mutation) in
            reducers.forEach {
                $0.body(&state, mutation)
            }
        }
    }
}
