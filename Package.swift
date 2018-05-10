// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "storage-demo",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor-community/swiftybeaver-provider.git", .branch("master")),

        .package(url: "https://github.com/gperdomor/local-storage.git", .branch("beta")),
        .package(url: "https://github.com/gperdomor/minio-storage.git", .branch("beta"))
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "SwiftyBeaverProvider", "LocalStorage", "MinioStorage"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

