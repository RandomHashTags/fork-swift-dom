// swift-tools-version:5.10
import PackageDescription
import CompilerPluginSupport

let package:Package = .init(
    name: "swift-dom",
    platforms: [.macOS(.v14), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(name: "DOM", targets: ["DOM"]),

        .library(name: "DynamicMemberFactoryMacro", targets: ["DynamicMemberFactoryMacro"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax", "510.0.1" ..< "601.0.0"),
    ],
    targets: [
        .target(
            name: "DOM",
            dependencies: [
                "DynamicMemberFactoryMacro"
            ]
        ),
        //.executableTarget(name: "Snippets", dependencies: ["DOM"]),

        .target(name: "DynamicMemberFactoryMacro",
            dependencies: [
                .target(name: "DynamicLookupMacros"),
            ],
            path: "Macros/DynamicMemberFactoryMacro"),

        .macro(name: "DynamicLookupMacros",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ],
            path: "Macros/DynamicLookupMacros"),
    ])
