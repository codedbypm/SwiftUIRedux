//
//  File.swift
//  
//
//  Created by Paolo Moroni on 16/11/2019.
//

import Combine
import Foundation
import os.log

public class Store<_Reducer, _Reactor>:
    ObservableObject
where
    _Reducer: Reducer,
    _Reactor: Reactor,
    _Reducer.Mutation == _Reactor.Mutation
//    _Reactor.Action: CustomStringConvertible
{

    // MARK: - Public properties
    
    public var objectWillChange: AnyPublisher<_Reducer.State, Never> {
        return objectWillChangeSubject.eraseToAnyPublisher()
    }

    public internal(set) var state: _Reducer.State {
        willSet { objectWillChangeSubject.send(newValue) }
    }

    // MARK: - Private properties

    private let objectWillChangeSubject = PassthroughSubject<_Reducer.State, Never>()
    private var cancellables: Set<AnyCancellable> = []
    private let reducer: _Reducer
    private let reactor: _Reactor

    // MARK: - Init

    public init(state: _Reducer.State, reactor: _Reactor, reducer: _Reducer) {
        self.state = state
        self.reactor = reactor
        self.reducer = reducer
    }

    // MARK: - Public methods

    public func send(_ action: _Reactor.Action) {
        os_log(.info, log: .redux, "[%@] Action: %@", String(describing: self), String(describing: action))
        reactor.react(to: action)
            .receive(on: DispatchQueue.main)
            .sink { self.reducer.reduce(&self.state, mutation: $0) }
            .store(in: &cancellables)
    }
}

//extension Store: CustomStringConvertible {
//    public var description: String {
//        switch _Reactor.self {
//        case is RootReactor.Type:
//            return "Root"
//        case is LoginReactor.Type:
//            return "Login"
//        case is UsersReactor.Type:
//            return "Users"
//        case is TextFieldReactor.Type:
//            return "TextField"
//        default:
//            assertionFailure("Error: this should not happen")
//            return ""
//        }
//    }
//}
//
