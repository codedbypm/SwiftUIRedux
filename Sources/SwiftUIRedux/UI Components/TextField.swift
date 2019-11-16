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

enum TextFieldAction {
    case onTextWillChange(String)
}

extension TextFieldAction: CustomStringConvertible {
    var description: String {
        switch self {
        case .onTextWillChange:
            return "onTextWillChange"
        }
    }
}

enum TextFieldMutation {
    case updateText(String)
}

struct TextFieldReactor: Reactor {

    func react(to action: TextFieldAction) -> AnyPublisher<TextFieldMutation, Never> {

        switch action {
        case .onTextWillChange(let text):
            os_log(.info, log: .redux, "[TextField] Reaction: UpdateText")
            return Just(.updateText(text)).eraseToAnyPublisher()
        }
    }
}

struct TextFieldState {
    var text: String = ""
}

struct TextFieldReducer: Reducer {

    func reduce(_ state: inout TextFieldState, mutation: TextFieldMutation) {
        switch mutation {
        case .updateText(let text):
            os_log(.info, log: .redux, "[TextField] Mutation: %@", String(describing: mutation))
            state.text = text
        }
    }
}

extension TextField where Label == Text {

    init(store: Store<TextFieldReducer, TextFieldReactor>) {
        let binding = Binding<String>(
            get: { store.state.text },
            set: { store.send(.onTextWillChange($0)) }
        )
        self = TextField("placeholder", text: binding)
    }
}
