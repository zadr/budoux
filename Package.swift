// swift-tools-version: 5.4

import PackageDescription

let package = Package(
    name: "BudouX",
    products: [
        .library(
            name: "BudouX",
            targets: ["BudouX"]
		),
    ],
    targets: [
        .target(
            name: "BudouX",
			path: "swift/src",

			// resource paths are relative to target root, or `swift/Sources`
			resources: [
				.process("models/ja.json"),
				.process("models/zh-hans.json"),
				.process("models/zh-hant.json"),
			]
		),
        .testTarget(
            name: "BudouXTests",
            dependencies: ["BudouX"],
			path: "swift/tests"
		),
    ]
)
