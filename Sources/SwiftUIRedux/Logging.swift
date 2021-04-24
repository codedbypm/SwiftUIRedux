//
// Project:  SwiftUIRedux
// Copyright © 2021 codedby.pm. All rights reserved.
//

import Foundation
import os.log

extension OSLog {

    private static var subsystem = Bundle.main.bundleIdentifier!

    /// Logs the events related to Stores, Actions, Reactors and Reducers
    public static let redux = OSLog(subsystem: subsystem, category: "redux")
}
