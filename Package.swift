// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Airwallex",
    defaultLocalization: "en-us",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "Airwallex",
            targets: ["Airwallex"]
        ),
        .library(
            name: "WeChatPay",
            targets: ["WeChatPay"]
        ),
        .library(
            name: "Card",
            targets: ["Card"]
        ),
        .library(
            name: "Redirect",
            targets: ["Redirect"]
        ),
    ],
    dependencies: [
        .package(
            name: "TrustDefender",
            url: "https://github.com/ilabsvictor/TrustDefender",
            .exact(Version(6, 1, 2))
        ),
        .package(
            name: "CardinalMobile",
            url: "https://github.com/ilabsvictor/CardinalMobile",
            .exact(Version(2, 2, 4))
        ),
    ],
    targets: [
        .target(
            name: "Airwallex",
            path: "Airwallex/Airwallex/Sources",
            exclude: [
                "Info.plist",
            ]
        ),
        .target(
            name: "WeChatPay",
            dependencies: [
                .target(name: "WeChatPay"),
            ],
            path: "Airwallex/WeChatPay",
            exclude: [
                "Info.plist"
            ]
        ),
        .target(
            name: "Card",
            dependencies: [
                .target(name: "Card"),
                .product(name: "TrustDefender", package: "TrustDefender"),
                .product(name: "CardinalMobile", package: "CardinalMobile")
            ],
            path: "Airwallex/Card",
            exclude: [
                "Info.plist"
            ]
        ),
        .target(
            name: "Redirect",
            dependencies: [
                .target(name: "Redirect"),
            ],
            path: "Airwallex/Redirect",
            exclude: [
                "Info.plist",
            ]
        )
    ]
)
