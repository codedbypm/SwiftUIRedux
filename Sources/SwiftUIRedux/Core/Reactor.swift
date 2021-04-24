//
// Project:  SwiftUIRedux
// Copyright © 2021 codedby.pm. All rights reserved.
//

import Combine
import Foundation

public struct Reactor<Action, Mutation> {

    public typealias Reaction = (Action) -> AnyPublisher<Mutation, Never>

    public let reaction: Reaction

    public init(reaction: @escaping Reaction) {
        self.reaction = reaction
    }
}

public extension Reactor {

    func lift<GlobalAction, GlobalMutation>(
        _ actionPrism: Prism<GlobalAction, Action>,
        _ mutationPrism:  Prism<GlobalMutation, Mutation>
    ) -> Reactor<GlobalAction, GlobalMutation> {

        return Reactor<GlobalAction, GlobalMutation> { globalAction in
            guard let action = actionPrism.tryGet(globalAction) else {
                return Empty<GlobalMutation, Never>(completeImmediately: false)
                    .eraseToAnyPublisher()
            }

            return self.reaction(action)
                .map { mutationPrism.inject($0) }
                .eraseToAnyPublisher()
        }
    }

    static func combine<Action, Mutation>(
        _ reactors: [Reactor<Action, Mutation>]
    ) -> Reactor<Action, Mutation> {
        return Reactor<Action, Mutation> { action in
            let initialResult = Empty<Mutation, Never>(completeImmediately: false)
                .eraseToAnyPublisher()

            let publisher = reactors
                .reduce(initialResult) { (result, reactor) -> AnyPublisher<Mutation, Never> in
                    return Publishers.Merge(result, reactor.reaction(action))
                        .eraseToAnyPublisher()
                }

            return publisher
                .eraseToAnyPublisher()
        }
    }
}

