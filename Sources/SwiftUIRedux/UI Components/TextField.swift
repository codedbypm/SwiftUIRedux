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

public extension TextField {

    static var reducer: (inout TextFieldState, TextFieldAction) -> Void {
        return { state, action in
            switch action {
            case .update(let text):
                state.text = text
            }
        }
    }
}

extension TextField where Label == Text {

    public init(_ placeholder: String? = nil, onTextDidChange: @escaping (String) -> Void) {
        let store = Store<TextFieldState, TextFieldAction>(
            state: TextFieldState(),
            reducer: TextField.reducer
        )

        _ = store
            .$state
            .map { $0.text }
            .sink(receiveValue: onTextDidChange)

        let binding = Binding<String>(
            get: { store.state.text },
            set: { store.send(.update($0)) }
        )

        let placeholder = placeholder ?? ""
        self = TextField(placeholder, text: binding)
    }
}
