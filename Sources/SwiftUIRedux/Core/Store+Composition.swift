// 
// Project:  SwiftUIRedux
// Copyright © 2021 codedby.pm. All rights reserved.
//

import Foundation

public extension Store {

    /// A method that transforms the receiver into a new store responsible for a portion of the receiver's `state`
    /// - Parameters:
    ///   - stateLens: the `Lens` used to derive `LocalState` from `State`
    ///   - actionPrism: the `Prism` used to get `LocalAction` from `Acion` or to transform a
    ///   `LocalAction`  into an `Action`.
    ///   - mutationPrism: the `Prism` used to get `LocalMutation` from `Mutation` or to transform a
    ///    `LocalMutation` into  a `Mutation`.
    /// - Returns: a new `Store` object operating on `LocalState`.
    func map<LocalState, LocalAction, LocalMutation>(
        stateLens: Lens<State, LocalState>,
        actionPrism: Prism<Action, LocalAction>,
        mutationPrism: Prism<Mutation, LocalMutation>
    ) -> Store<LocalState, LocalAction, LocalMutation> {

        let localReducer: Reducer<LocalState, LocalMutation>
        localReducer = .init { localState, localMutation in
            /// Get the mutation
            let mutation = mutationPrism.inject(localMutation)

            /// Reduce the Store state
            self.reducer.body(&self.state, mutation)

            /// Change the localState
            localState = stateLens.get(self.state)
        }

        let localStoreController: Reactor<LocalAction, LocalMutation>
        localStoreController = .init { localAction in
            /// Get the action
            let action = actionPrism.inject(localAction)

            /// Get the Publisher
            let publisher = self.reactor.reaction(action)

            /// Map the publisher and return
            return publisher
                .compactMap { mutationPrism.tryGet($0) }
                .eraseToAnyPublisher()
        }

        return Store<LocalState, LocalAction, LocalMutation>(
            state: stateLens.get(state),
            reducer: localReducer,
            controller: localStoreController
        )
    }
}
