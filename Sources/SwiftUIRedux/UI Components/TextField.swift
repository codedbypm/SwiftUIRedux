//
//  File.swift
//  
//
//  Created by Paolo Moroni on 16/11/2019.
//

import Combine
import Foundation
import os.log
import SwiftUI

// MARK: - State

public struct TextFieldState {
    public var text: String = ""
}

// MARK: - Action

public enum TextFieldAction {
    case onTextWillChange(String)
}

extension TextFieldAction: CustomStringConvertible {
    public var description: String {
        switch self {
        case .onTextWillChange:
            return "onTextWillChange"
        }
    }
}

// MARK: - Mutation

public enum TextFieldMutation {
    case updateText(String)
}

public struct TextFieldReactor: Reactor {

    public init() {}

    public func react(to action: TextFieldAction) -> AnyPublisher<TextFieldMutation, Never> {

        switch action {
        case .onTextWillChange(let text):
            os_log(.info, log: .redux, "[TextField] Reaction: UpdateText")
            return Just(.updateText(text)).eraseToAnyPublisher()
        }
    }
}

public struct TextFieldReducer: Reducer {

    public init() {}

    public func reduce(_ state: inout TextFieldState, mutation: TextFieldMutation) {
        switch mutation {
        case .updateText(let text):
            os_log(.info, log: .redux, "[TextField] Mutation: %@", String(describing: mutation))
            state.text = text
        }
    }
}

extension TextField where Label == Text {

    public init(store: Store<TextFieldReducer, TextFieldReactor>) {
        let binding = Binding<String>(
            get: { store.state.text },
            set: { store.send(.onTextWillChange($0)) }
        )
        self = TextField("placeholder", text: binding)
    }
}
