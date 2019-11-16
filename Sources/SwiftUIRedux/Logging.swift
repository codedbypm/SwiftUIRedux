//
//  File.swift
//  
//
//  Created by Paolo Moroni on 16/11/2019.
//

import Foundation
import os.log

extension OSLog {

    private static var subsystem = Bundle.main.bundleIdentifier!

    /// Logs the events related to Stores, Actions, Reactors and Reducers
    static let redux = OSLog(subsystem: subsystem, category: "redux")
}
