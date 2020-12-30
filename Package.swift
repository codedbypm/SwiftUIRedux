// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SwiftUI Redux",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_14)
    ],
    products: [
        .library(name: "SwiftUIRedux Lib", targets: ["SwiftUIRedux"])
    ],
    targets: [
        .target(name: "SwiftUIRedux"),
        .testTarget(name: "SwiftUIRedux Tests", dependencies: ["SwiftUIRedux"])
    ],
    swiftLanguageVersions: [.v5]
)
