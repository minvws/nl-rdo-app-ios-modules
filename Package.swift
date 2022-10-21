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
			name: "LunhCheck",
			targets: ["LunhCheck"]),
		.library(
			name: "QRGenerator",
			targets: ["QRGenerator"]),
	],
	dependencies: [],
	targets: [
		.target(
			name: "LunhCheck",
			dependencies: []),
		.testTarget(
			name: "LunhCheckTests",
			dependencies: ["LunhCheck"]),
		.target(
			name: "QRGenerator",
			dependencies: []),
	]
)
