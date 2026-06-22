// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "PerfectLogger",
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "PerfectLogger", targets: ["PerfectLogger"]),
    ],
    targets: [
        .target(
            name: "PerfectLogger",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "PerfectLoggerTests",
            dependencies: ["PerfectLogger"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
    ]
)
