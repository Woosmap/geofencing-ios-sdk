// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WoosmapGeofencingCore",
    platforms: [.iOS(.v11)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "WoosmapGeofencingCore",
            targets: ["WoosmapGeofencingCore"])
    ],
    dependencies: [
        // Surge Package
        .package(url: "https://github.com/Jounce/Surge.git", from: "2.3.0"),
        // Realm
        .package(url: "https://github.com/realm/realm-cocoa", from: "10.5.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "WoosmapGeofencingCore",
            dependencies: ["Surge","RealmSwift"],
            path: "WoosmapGeofencing/Sources/WoosmapGeofencing")
    ],
    exclude: ["assets", "doc"],
)
