// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "RDOModules",
	platforms: [
		.iOS(.v11)
	],
	products: [
		.library(
			name: "LuhnCheck",
			targets: ["LuhnCheck"]),
		.library(
			name: "QRGenerator",
			targets: ["QRGenerator"]),
		.library(
			name: "OpenIDConnect",
			targets: ["OpenIDConnect"])
	],
	dependencies: [
		.package(
			// A fork has been used to support both universal links and url schemes
			// Forked from: https://github.com/openid/AppAuth-iOS
			url: "https://github.com/Rool/AppAuth-iOS.git",
			branch: "feature/custom-url-support"
		),
		.package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", from: "9.0.0")
	],
	targets: [
		.target(
			name: "LuhnCheck",
			dependencies: []),
		.testTarget(
			name: "LuhnCheckTests",
			dependencies: ["LuhnCheck"]),
		.target(
			name: "QRGenerator",
			dependencies: []),
		.testTarget(
			name: "QRGeneratorTests",
			dependencies: ["QRGenerator"]),
		.target(
			name: "OpenIDConnect",
			dependencies: [.product(name: "AppAuth", package: "AppAuth-iOS")]),
		.testTarget(
			name: "OpenIDConnectTests",
			dependencies: ["OpenIDConnect", "OHHTTPStubs", .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs")]
		)
	]
)
