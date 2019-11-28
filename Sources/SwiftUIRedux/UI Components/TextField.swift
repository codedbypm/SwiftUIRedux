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
    
    var text: String = ""
    
    public init() {}
}

// MARK: - Action

public enum TextFieldAction {
    case update(String)
}

extension TextFieldAction: Effect {
    public func reaction(state: TextFieldState) -> AnyPublisher<TextFieldMutation, Never> {
        switch self {
        case .update(let text):
            return Just(.textDidChange(text)).eraseToAnyPublisher()
        }
    }
}

extension TextFieldAction: CustomStringConvertible {
    public var description: String {
        switch self {
        case .update:
            return "update"
        }
    }
}

// MARK: - Mutation

public enum TextFieldMutation {
    case textDidChange(String)
}

// MARK: - Reducer

extension Reducers {

    public static func textFieldReducer(state: inout TextFieldState, mutation: TextFieldMutation) {
        switch mutation {
        case .textDidChange(let text):
            state.text = text
        }
    }
}

// MARK: - Store

extension TextField where Label == Text {

    public static func store() -> Store<TextFieldState, TextFieldAction> {
        return Store(
            state: TextFieldState(),
            reducer: Reducers.textFieldReducer
        )
    }
}

extension TextField where Label == Text {

    public init(_ placeholder: String? = nil, onTextDidChange: @escaping (String) -> Void) {
        let store = Self.store()

        let binding = Binding<String>(
            get: { store.state.text },
            set: { store.send(.update($0)) }
        )

        let placeholder = placeholder ?? ""
        self = TextField(placeholder, text: binding)
    }
}
