// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "oa-ios-sdk",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15),
        .macCatalyst(.v15),
        .visionOS(.v1),
        //.macOS(.v13)
    ],
    products: [
        // Marketing contains any code that does NOT require privacy disclosures. Mainly functional or utility features.
        .library(
            name: "Marketing",
            targets: ["Marketing"]),
        // MarketingData contains data collection for fraud and ads analysis, excludes IDFA related code.
        // Apps including this will probably require a privacy manifest.
        .library(
            name: "MarketingData",
            targets: ["MarketingData"]
        ),
        // MarketingDataIDFA adds an IDFA helper class for use with MarketingData.
        // App must show the ATT prompt and include a privacy manifest.
        .library(
            name: "MarketingDataIDFA",
            targets: ["MarketingDataIDFA"]
        )
    ],
    targets: [
        .target(
            name: "Marketing"),
        .target(
            name: "MarketingData",
            dependencies: ["Marketing"],
            linkerSettings: [
                .linkedFramework("WebKit", .when(platforms: [.iOS, .macCatalyst, .visionOS])),
                .linkedFramework("AdServices", .when(platforms: [.iOS, .macCatalyst, .visionOS]))
            ]
        ),
        .target(
            name: "MarketingDataIDFA",
            dependencies: ["MarketingData"],
            linkerSettings: [
                .linkedFramework("AdSupport", .when(platforms: [.iOS, .tvOS, .macCatalyst, .visionOS])),
                .linkedFramework("AppTrackingTransparency", .when(platforms: [.iOS, .tvOS, .macCatalyst, .visionOS]))
            ]
        ),
        .testTarget(
            name: "MarketingTests",
            dependencies: ["Marketing"],
            resources: [
                .copy("Resources/compression_lorem.txt"),
                .copy("Resources/compression_ambrose.txt"),
                .copy("Resources/compressed_ambrose.txt"),
                .copy("Resources/config.json"),
                .copy("Resources/config_data_disabled.json"),
                .copy("Resources/config_data_enabled.json"),
                .copy("Resources/config_log_level.json"),
                .copy("Resources/config_unsupported_fields.json"),
            ]
        ),
        .testTarget(
            name: "MarketingDataTests",
            dependencies: ["MarketingData"]
        ),
        .testTarget(
            name: "MarketingDataIDFATests",
            dependencies: ["MarketingDataIDFA"]
        )
    ]
)
