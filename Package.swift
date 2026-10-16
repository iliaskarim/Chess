// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Chess",
  platforms: [
    .macOS(.v14)
  ],
  dependencies: [
    .package(url: "git@github.com:iliaskarim/ChessCore.git", branch: "develop"),
    .package(url: "git@github.com:iliaskarim/CasanchessSwift.git", from: "1.0.0")
  ],
  targets: [
    .executableTarget(
      name: "Chess",
      dependencies: [
        .product(name: "ChessCore", package: "chesscore"),
        .product(name: "Casanchess", package: "casanchessswift")
      ],
      resources: [
        .copy("syzygy")
      ]
    )
  ]
)
