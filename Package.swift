// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SwiftUI Redux",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
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
