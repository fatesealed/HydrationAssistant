// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "HydrationAssistant",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "HydrationAssistantDomain", targets: ["HydrationAssistantDomain"]),
        .executable(name: "HydrationAssistantApp", targets: ["HydrationAssistantApp"])
    ],
    targets: [
        .target(name: "HydrationAssistantDomain"),
        .executableTarget(
            name: "HydrationAssistantApp",
            dependencies: ["HydrationAssistantDomain"]
        ),
        .testTarget(
            name: "HydrationAssistantDomainTests",
            dependencies: ["HydrationAssistantDomain"]
        )
    ]
)
