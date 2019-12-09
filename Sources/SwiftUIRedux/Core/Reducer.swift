//
//  File.swift
//  
//
//  Created by Paolo Moroni on 24/11/2019.
//

import Combine
import Foundation

public struct Reducer<State, Mutation> {
    let reduce: (inout State, Mutation) -> Void

    public init(reduce: @escaping (inout State, Mutation) -> Void) {
        self.reduce = reduce
    }
}

public extension Reducer {

    func pullback<GlobalState, GlobalMutation>(
        _ stateKeyPath: WritableKeyPath<GlobalState, State>,
        _ mutationKeyPath: KeyPath<GlobalMutation, Mutation?>
    ) -> Reducer<GlobalState, GlobalMutation> {
        return Reducer<GlobalState, GlobalMutation> { state, mutation in
            guard let localMutation = mutation[keyPath: mutationKeyPath] else { return }

            self.reduce(&state[keyPath: stateKeyPath], localMutation)
        }
    }

    func map<LocalState, LocalMutation>(
        stateGetter: @escaping (LocalState) -> State,
        stateSetter: @escaping (inout State) -> Void,
        localStateKeyPath: WritableKeyPath<State, LocalState>,
        mutationGetter: @escaping (LocalMutation) -> Mutation
    ) -> Reducer<LocalState, LocalMutation> {
        return Reducer<LocalState, LocalMutation> { localState, localMutation in
            var state = stateGetter(localState)
            let mutation = mutationGetter(localMutation)

            self.reduce(&state, mutation)

            localState = state[keyPath: localStateKeyPath]
            state[keyPath: localStateKeyPath] = localState
            
            // I WAS HERE: trying to propagate the localState change to the global state
        }
    }

    static func combine<State, Mutation>(
        _ reducers: [Reducer<State, Mutation>]
    ) -> Reducer<State, Mutation> {
        return Reducer<State, Mutation> { (state, mutation) in
            reducers.forEach {
                $0.reduce(&state, mutation)
            }
        }
    }
}
