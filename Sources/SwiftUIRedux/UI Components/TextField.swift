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

public enum TextFieldMutation {
    case updateText(String)
}

public struct TextFieldReactor: Reactor {

    public func react(to action: TextFieldAction) -> AnyPublisher<TextFieldMutation, Never> {

        switch action {
        case .onTextWillChange(let text):
            os_log(.info, log: .redux, "[TextField] Reaction: UpdateText")
            return Just(.updateText(text)).eraseToAnyPublisher()
        }
    }
}

public struct TextFieldState {
    public var text: String = ""
}

public struct TextFieldReducer: Reducer {

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
