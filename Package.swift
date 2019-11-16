// swift-tools-version:5.1

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
    dependencies: [
//        .package(url: "git@github.com:codedbypm/swiftutils.git", .branch("master")),
        //        .package(url: "git@github.com:apple/swift-format.git", .branch("master"))
    ],
    targets: [
        .target(name: "SwiftUIRedux"),
        .testTarget(name: "SwiftUIRedux Tests", dependencies: ["SwiftUIRedux"])
    ],
    swiftLanguageVersions: [.v5]
)
