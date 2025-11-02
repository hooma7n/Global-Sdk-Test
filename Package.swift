// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GlobalCommunicationSDK",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "GlobalCommunicationSDK", targets: ["GlobalCommunicationSDK"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.7.0")
    ],
    targets: [
        .target(
            name: "GlobalCommunicationSDK",
            dependencies: [
                .product(name: "RxSwift", package: "RxSwift", condition: .when(platforms: [.iOS])),
                .product(name: "RxCocoa", package: "RxSwift", condition: .when(platforms: [.iOS]))
            ],
            path: "Sources/GlobalCommunicationSDK"
        ),
        .testTarget(
            name: "GlobalCommunicationSDKTests",
            dependencies: ["GlobalCommunicationSDK"]
        )
    ]
)
