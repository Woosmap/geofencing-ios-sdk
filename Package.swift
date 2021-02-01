// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WoosmapGeofencing",
    platforms: [.iOS(.v10)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "WoosmapGeofencing",
            targets: ["WoosmapGeofencing"])
    ],
    dependencies: [
        // Surge Package
        .package(url: "https://github.com/Jounce/Surge.git", from: "2.3.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "WoosmapGeofencing",
            dependencies: ["Surge"],
            path: "WoosmapGeofencing/Sources/WoosmapGeofencing"),
        .testTarget(
            name: "WoosmapGeofencingTests",
            dependencies: ["WoosmapGeofencing"],
            path: "WoosmapGeofencing/Tests/WoosmapGeofencingTests")
    ]
)
